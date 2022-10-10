#!/bin/bash

docker run --rm \
    --name nap-build \
    --mount type=bind,source="$(pwd)",target=/nap \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    thenetadmin/nap \
    $* \
;
