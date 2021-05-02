#!/usr/bin/env bash

source ${SCRIPTS_DIR}/common-functions.sh

JPEG_TURBO_VERSION=2.1.0

downloadTarArchive \
  "libjpegturbo" \
  "https://sourceforge.net/projects/libjpeg-turbo/files/2.1.0/libjpeg-turbo-${JPEG_TURBO_VERSION}.tar.gz/download"
  false
  false
