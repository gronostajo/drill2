#!/bin/bash

set -xe

GULP_VERSION="$(jq -r '.packages."node_modules/gulp".version // .dependencies.gulp.version' package-lock.json)"

npm i -g "gulp@$GULP_VERSION"
gulp --version
