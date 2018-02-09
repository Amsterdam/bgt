#!/usr/bin/env bash
#
# Make sure we have the ENV set correctly
#
set -e
set -u
cd "$(dirname $0)/src"
export PYTHONPATH="$PWD"
python3 fme/core.py
