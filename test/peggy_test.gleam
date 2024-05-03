import gleam/io
import gleam/string
import gleeunit
import gleeunit/should
import peggy
import peggy/ffprobe
import shellout
import simplifile

pub fn main() {
  gleeunit.main()
}

pub fn verify_ffmpeg_install_test() {
  let assert Ok(path) = shellout.which("ffmpeg")

  let _ =
    shellout.command(run: path, with: ["-version"], in: ".", opt: [
      shellout.LetBeStdout,
    ])
}

pub fn run_error_test() {
  case
    peggy.new_command()
    |> peggy.input("temp1.mp4")
    |> peggy.video_codec("libx264")
    |> peggy.output("temp2.mp4")
    |> peggy.exec_sync
  {
    Ok(_) -> True
    Error(e) -> string.ends_with(e, "No such file or directory\n")
  }
  |> should.equal(True)
}

pub fn run_sync_test() {
  // verify that file temp1.mp4 doesn't already exist
  case simplifile.verify_is_file("temp1.mp4") {
    Ok(True) -> {
      let assert Ok(Nil) = simplifile.delete("temp1.mp4")
      Nil
    }
    Ok(False) -> Nil
    Error(_) -> {
      io.println("Failed to verify existence of file temp1.mp4, failing")
      1
      |> should.equal(2)
    }
  }
  // verify that file temp2.mp4 doesn't already exist
  case simplifile.verify_is_file("temp2.mp4") {
    Ok(True) -> {
      let assert Ok(Nil) = simplifile.delete("temp2.mp4")
      Nil
    }
    Ok(False) -> Nil
    Error(_) -> {
      io.println("Failed to verify existence of file temp2.mp4, failing")
      should.fail()
    }
  }
  // create video file
  let _ =
    peggy.new_command()
    |> peggy.fmt("lavfi")
    |> peggy.input("color=c=black:s=1920x1080:d=5")
    |> peggy.video_codec("libx264")
    |> peggy.duration("5")
    |> peggy.output("temp1.mp4")
    |> peggy.exec_sync

  case simplifile.verify_is_file("temp1.mp4") {
    Ok(r) ->
      r
      |> should.equal(True)
    Error(_) -> {
      io.println("Failed to verify existence of file temp1.mp4, failing")
      should.fail()
    }
  }

  let _ =
    peggy.new_command()
    |> peggy.input("temp1.mp4")
    |> peggy.video_filter("scale=854:480")
    |> peggy.video_codec("libx264")
    |> peggy.output("temp2.mp4")
    |> peggy.exec_sync
  let assert Ok(Nil) = simplifile.delete("temp1.mp4")
  let assert Ok(Nil) = simplifile.delete("temp2.mp4")
}

pub fn add_arg_test() {
  peggy.new_command()
  |> peggy.input("temp1.mp4")
  |> peggy.video_filter("scale=854:480")
  |> should.equal(peggy.Command(
    files: [],
    options: [
      peggy.CmdOption(name: "-vf", value: "scale=854:480"),
      peggy.CmdOption(name: "-i", value: "temp1.mp4"),
    ],
    config: peggy.default_cfg,
  ))
}

pub fn output_test() {
  peggy.new_command()
  |> peggy.output("temp1.mp4")
  |> peggy.output("temp2.mp4")
  |> should.equal(peggy.Command(
    options: [],
    files: [peggy.File("temp2.mp4"), peggy.File("temp1.mp4")],
    config: peggy.default_cfg,
  ))
}

pub fn overwrite_test() {
  let video1 =
    peggy.new_command()
    |> peggy.fmt("lavfi")
    |> peggy.input("color=c=black:s=1920x1080:d=5")
    |> peggy.video_codec("libx264")
    |> peggy.duration("5")
    |> peggy.output("temp1.mp4")
    |> peggy.exec_sync

  video1
  |> should.equal(Ok(""))

  // check that the resolution is 1920x1080
  ffprobe.get_video_info("temp1.mp4")
  |> should.equal(
    Ok(ffprobe.StreamProperties("1920", "1080", "1:1", "16:9", "25/1")),
  )
  // now create a video set to overwrite the first one
  let _ =
    peggy.new_command()
    |> peggy.fmt("lavfi")
    |> peggy.input("color=c=black:s=840x480:d=5")
    |> peggy.video_codec("libx264")
    |> peggy.duration("5")
    |> peggy.overwrite
    |> peggy.output("temp1.mp4")
    |> peggy.exec_sync
  ffprobe.get_video_info("temp1.mp4")
  |> should.equal(
    Ok(ffprobe.StreamProperties("840", "480", "1:1", "7:4", "25/1")),
  )
  let assert Ok(Nil) = simplifile.delete("temp1.mp4")
}

pub fn no_overwrite_test() {
  let _ =
    peggy.new_command()
    |> peggy.fmt("lavfi")
    |> peggy.input("color=c=black:s=1920x1080:d=5")
    |> peggy.video_codec("libx264")
    |> peggy.duration("5")
    |> peggy.output("temp1.mp4")
    |> peggy.exec_sync
    |> should.equal(Ok(""))

  // check that the resolution is 1920x1080
  ffprobe.get_video_info("temp1.mp4")
  |> should.equal(
    Ok(ffprobe.StreamProperties("1920", "1080", "1:1", "16:9", "25/1")),
  )
  // now create a video set to overwrite the first one
  let _ =
    peggy.new_command()
    |> peggy.fmt("lavfi")
    |> peggy.input("color=c=black:s=840x480:d=5")
    |> peggy.video_codec("libx264")
    |> peggy.duration("5")
    |> peggy.output("temp1.mp4")
    |> peggy.exec_sync
  ffprobe.get_video_info("temp1.mp4")
  |> should.equal(
    Ok(ffprobe.StreamProperties("1920", "1080", "1:1", "16:9", "25/1")),
  )
  let assert Ok(Nil) = simplifile.delete("temp1.mp4")
}
