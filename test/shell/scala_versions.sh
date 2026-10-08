#!/usr/bin/env bash
# Scala versions exercised by version-specific integration tests.

scala_2_12="2.12.21"
scala_2_13="2.13.18"
scala_3_3="3.3.8"
scala_3_9="3.9.0" # LTS
scala_3="3.10.0" # Latest Next

scala_versions=(
  "$scala_2_12"
  "$scala_2_13"
  "$scala_3_3"
  "$scala_3_9"
  "$scala_3"
)
