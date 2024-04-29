import gleam/io
import gleeunit
import gleeunit/should
import peggy
import simplifile

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
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
    |> peggy.add_arg("-f", "lavfi")
    |> peggy.add_arg("-i", "color=c=black:s=1920x1080:d=5")
    |> peggy.add_arg("-c:v", "libx264")
    |> peggy.add_arg("-t", "5")
    |> peggy.add_file("temp1.mp4")
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
    |> peggy.add_arg("-i", "temp1.mp4")
    |> peggy.add_arg("-vf", "scale=854:480")
    |> peggy.add_arg("-c:v", "libx264")
    |> peggy.add_file("temp2.mp4")
    |> peggy.exec_sync

  case simplifile.verify_is_file("temp2.mp4") {
    Ok(r) ->
      r
      |> should.equal(True)
    Error(_) -> {
      io.println("Failed to verify existence of file temp2.mp4, failing")
      should.fail()
    }
  }
}
