#!/usr/bin/env bash

# `jar tf` writes CRLF line endings on Windows.
exec diff -u --strip-trailing-cr "$1" "$2"
