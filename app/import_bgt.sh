#!/usr/bin/env bash
#
# Make sure we have the ENV set correctly
#
pushd /src
export PYTHONPATH=$PYTHONPATH:`pwd`
/usr/bin/python3 /src/fme/core.py
popd
