#!/bin/bash

docker run --rm \
    --name nap-build \
    --mount type=bind,source="$(pwd)",target=/nap \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    thenetadmin/nap \
    $* \
;

if [ $? -ne 0 ]; then
    echo "#################################################"
    echo "Did not find the docker image to build this paper"
    echo "You may exeute the 'docker/build.sh' to build it"
    echo "And then redo 'make'"
    echo "#################################################"
fi
