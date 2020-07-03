#!/usr/bin/env bash

INPUT_VERB="$(echo $1 | tr '[:upper:]' '[:lower:]')"
LATEST_DEBUG_LOG_LOCATION="$(find . -type f -name "*.log" | sort -r | head -n 1)"

if ! test -f "ffmpegNormalize.sh"; then
  echo "ffmpegNormalize.sh not found, program exiting" >&2;
  exit 1;
fi

if [ -z ${1+x} ]; then
  echo "No arguments passed, exiting. Run \"./ffmpegRun.sh help\" to print help" >&2;
  exit 1;
fi

if [ $INPUT_VERB == "help" ]; then
  echo "ffmpegRun.sh: a wrapper for ffmpegNormalize.sh with super debug powers!";
  echo "";
  echo "ffmpegRun.sh [command]";
  echo "";
  echo "List of [command] command verbs:";
  echo "start       - starts an instance of ffmpegNormalize with all output routed to a debug log";
  echo "showfails   - lists failed conversion from latest debug log";
  echo "showconvs   - lists files that were successfully converted from latest debug log";
  echo "showskips   - lists files that were skipped because of suffix-match from latest debug log";
  echo "showyellows - list files that were skipped because of double-suffix-matching from latest debug log";
  echo "showipts    - lists files that were input for processing from latest debug log";
  echo "printregex  - prints the regex that was passed to find from the latest debug log";
  echo "help        - prints this help message";
  echo ""
elif [ $INPUT_VERB == "start" ]; then
  ./ffmpegNormalize.sh &> "$(echo "$(date).log")";
elif [ $INPUT_VERB == "showfails" ]; then
  if test -f "$LATEST_DEBUG_LOG_LOCATION"; then
    cat "$LATEST_DEBUG_LOG_LOCATION" | grep "preserving original, deleting corrupt file" | sort -u;
  else
    echo "Cannot find any debug log, exiting." >&2;
    exit 1;
  fi
elif [ $INPUT_VERB == "showconvs" ]; then
  if test -f "$LATEST_DEBUG_LOG_LOCATION"; then
    cat "$LATEST_DEBUG_LOG_LOCATION" | grep "passes ffprobe, deleting original" | sort -u;
  else
    echo "Cannot find any debug log, exiting." >&2;
    exit 1;
  fi
elif [ $INPUT_VERB == "showskips" ]; then
  if test -f "$LATEST_DEBUG_LOG_LOCATION"; then
    cat "$LATEST_DEBUG_LOG_LOCATION" | grep "probably already processed, skipping" | sort -u;
  else
    echo "Cannot find any debug log, exiting." >&2;
    exit 1;
  fi
elif [ $INPUT_VERB == "showyellows" ]; then
  if test -f "$LATEST_DEBUG_LOG_LOCATION"; then
    cat "$LATEST_DEBUG_LOG_LOCATION" | grep "already processed and not corrupt, skipping, not deleting original" | sort -u;
  else
    echo "Cannot find any debug log, exiting." >&2;
    exit 1;
  fi
elif [ $INPUT_VERB == "showipts" ]; then
  if test -f "$LATEST_DEBUG_LOG_LOCATION"; then
    cat "$LATEST_DEBUG_LOG_LOCATION" | grep "Running ffmpeg with input" | sort -u;
  else
    echo "Cannot find any debug log, exiting." >&2;
    exit 1;
  fi
elif [ $INPUT_VERB == "printregex" ]; then
  if test -f "$LATEST_DEBUG_LOG_LOCATION"; then
    cat "$LATEST_DEBUG_LOG_LOCATION" | grep "Regex used by find is" | sort -u;
  else
    echo "Cannot find any debug log, exiting." >&2;
    exit 1;
  fi
else
  echo "Invalid argument passed, exiting. Run \"./ffmpegRun.sh help to print help\"" >&2;
  exit 1;
fi
