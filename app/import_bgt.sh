#!/usr/bin/env bash
#
# Make sure we have the ENV set correctly
#
set -e
set -u

pushd /src
echo "create of database started"
export PYTHONPATH=$PYTHONPATH:`pwd`
python endproduct/bld_database.py
popd
