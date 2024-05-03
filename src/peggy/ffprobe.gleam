import gleam/dict
import gleam/float
import gleam/list
import gleam/result
import gleam/string
import shellout

pub type StreamProperties {
  StreamProperties(
    width: String,
    height: String,
    sample_aspect_ratio: String,
    aspect_ratio: String,
    frame_rate: String,
  )
}

pub fn get_video_info(file_path: String) -> Result(StreamProperties, String) {
  let assert Ok(ffprobe) = shellout.which("ffprobe")
  case
    shellout.command(
      run: ffprobe,
      with: [
        "-v",
        "error",
        "-loglevel",
        "error",
        "-hide_banner",
        "-select_streams",
        "v:0",
        "-show_entries",
        "stream=width,height,sample_aspect_ratio,display_aspect_ratio,r_frame_rate",
        "-of",
        "default=noprint_wrappers=1",
        file_path,
      ],
      in: ".",
      opt: [],
    )
  {
    Ok(s) -> {
      let kv =
        string.split(s, "\n")
        |> list.fold(dict.new(), fold_kv)

      case
        [
          "width", "height", "sample_aspect_ratio", "display_aspect_ratio",
          "r_frame_rate",
        ]
        |> list.fold(True, fn(acc, v) { acc && dict.has_key(kv, v) })
      {
        True -> {
          Ok(StreamProperties(
            dict.get(kv, "width")
              |> result.unwrap(""),
            dict.get(kv, "height")
              |> result.unwrap(""),
            dict.get(kv, "sample_aspect_ratio")
              |> result.unwrap(""),
            dict.get(kv, "display_aspect_ratio")
              |> result.unwrap(""),
            dict.get(kv, "r_frame_rate")
              |> result.unwrap(""),
          ))
        }
        False -> Error("Failed to parse: " <> s)
      }
    }
    Error(#(_, es)) -> Error(es)
  }
}

fn fold_kv(acc, s) {
  case string.split(s, on: "=") {
    [a, b] -> dict.insert(acc, a, b)
    _ -> acc
  }
}

// ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input.mp4
// ffprobe -i <file> -show_entries format=duration -v quiet -of csv="p=0"
// ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input_video.mp4

pub fn get_duration(file_path: String) -> Result(Float, String) {
  let assert Ok(ffprobe) = shellout.which("ffprobe")
  case
    shellout.command(
      run: ffprobe,
      with: [
        "-show_entries",
        "format=duration",
        "-v",
        "error",
        "-of",
        "default=noprint_wrappers=1:nokey=1",
        file_path,
      ],
      in: ".",
      opt: [],
    )
  {
    Ok(s) ->
      case float.parse(string.trim(s)) {
        Ok(f) -> Ok(f)
        Error(_) -> Error("Failed to parse: " <> s)
      }
    Error(#(_, es)) -> Error(es)
  }
}
