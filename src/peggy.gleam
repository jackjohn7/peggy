//// A module for utilizing FFMPEG in Gleam

import gleam/list
import shellout

/// A file input provided to FFmpeg
pub type File {
  File(String)
}

/// A CLI argument provided to FFmpeg
pub type CmdOption {
  CmdOption(name: String, value: String)
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

/// Executes the command provided to ffmpeg
pub fn exec_sync(cmd: Command) -> Result(String, String) {
  let assert Ok(ffmpeg) = shellout.which("ffmpeg")

  let args =
    cmd.options
    |> list.reverse
    |> list.map(fn(x) {
      case x {
        CmdOption(name, val) -> [name, val]
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
