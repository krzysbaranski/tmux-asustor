# Quick Start Guide

This guide will help you get started with building the tmux ASUSTOR package.

## Prerequisites

You need:
- A Linux environment (Ubuntu 20.04+ recommended)
- Internet connection to download sources
- About 300MB free disk space
- Build tools (see below)

## Option 1: Automated Build with GitHub Actions (Recommended)

1. Fork this repository
2. Push to the `main` or `master` branch
3. GitHub Actions will automatically build the package
4. Download the built `.apk` file from the Actions artifacts

## Option 2: Local Build

### Option 2a: Build with Docker (Recommended for Consistency)

Build inside a Docker container to ensure a consistent environment:

```bash
# Clone the repository
git clone https://github.com/krzysbaranski/tmux-asustor.git
cd tmux-asustor

# Build using Docker
docker run --rm -v $(pwd):/workspace -w /workspace ubuntu:22.04 bash -c "
  apt-get update && \
  apt-get install -y build-essential wget make pkg-config bison && \
  chmod +x build.sh && \
  ./build.sh
"
```

### Option 2b: Build Directly on Host

### Install Dependencies

On Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential wget make pkg-config bison
```

### Build the Package

```bash
# Clone the repository
git clone https://github.com/krzysbaranski/tmux-asustor.git
cd tmux-asustor

# Run the build script
chmod +x build.sh
./build.sh
```

This will:
1. Download tmux, libevent, and ncurses sources
2. Compile everything
3. Install files into the `apkg/` directory

### Package the ASUSTOR APK

Using Docker:
```bash
docker run --rm \
  -v $(pwd)/apkg:/source \
  -v $(pwd)/dist:/dest \
  ghcr.io/asustor-contrib/apkg-tools:latest
```

The `.apk` file will be created in the `dist/` directory.

## Installing on ASUSTOR NAS

1. Download the `.apk` file
2. Log into your ASUSTOR NAS web interface
3. Open App Central
4. Click the gear icon and select "Install Manually"
5. Upload the `.apk` file
6. Follow the installation wizard

## Using tmux

After installation, connect to your NAS via SSH and run:

```bash
# Start a new session
tmux

# Start a named session
tmux new -s work

# List sessions
tmux ls

# Attach to a session
tmux attach -t work

# Inside tmux, detach with: Ctrl+b d
```

### Essential Key Bindings

All tmux commands start with the prefix key (default: `Ctrl+b`):

| Key | Action |
|-----|--------|
| `Ctrl+b c` | Create new window |
| `Ctrl+b n` | Next window |
| `Ctrl+b p` | Previous window |
| `Ctrl+b %` | Split pane vertically |
| `Ctrl+b "` | Split pane horizontally |
| `Ctrl+b o` | Switch pane |
| `Ctrl+b d` | Detach from session |
| `Ctrl+b x` | Kill pane |
| `Ctrl+b &` | Kill window |

## Troubleshooting

### Build fails with "command not found"
- Make sure all dependencies are installed
- Check that you're using a compatible Linux distribution

### Build runs out of space
- Free up at least 300MB of disk space
- The build process creates temporary files in the `build/` directory

### Package installation fails on ASUSTOR
- Check that your NAS OS version is 5.1 or higher
- Verify the `.apk` file is not corrupted (check file size)

### tmux: command not found after installation
- The binary is at `/usr/local/AppCentral/tmux/bin/tmux`
- A symlink should be created at `/usr/local/bin/tmux`
- Try: `export PATH="/usr/local/AppCentral/tmux/bin:$PATH"`

## Getting Help

- Check the [README.md](README.md) for detailed documentation
- Open an issue on GitHub for bugs or questions
- See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines

## Next Steps

Once tmux is installed:
- Read the [tmux Wiki](https://github.com/tmux/tmux/wiki)
- Learn [tmux key bindings](https://tmuxcheatsheet.com/)
- Create a `~/.tmux.conf` for customization
