"""Macros of the consumer module."""

load("@rules_scala//scala:advanced_usage/scala.bzl", "make_scala_library")
load("@rules_scala//scala:scala.bzl", "scala_library")

def consumer_library(name, **kwargs):
    """Declares a `scala_library`.

    Args:
        name: the target name
        **kwargs: other `scala_library` attributes
    """
    scala_library(name = name, **kwargs)

consumer_custom_library = make_scala_library()
