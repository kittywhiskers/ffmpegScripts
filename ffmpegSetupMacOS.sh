#!/usr/bin/env bash

if ! [ -x "$(command -v brew)" ]; then
  echo 'Homebrew is not installed, exiting :(' >&2;
  exit 1;
fi

if [ -x "$(command -v ffmpeg)" ]; then
  # Remove ffmpeg that comes with homebrew
  brew uninstall ffmpeg;
  brew cleanup;
fi

# Now install ffmpeg with most options
brew update
brew install chromaprint

# Uninstall ffmpeg (again) because chromaprint installed it
# and setup decklinksdk
brew uninstall --ignore-dependencies ffmpeg
brew install amiaopensource/amiaos/decklinksdk

# Install ffmpeg
brew tap homebrew-ffmpeg/ffmpeg
FFMPEG_OPTIONS="$(brew options homebrew-ffmpeg/ffmpeg/ffmpeg | grep -vE '\s' | grep -- '--with-' | tr '\n' ' ' | rev | cut -c2- | rev)"
bash -c "brew install homebrew-ffmpeg/ffmpeg/ffmpeg $FFMPEG_OPTIONS"

if [ -x "$(command -v ffmpeg)" ]; then
  echo 'ffmpeg has been successfully configured!';
else
  echo 'ffmpeg has not successfully installed, script failed :(' >&2;
  exit 1;
fi
