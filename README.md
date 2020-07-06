<img src="https://raw.githubusercontent.com/kittywhiskers/ffmpegScripts/master/misc/generic.png" width="200" style="display: block; margin-left: auto; margin-right: auto; width: 50%;" />

# ffmpegScripts

A bunch of `bash` scripts that (primarily) help you take a folder with a variety of formats and convert them to a **singular, consistent format.** Useful for when you handle diverse media sources.

## Included "in the package"

- `ffmpegNormalize.sh`: The primary script that does the job!
- `ffmpegSetupMacOS.sh`: Setup script that replaces homebrew's provided `ffmpeg` with a version of ffmpeg with all options enabled (thanks to `homebrew-ffmpeg`) along with all other dependencies, useful for also when you break your `ffmpeg` because of a bad case of `brew upgrade`
- `ffmpegRun.sh`: For all your debugging needs
- `ffmpegDecompose.sh`: For when `crf=50` isn't high enough (choose between `x265` and `x264`) **[experimental]**
- `ffmpegLoopStream.sh`: High quality looped video streaming for YouTube **[experimental]**
- `ffprobeDeleteCorrupts.sh`: Delete files that fail `ffprobe` corruption checks **[risky, untested]**

## Dependencies

- `homebrew` package manager (install it from [here](https://brew.sh))
- an internet connection _(only for `ffmpegSetupMacOS.sh`)_

## Script Defaults

- `ffmpegNormalize.sh`: Input file can be anything, conversion will result in output with 720px width, constant rate factor of 18 (increase it to make file size smaller but worsen quality) in an MP4 container with HEVC video encoding handled by `libx265` running with `slow` preset and 128k AAC audio.
- `ffmpegLoopStream.sh`: Input file can be anything, output stream will be to YouTube's RTMP servers (you'll need a key), with a constant rate factor of 12, it will use half the threads on your machine with a `512k` buffer, encoding with `libx264` (`slow` preset) and 128k AAC audio, output stream format is `mpegts`.

### Why `slow` instead of `veryslow`

**Because of Diminishing Returns**

![Diminishing Returns](https://raw.githubusercontent.com/kittywhiskers/ffmpegScripts/master/misc/coolgraph.png)

## License

Released under [The Unlicense](https://github.com/kittywhiskers/ffmpegScripts/blob/master/LICENSE)

