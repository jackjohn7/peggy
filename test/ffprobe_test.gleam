import gleam/io
import gleam/string
import gleeunit/should
import peggy
import peggy/ffprobe
import simplifile

pub fn info_test() {
  let _ =
    peggy.new_command()
    |> peggy.fmt("lavfi")
    |> peggy.input("color=c=black:s=1920x1080:d=5")
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

pub fn bad_test() {
  case ffprobe.get_video_info("temp1.mp4") {
    Ok(_) -> {
      io.println("Should have failed")
      False
    }
    Error(s) -> string.ends_with(s, "No such file or directory\n")
  }
  |> should.equal(True)
}
