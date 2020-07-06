#!/usr/bin/env bash

# https://unix.stackexchange.com/a/269367
trap 'trap - SIGINT; kill -SIGINT $$' SIGINT;

RANDOM_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
DECOMPOSITION_COUNTER=0

SOURCE_FILE=$1
DECOMPOSITION_CRF_TIMES=$2
DECOMPOSITION_CRF_VALUE=$3

if ! [ -x "$(command -v /usr/local/bin/ffmpeg)" ] || ! [ -x "$(command -v /usr/local/bin/ffprobe)" ]; then
  echo 'ffmpeg cannot be found in /usr/local/bin/, quitting :(' >&2
  exit 1
fi

function print_and_quit {
  echo $1; echo "ffmpegDecompose.sh [filepath] [extent] [crf]"; exit 1;
}

# Some rudimentary checks before we begin
if [ -z ${SOURCE_FILE+x} ]; then
  print_and_quit "Source file missing in arguments, quitting!" >&2;
elif [ -z ${DECOMPOSITION_CRF_TIMES+x} ]; then
  print_and_quit "Decomposition extent missing in arguments, quitting!" >&2;
elif [ -z ${DECOMPOSITION_CRF_VALUE+x} ]; then
  print_and_quit "Constant Rate Factor missing in arguments, quitting!" >&2;
elif [ ! -f "$SOURCE_FILE" ]; then
  print_and_quit "Cannot locate $SOURCE_FILE or is not a valid file, quitting!" >&2;
elif ! [[ $DECOMPOSITION_CRF_TIMES =~ ^[0-9]+$ ]]; then
  print_and_quit "Decomposition extent is not a valid number, quitting!"  >&2;
elif ! [[ $DECOMPOSITION_CRF_VALUE =~ ^[0-9]+$ ]]; then
  print_and_quit "Constant Rate Factor is not a valid number, quitting!"  >&2;
fi

# TODO: Add feature that allows choice between different codecs
function runffmpeg {
  "/usr/local/bin/ffmpeg" -y -i "$1" -c:v libx265 -preset slow -c:a aac -x265-params crf="$DECOMPOSITION_CRF_VALUE" "$2"; sync;
}

# Create our working directory and copy our original
mkdir $RANDOM_UUID && cp "$SOURCE_FILE" "$RANDOM_UUID"

# Run decomposition function a "zeroth" time before running in within the loop
runffmpeg $RANDOM_UUID/"$(echo $SOURCE_FILE | sed 's@.*/@@')" $RANDOM_UUID/"$DECOMPOSITION_COUNTER.mp4"

while [ $DECOMPOSITION_COUNTER != "$((($DECOMPOSITION_CRF_TIMES - 1)))" ]; do
  runffmpeg $RANDOM_UUID/"$DECOMPOSITION_COUNTER.mp4" $RANDOM_UUID/"$((($DECOMPOSITION_COUNTER+1))).mp4"
  DECOMPOSITION_COUNTER=$((($DECOMPOSITION_COUNTER+1)))
done;

mv $RANDOM_UUID/"$DECOMPOSITION_COUNTER.mp4" "$RANDOM_UUID.mp4"
