# peggy

*NOTE: This package is WIP*

[![Package Version](https://img.shields.io/hexpm/v/peggy)](https://hex.pm/packages/peggy)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/peggy/)

```sh
gleam add peggy
```
```gleam
import peggy

pub fn main() {
  // creates a 5 second video of black screen
  peggy.new_command()
  |> peggy.add_arg("-f", "lavfi")
  |> peggy.add_arg("-i", "color=c=black:s=1920x1080:d=5")
  |> peggy.add_arg("-c:v", "libx264")
  |> peggy.add_arg("-t", "5")
  |> peggy.add_file("output.mp4")
  |> peggy.exec_sync
}
```

Further documentation can be found at <https://hexdocs.pm/peggy>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
