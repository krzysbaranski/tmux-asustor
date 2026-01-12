# tmux for ASUSTOR NAS

This repository contains everything needed to build an ASUSTOR APK package for tmux, a terminal multiplexer.

## About

tmux is a terminal multiplexer: it enables a number of terminals to be created, accessed, and controlled from a single screen. tmux may be detached from a screen and continue running in the background, then later reattached.

This package provides tmux binaries compiled from source for ASUSTOR NAS devices, enabling powerful terminal multiplexing directly on your NAS.

## Features

- **Session persistence**: Sessions survive network disconnections
- **Window management**: Multiple windows within a single session
- **Pane splitting**: Split windows horizontally or vertically
- **Session sharing**: Multiple users can attach to the same session
- **Scriptable**: Automate complex terminal layouts
- **Zero runtime dependencies**: All libraries bundled in the package

## Building

### Automated Build (GitHub Actions)

The package is automatically built using GitHub Actions on every push to the main branch. The workflow:

1. Installs required build dependencies
2. Downloads and compiles tmux, libevent, and ncurses from source
3. Reorganizes files into ASUSTOR package structure (bin/ at root)
4. Validates package contents against config.json
5. Packages everything into an ASUSTOR APK file
6. Uploads the package as a build artifact

You can download the built APK from the Actions tab after a successful build.

### Manual Build

Quick summary:
```bash
git clone https://github.com/krzysbaranski/tmux-asustor.git
cd tmux-asustor
chmod +x build.sh
./build.sh
```

The build process:
1. `build.sh` compiles tmux, libevent, and ncurses into a staging directory
2. `package.sh` (called by build.sh) reorganizes files into the ASUSTOR package structure
3. Files are placed in `apkg/bin/` and `apkg/lib/` directories
4. `validate-package.sh` checks that all files in config.json exist and warns about unexpected files

## Installation

1. Download the `.apk` file from the build artifacts
2. Log in to your ASUSTOR NAS web interface
3. Go to App Central
4. Click "Install Manually" (the gear icon)
5. Upload the `.apk` file
6. Follow the installation prompts

## Usage

After installation, tmux will be available in `/usr/local/AppCentral/tmux/bin/` and symlinked to `/usr/local/bin/`.

### Basic Commands

```bash
# Start a new session
tmux

# Start a new named session
tmux new -s mysession

# List sessions
tmux ls

# Attach to existing session
tmux attach -t mysession

# Detach from session (inside tmux)
# Press: Ctrl+b, then d

# Kill a session
tmux kill-session -t mysession
```

### Window Management (inside tmux)

- `Ctrl+b c` - Create new window
- `Ctrl+b n` - Next window
- `Ctrl+b p` - Previous window
- `Ctrl+b 0-9` - Switch to window by number
- `Ctrl+b w` - List windows
- `Ctrl+b &` - Kill current window

### Pane Management (inside tmux)

- `Ctrl+b %` - Split pane vertically
- `Ctrl+b "` - Split pane horizontally
- `Ctrl+b o` - Switch to next pane
- `Ctrl+b arrow` - Move between panes
- `Ctrl+b x` - Kill current pane
- `Ctrl+b z` - Toggle pane zoom

For more information, see the [tmux Wiki](https://github.com/tmux/tmux/wiki).

## Package Contents

This package includes:
- tmux 3.6a
- libevent 2.1.12 (bundled)
- ncurses 6.5 (bundled)

## Development

### Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions workflow
├── apkg/
│   └── CONTROL/
│       ├── config.json        # Package metadata (static file list)
│       ├── description.txt    # Package description
│       ├── changelog.txt      # Version history
│       ├── icon.png           # Package icon
│       ├── pre-install.sh     # Pre-installation script
│       ├── post-install.sh    # Post-installation script
│       ├── pre-uninstall.sh   # Pre-uninstallation script
│       └── post-uninstall.sh  # Post-uninstallation script
├── build.sh                   # Build script for tmux
├── package.sh                 # Package preparation script
├── validate-package.sh        # Package validation script
├── .gitignore                 # Git ignore patterns
└── README.md                  # This file
```

### Modifying the Build

To update tmux or dependency versions, edit the version variables at the top of `build.sh`:

```bash
TMUX_VERSION="3.6a"
LIBEVENT_VERSION="2.1.12"
NCURSES_VERSION="6.5"
```

### Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build
5. Submit a pull request

## References

- [ASUSTOR App Central Developer Guide](https://downloadgb.asustor.com/developer/App_Central_Developer_Guide_4.2.5_20231030.pdf)
- [tmux GitHub Repository](https://github.com/tmux/tmux)
- [tmux Wiki](https://github.com/tmux/tmux/wiki)
- [tmux Cheat Sheet](https://tmuxcheatsheet.com/)

## License

This packaging is released under ISC license, consistent with tmux's license.

tmux itself is:
- Copyright (C) Nicholas Marriott and contributors
- Licensed under ISC License

## Support

For issues related to:
- **This package**: Open an issue in this repository
- **tmux itself**: See [tmux GitHub Issues](https://github.com/tmux/tmux/issues)
- **ASUSTOR NAS**: Contact [ASUSTOR support](https://www.asustor.com/support)
