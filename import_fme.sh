#!/usr/bin/env bash
#
# Make sure we have the ENV set correctly
#
set -e
set -u
cd src
echo "import of bgt started"
export PYTHONPATH=`pwd` # $PYTHONPATH:
python3 fme/core.py
