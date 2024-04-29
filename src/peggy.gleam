//// A module for utilizing FFMPEG in Gleam

import gleam/list
import glexec.{Stderr, Stdout}

/// Err that occurred during construction/execution of FFmpeg Command
pub type PeggyErr {
  FFmpegNotFound(String)
}

/// A file input provided to FFmpeg
pub opaque type File {
  File(String)
}

/// A CLI argument provided to FFmpeg
pub opaque type CmdOption {
  CmdOption(name: String, value: String)
}

/// Command provided to FFmpeg
pub opaque type Command {
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
pub fn exec_sync(cmd: Command) -> Result(List(String), List(String)) {
  let assert Ok(ffmpeg) = glexec.find_executable("ffmpeg")

  let args =
    cmd.options
    |> list.reverse
    |> list.map(fn(x) {
      case x {
        CmdOption(name, val) -> name <> val
      }
    })

  let files =
    cmd.files
    |> list.reverse
    |> list.map(fn(x) {
      case x {
        File(s) -> s
      }
    })

  case
    glexec.new()
    |> glexec.run_sync(glexec.Execve(list.concat([[ffmpeg], files, args])))
  {
    // TODO: Improve this travesty
    Ok(_) -> Ok([])
    Error(_) -> Error([])
  }
}
