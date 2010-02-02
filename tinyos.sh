#! /usr/bin/env bash
# Here we setup the environment
# variables needed by the tinyos 
# make system

echo "Setting up for TinyOS 2.1.0"
export TOSROOT=
export TOSDIR=
export MAKERULES=

TOSROOT="/opt/tinyos-2.1.0"
TOSDIR="$TOSROOT/tos"
CLASSPATH=$CLASSPATH:$TOSROOT/support/sdk/java/tinyos.jar
MAKERULES="$TOSROOT/support/make/Makerules"
PYTHONPATH=$PYTHONPATH:.:/home/vijayender/wsn/moteworks/tinyoscvs/tinyos-2.x/support/sdk/python/

export TOSROOT
export TOSDIR
export CLASSPATH
export MAKERULES
export PYTHONPATH

