#!/usr/bin/env bash

./build.sh

docker save aorta24_segmentationcontainer | gzip -c > Aorta24_SegmentationContainer.tar.gz
