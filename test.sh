#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

./build.sh

VOLUME_SUFFIX=$(dd if=/dev/urandom bs=32 count=1 | md5sum | cut --delimiter=' ' --fields=1)
# Maximum is currently 30g, configurable in your algorithm image settings on grand challenge
MEM_LIMIT="32g"

docker volume create aorta24_segmentationcontainer-output-$VOLUME_SUFFIX

echo $VOLUME_SUFFIX
# Do not change any of the parameters to docker run, these are fixed
docker run --rm --gpus all \
        --memory="${MEM_LIMIT}" \
        --memory-swap="${MEM_LIMIT}" \
        --network="none" \
        --cap-drop="ALL" \
        --security-opt="no-new-privileges" \
        --shm-size="128m" \
        --pids-limit="256" \
        -v $SCRIPTPATH/images/:/input/ \
        -v aorta24_segmentationcontainer-output-$VOLUME_SUFFIX:/output/ \
        aorta24_segmentationcontainer

docker run --rm \
        -v aorta24_segmentationcontainer-output-$VOLUME_SUFFIX:/output/ \
        python:3.10-slim ls -al /output/images/aortic-branches

docker run --rm \
        -v aorta24_segmentationcontainer-output-$VOLUME_SUFFIX:/output/ \
        python:3.10-slim cat /output/results.json | python -m json.tool

docker run --rm \
        -v aorta24_segmentationcontainer-output-$VOLUME_SUFFIX:/output/ \
        -v $SCRIPTPATH/test/:/input/ \
        python:3.10-slim python -c "import json, sys; f1 = json.load(open('/output/results.json')); f2 = json.load(open('/input/expected_output.json')); sys.exit(f1 != f2);"

if [ $? -eq 0 ]; then
    echo "Tests successfully passed..."
else
    echo "Expected output was not found..."
fi

docker volume rm aorta24_segmentationcontainer-output-$VOLUME_SUFFIX
