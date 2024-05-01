//// A module for utilizing FFmpeg in Gleam. It requires that you have
//// FFmpeg in your path. This modules contains the tools for building
//// FFmpeg commands in a type-safe manner appropriate for video
//// services written in this wonderful language.

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
pub fn input_url(cmd: Command, url: String) -> Command {
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
/// CMD: -c:v <video_codec>
pub fn video_codec(cmd: Command, codec: String) -> Command {
  // NOTE: Not sure how to test this
  add_arg(cmd, "-c:v", codec)
}

/// Specify audio codec
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
pub fn duration(cmd: Command, codec: String) -> Command {
  // TODO: Write tests for this
  add_arg(cmd, "-t", codec)
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
