#!/bin/bash

set -xe

GULP_VERSION="$(jq -r .dependencies.gulp package-lock.json)"
BOWER_VERSION="$(jq -r .dependencies.bower package-lock.json)"

npm i -g "gulp@$GULP_VERSION" "bower@$BOWER_VERSION"
gulp --version
bower --version
