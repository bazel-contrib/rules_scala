"""Utilities for `update_*_integrity.py` scripts."""

from base64 import b64encode

from pathlib import Path

import argparse
import ast
import hashlib
import json
import re
import sys
import urllib.request


class UpdateIntegrityError(Exception):
    """Errors raised explicitly by this module."""


def get_integrity_file_path_and_generated_by(
    integrity_file_path,
    script_path,
):
    """Generates the integrity file's absolute path and its docstring.

    Args:
        integrity_file_path: integrity file path relative to the repo root
        script_path: path to the calling script, presumed to be in //scripts
    """
    script_file = Path(script_path)
    repo_root = script_file.parent.parent
    integrity_file = repo_root / integrity_file_path
    return (
        integrity_file,
        f'Generated and updated by {script_file.relative_to(repo_root)}.',
    )


def get_artifact_integrity(url):
    """Emits the integrity string for the specified artifact at `url`.

    Args:
        url: URL from which to download the artifact

    Returns:
        a string starting with `sha256-` and ending with the base 64 encoded
            sha256 checksum of the artifact file

    Raises:
        `UpdateIntegrityError` if downloading or checksumming fails
    """
    try:
        with urllib.request.urlopen(url) as data:
            body = data.read()

        sha256 = hashlib.sha256(body).digest()
        return f'sha256-{b64encode(sha256).decode('utf-8')}'

    except Exception as err:
        msg = f'while processing {url}: {err}'
        raise UpdateIntegrityError(msg) from err


def stringify_object(data):
    """Pretty prints `data` as a Starlark object to emit into an output file.

    Args:
        data: a Python list or dict

    Returns:
        a pretty-printed string version of `data` to represent a valid Starlark
            object in the output file
    """
    result = (
        json.dumps(data, indent=4)
            .replace('true', 'True')
            .replace('false', 'False')
    )
    # Add trailing commas.
    return re.sub(r'([]}"])\n', r'\1,\n', result) + '\n'


def sorted_semver_keyed_dict(semver_keyed_dict, reverse=False):
    """Returns a sorted copy of semver_keyed_dict."""
    return dict(sorted(
        semver_keyed_dict.items(),
        key=lambda item: [int(n) for n in item[0].split(".")],
        reverse=reverse,
    ))


def load_existing_data(existing_file, marker):
    """Loads existing integrity data from `existing_file`.

    This enables the script to avoid redownloading artifacts when the integrity
    information already exists.

    Args:
        existing_file: path to the existing integrity file
        marker: string identifying the beginning of the integrity data object

    Returns:
        the existing integrity data from `existing_file`,
            or `{}` if the file does not exist
    """
    if not existing_file.exists():
        return {}

    with existing_file.open('r', encoding='utf-8') as f:
        data = f.read()

    start = data.find(marker)

    if start == -1:
        msg = f'"{marker}" not found in {existing_file}'
        raise UpdateIntegrityError(msg)

    return ast.literal_eval(data[start + len(marker):])


def update_integrity_file(usage, file_path, data_marker, update_data, emit_data):
    """Implements `main()` for integrity file updater scripts.

    Args:
        usage: command line usage summary line
        file_path: path to the integrity file to generate or update
        data_marker: line prefix marking the start of the integrity data
        update_data: function `(existing data) -> updated data`
        emit_data: function `(open file handle, updated data) -> None`

    Raises:
        UpdateIntegrityError if any operation fails
    """
    parser = argparse.ArgumentParser(description = usage)

    parser.add_argument(
        '--integrity_file',
        type=str,
        default=str(file_path),
        help=f'integrity file path (default: {file_path})',
    )

    args = parser.parse_args()
    integrity_file = Path(args.integrity_file)

    try:
        existing_data = load_existing_data(integrity_file, data_marker)
        updated_data = update_data(existing_data)

        with integrity_file.open('w', encoding = 'utf-8') as f:
            emit_data(f, updated_data)

    except UpdateIntegrityError as err:
        print(f'Failed to update {integrity_file}: {err}', file=sys.stderr)
        sys.exit(1)
