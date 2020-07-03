<img src="https://raw.githubusercontent.com/kittywhiskers/ffmpegScripts/master/misc/generic.png" width="200" style="display: block; margin-left: auto; margin-right: auto; width: 50%;" />

# ffmpegScripts

A bunch of `bash` scripts that help you take a folder with a variety of formats and convert them to a **singular, consistent format.** Useful for when you handle diverse media sources.

## Included "in the package"

- `ffmpegNormalize.sh`: The primary script that does the job!
- `ffmpegSetupMacOS.sh`: Setup script that replaces homebrew's provided `ffmpeg` with a version of ffmpeg with all options enabled (thanks to `homebrew-ffmpeg`) along with all other dependencies
- `ffmpegRun.sh`: For all your debug log needs

## Dependencies

- `homebrew` package manager (install it from [here](https://brew.sh))
- an internet connection _(only for `ffmpegSetupMacOS.sh`)_

## Script Defaults

- Input file can be anything, conversion will result in output with 720px width, `crf` value 18 (increase it to make file size smaller but worsen quality) in an MP4 container with x265 video encoding handled by `libx265` running with `slow` preset and 128k AAC audio.

### Why `slow` instead of `veryslow`

**Diminishing Returns**

![Diminishing Returns](https://raw.githubusercontent.com/kittywhiskers/ffmpegScripts/master/misc/coolgraph.png)

## License

Released under [The Unlicense](https://github.com/kittywhiskers/ffmpegScripts/blob/master/LICENSE)
