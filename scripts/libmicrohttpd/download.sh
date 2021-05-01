#!/usr/bin/env bash

source ${SCRIPTS_DIR}/common-functions.sh

MICROHTTPD_VERSION=0.9.73

downloadTarArchive \
  "libmicrohttpd" \
  "https://mirror.cedia.org.ec/gnu/libmicrohttpd/libmicrohttpd-${MICROHTTPD_VERSION}.tar.gz"
  false
  true
