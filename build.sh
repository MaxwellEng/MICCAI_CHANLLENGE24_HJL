#!/usr/bin/env bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

docker build -t aorta24_segmentationcontainer "$SCRIPTPATH" 