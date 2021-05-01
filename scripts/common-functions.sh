#!/usr/bin/env bash

# Function that downloads an archive with the source code by the given url,
# extracts its files and exports a variable SOURCES_DIR_${LIBRARY_NAME}
function downloadTarArchive() {
  # The full name of the library
  LIBRARY_NAME=$1
  # The url of the source code archive
  DOWNLOAD_URL=$2
  # Optional. If 'true' then the function creates an extra directory for archive extraction.
  NEED_EXTRA_DIRECTORY=$3
  # Optional ignore the root folder but keeps the rest intact
  IGNORE_FIRST_FOLDER=$4 # --strip-components=1

  if [ "$IGNORE_FIRST_FOLDER" = true ] ; then
    IGNORE_FIRST_FOLDER="--strip-components=1"
  else
    IGNORE_FIRST_FOLDER=
  fi

  ARCHIVE_NAME=${DOWNLOAD_URL##*/}
  # File name without extension
  LIBRARY_SOURCES="${ARCHIVE_NAME%.tar.*}"

  echo "Ensuring sources of ${LIBRARY_NAME} in ${LIBRARY_SOURCES}"

  if [[ ! -d "$LIBRARY_SOURCES" ]]; then
    curl -LO ${DOWNLOAD_URL}

    EXTRACTION_DIR="."
    if [ "$NEED_EXTRA_DIRECTORY" = true ] ; then
      EXTRACTION_DIR=${LIBRARY_SOURCES}
      mkdir ${EXTRACTION_DIR}
    fi

    tar xf ${ARCHIVE_NAME} ${IGNORE_FIRST_FOLDER} -C ${EXTRACTION_DIR}
    rm ${ARCHIVE_NAME}
  fi

  export SOURCES_DIR_${LIBRARY_NAME}=$(pwd)/${LIBRARY_SOURCES}
}

# Custom GIT FFmpeg repository
function downloadGitRepository() {
  # The full name of the library
  LIBRARY_NAME=$1
  # The url of the source code archive
  GIT_REPO=$2 # ${DOWNLOAD_URL}

  GIT_DIRECTORY=${LIBRARY_NAME}-git

  LIBRARY_SOURCES=$(pwd)/${GIT_DIRECTORY}

  if [[ ! -d "$LIBRARY_SOURCES" ]]; then
    git clone ${GIT_REPO} ${GIT_DIRECTORY}
  fi

  cd ${GIT_DIRECTORY}
  git reset --hard

  export SOURCES_DIR_${LIBRARY_NAME}=${LIBRARY_SOURCES}
}
