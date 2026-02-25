## For Homebrew on macOS

- `brew install asciinema agg`
- Record(execute): `./macos-rec.sh`
- Edit,Replace: `./macos-replace.sh`
- Play(not execute): ./macos-play.sh`
- Generate gif: `./macos-agg.sh`

## For Podman on Ubuntu

- Install Rust
  - `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- `. "$HOME/.cargo/env"`
- Install asciinema
  - `cargo install --locked --git https://github.com/asciinema/asciinema`
- Install agg
  - `cargo install --git https://github.com/asciinema/agg`
- Record(execute): `./podman-rec.sh`
- Edit,Replace: `./podman-replace.sh`
- Play(not execute): ./podman-play.sh`
- Generate gif: `./podman-agg.sh`
