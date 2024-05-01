//// A module for utilizing FFmpeg in Gleam. It requires that you have
//// FFmpeg in your path. This modules contains the tools for building
//// FFmpeg commands in a type-safe manner appropriate for video
//// services written in this wonderful language.

// TODO: separate into the following modules:
//       audio, video, base, misc
import gleam/float

import gleam/int
import gleam/list
import shellout

/// A file input provided to FFmpeg
pub type File {
  File(String)
}

/// A CLI argument provided to FFmpeg
pub type CmdOption {
  CmdOption(name: String, value: String)
  Flag(flag: String)
}

/// Command provided to FFmpeg
pub type Command {
  Command(files: List(File), options: List(CmdOption))
}

/// Creates new command for executing an FFmpeg command
pub fn new_command() -> Command {
  Command(files: [], options: [])
}

/// Adds file to command
pub fn add_file(cmd: Command, file_name: String) -> Command {
  case cmd {
    Command(files, options) -> Command([File(file_name), ..files], options)
  }
}

/// Adds argument to command
pub fn add_arg(cmd: Command, name: String, value: String) -> Command {
  case cmd {
    Command(files, options) ->
      Command(files, [CmdOption(name, value), ..options])
  }
}

// Adds flag to command
pub fn add_flag(cmd: Command, flag: String) -> Command {
  case cmd {
    Command(files, options) -> Command(files, [Flag(flag), ..options])
  }
}

/// Executes the command provided to ffmpeg
pub fn exec_sync(cmd: Command) -> Result(String, String) {
  let assert Ok(ffmpeg) = shellout.which("ffmpeg")

  let args =
    cmd.options
    |> list.reverse
    |> list.map(fn(x) {
      case x {
        CmdOption(name, val) -> [name, val]
        Flag(flag) -> [flag]
      }
    })
    |> list.flatten
    |> list.append(["-loglevel", "error", "-hide_banner"])

  let files =
    cmd.files
    |> list.reverse
    |> list.map(fn(x) {
      case x {
        File(s) -> s
      }
    })

  case
    shellout.command(
      run: ffmpeg,
      with: list.concat([args, files]),
      in: ".",
      opt: [],
    )
  {
    Ok(s) -> Ok(s)
    Error(#(_, es)) -> Error(es)
  }
}

// These functions are all predefined helpers

/// Add input to command
pub fn input(cmd: Command, url: String) -> Command {
  // TODO: Write tests for this
  add_arg(cmd, "-i", url)
}

/// Specify format of output
pub fn fmt(cmd: Command, format: String) -> Command {
  // TODO: Write tests for this
  add_arg(cmd, "-f", format)
}

// TODO: Update command model to account for these settings specially to prevent collision and
//       enable a default setting
//       I lean toward no_overwrite being the default.

/// Overwrite output files if necessary
///
/// CMD: -y
pub fn overwrite(cmd: Command) -> Command {
  // TODO: Write tests for this
  add_flag(cmd, "-y")
}

/// Do not overwrite the output file if exists.
/// If the output file already exists, you will get an error
///
/// CMD: -n
pub fn no_overwrite(cmd: Command) -> Command {
  // TODO: Write tests for this
  add_flag(cmd, "-n")
}

/// Specify format of output
///  0 -> No loop
/// -1 -> Infinite loop
///
/// CMD: -stream_loop <number>
pub fn loop(cmd: Command, loops: Int) -> Command {
  // NOTE: Not sure how to test this
  add_arg(cmd, "-stream_loop", int.to_string(loops))
}

/// Allow forcing a decoder of a different media type than the one detected or designated by the demuxer.
///
/// CMD: -recast_media
pub fn allow_recast(cmd: Command) -> Command {
  // NOTE: Not sure how to test this
  add_flag(cmd, "-recast_media")
}

/// Specify video codec
///
/// use 'copy' to copy stream
///
/// CMD: -c:v <video_codec>
pub fn video_codec(cmd: Command, codec: String) -> Command {
  // NOTE: Not sure how to test this
  add_arg(cmd, "-c:v", codec)
}

/// Specify codec
///
/// use 'copy' to copy stream
///
/// CMD: -c <codec>
pub fn codec(cmd: Command, codec: String) -> Command {
  // NOTE: Not sure how to test this
  add_arg(cmd, "-c", codec)
}

/// Specify audio codec
///
/// use 'copy' to copy stream
///
/// CMD: -c:a <audio_codec>
pub fn audio_codec(cmd: Command, codec: String) -> Command {
  // NOTE: Not sure how to test this
  add_arg(cmd, "-c:a", codec)
}

/// Specify output of file
///
/// CMD: <final positional argument>
pub fn output(cmd: Command, output: String) -> Command {
  // TODO: Write tests for this
  add_file(cmd, output)
}

/// Specifies duration to read/write from/to input/output
/// Arg given before input -> duration of input
/// Arg given after input  -> duration of output
///
/// This argument takes precedent over `until` (-to)
///
/// CMD: -t <duration>
pub fn duration(cmd: Command, duration: String) -> Command {
  // TODO: Write tests for this
  add_arg(cmd, "-t", duration)
}

/// Specifies location to stop reading/writing at
/// Arg given before input -> duration of input
/// Arg given after input  -> duration of output
///
/// CMD: -to <position>
pub fn until(cmd: Command, stamp: String) -> Command {
  // TODO: Write tests for this
  add_arg(cmd, "-to", stamp)
}

/// Limit size of output file to a set number of bytes
///
/// CMD: -fs <bytes>
pub fn limit_size(cmd: Command, size: Int) -> Command {
  // TODO: Write tests for this
  add_arg(cmd, "-to", int.to_string(size))
}

/// Seek position in input or output
/// Arg given before input -> seek in input
/// Arg given after input  -> seek in output
///
/// CMD: -ss <position>
pub fn seek(cmd: Command, pos: Int) -> Command {
  // NOTE: Not sure how to test this
  add_arg(cmd, "-to", int.to_string(pos))
}

/// Seek position in input or output relative to EOF
/// Position should be negative in this case (0 is EOF)
/// Arg given before input -> seek in input
/// Arg given after input  -> seek in output
///
/// CMD: -sseof <position>
pub fn seek_eof(cmd: Command, pos: Int) -> Command {
  // NOTE: Not sure how to test this
  add_arg(cmd, "-to", int.to_string(pos))
}

/// Apply filter to video
///
/// CMD: -vf <filter>
pub fn video_filter(cmd: Command, filter: String) -> Command {
  // NOTE: Not sure how to test this
  add_arg(cmd, "-vf", filter)
}

/// Apply filter to audio
///
/// CMD: -af <filter>
pub fn audio_filter(cmd: Command, filter: String) -> Command {
  // NOTE: Not sure how to test this
  add_arg(cmd, "-af", filter)
}

/// Add metadata to output
/// # Usage
///
/// peggy.new_command()
/// |> peggy.input("input.mp4")
/// |> peggy.metadata("description = \"awesome video\"")
/// |> peggy.metadata("\"filmed by\" = \"some person\"")
/// |> peggy.output("output.mp4")
/// |> peggy.exec_sync()
///
/// CMD: -metadata <key=value>
pub fn metadata(cmd: Command, metastring: String) -> Command {
  // TODO: use metadata output to test this
  add_arg(cmd, "-metadata", metastring)
}

/// Disable video output
///
/// CMD: -vn
pub fn disable_video(cmd: Command) -> Command {
  // NOTE: Not sure how to test this
  add_flag(cmd, "-vn")
}

/// Disable audio output
///
/// CMD: -an
pub fn disable_audio(cmd: Command) -> Command {
  // NOTE: Not sure how to test this
  add_flag(cmd, "-an")
}

/// Set aspect ratio
///
/// CMD: -aspect <ratio>
pub fn aspect_ratio(cmd: Command, ratio: String) -> Command {
  add_arg(cmd, "-aspect", ratio)
}

/// Set frame size
///
/// CMD: -s <ratio>
pub fn frame_size(cmd: Command, size: String) -> Command {
  add_arg(cmd, "-s", size)
}

/// Set video frame rate
///
/// CMD: -s <ratio>
pub fn frame_rate(cmd: Command, rate: String) -> Command {
  add_arg(cmd, "-r", rate)
}

/// Set audio frame rate
///
/// CMD: -s <ratio>
pub fn audio_frame_rate(cmd: Command, rate: String) -> Command {
  add_arg(cmd, "-ar", rate)
}

/// Set audio quality
///
/// This configuration is codec-specific
///
/// CMD: -aq <quality>
pub fn audio_quality(cmd, quality: String) {
  add_arg(cmd, "-aq", quality)
}

/// Set frame size
///
/// CMD: -s <ratio>
pub fn frame_rate_max(cmd: Command, rate: String) -> Command {
  add_arg(cmd, "-fpsmax", rate)
}

/// Set video bitrate
///
/// CMD: -b:v <rate>
pub fn video_bitrate(cmd: Command, rate: String) -> Command {
  add_arg(cmd, "-b:v", rate)
}

/// Set audio bitrate
///
/// CMD: -b:a <rate>
pub fn audio_bitrate(cmd: Command, rate: String) -> Command {
  add_arg(cmd, "-b:a", rate)
}

/// Disable data
///
/// CMD: -dn
pub fn disable_data(cmd: Command) -> Command {
  add_flag(cmd, "-dn")
}

/// Set frame size
///
/// CMD: -pass <1|2|3>
pub fn set_pass(cmd: Command, pass: Int) -> Command {
  add_arg(cmd, "-pass", int.to_string(pass))
}

/// Set volume
/// 256 = normal
///
/// CMD: -vol <value>
pub fn volume(cmd: Command, volume: String) -> Command {
  add_arg(cmd, "-vol", volume)
}

/// Audio pad
///
/// CMD: -apad
pub fn audio_pad(cmd) {
  // NOTE: Not sure how to test this
  add_flag(cmd, "-apad")
}

/// Set number of frames
///
/// CMD: -frames <num>
pub fn num_frames(cmd, num) {
  // NOTE: Not sure how to test this yet (ffprobe perhaps?)
  add_arg(cmd, "-frames", num)
}

/// Set number of video frames
///
/// CMD: -frames <num>
pub fn num_video_frames(cmd, num) {
  // NOTE: Not sure how to test this yet (ffprobe perhaps?)
  add_arg(cmd, "-vframes", num)
}

/// Set number of audio frames
///
/// CMD: -frames <num>
pub fn num_audio_frames(cmd, num) {
  // NOTE: Not sure how to test this yet (ffprobe perhaps?)
  add_arg(cmd, "-vframes", num)
}

/// Set maximum error rate
/// 0.0 -> No errors
/// 1.0 -> All errors
///
/// CMD: -max_err_rate <rate>
pub fn err_rate(cmd, rate: Float) {
  // NOTE: Not sure how to test this yet (test bounds?)
  add_arg(cmd, "-max_err_rate", float.to_string(rate))
}

/// Set target filetype
pub fn target(cmd, tgt) {
  // NOTE: Not sure how to test this yet (test bounds?)
  add_arg(cmd, "-target", tgt)
}

/// Set discard
pub fn discard(cmd) {
  add_flag(cmd, "-discord")
}

/// Set discard
pub fn disposition(cmd) {
  add_flag(cmd, "-disposition")
}

// subtitle options
//Subtitle options:
// 102   │ -s size             set frame size (WxH or abbreviation)
// 103   │ -sn                 disable subtitle
// 104   │ -scodec codec       force subtitle codec ('copy' to copy stream)
// 105   │ -stag fourcc/tag    force subtitle tag/fourcc
// 106   │ -fix_sub_duration   fix subtitles duration
// 107   │ -canvas_size size   set canvas size (WxH or abbreviation)
// 108   │ -spre preset        set the subtitle options to the indicated preset
pub fn disable_subtitle(cmd) {
  add_flag(cmd, "-sn")
}

pub fn subtitle_codec(cmd, codec) {
  add_arg(cmd, "-c:s", codec)
}
