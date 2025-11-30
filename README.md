# .dotfiles

Personal dotfiles managed with GNU Stow for macOS.

## Structure

This repository organizes dotfiles into three categories:

- **`safe/`** - Configuration files that can be safely stowed with directory folding
- **`unsafe/`** - Sensitive configurations stowed with `--no-folding` to prevent accidental overwrites
- **`scripts/`** - User scripts and binaries deployed to `~/bin`

## Prerequisites

- [GNU Stow](https://www.gnu.org/software/stow/)
- macOS (Darwin)

Install Stow via Homebrew:
```bash
brew install stow
```

## Usage

### Quick Start

```bash
# Show all available commands
make help

# Stow all packages
make stow

# Remove all stowed packages
make unstow

# Adopt existing local files
make adopt
```

### Available Commands

| Command | Description |
|---------|-------------|
| `make help` | Show help message with all available commands |
| `make stow` | Stow all packages (safe, unsafe, and scripts) |
| `make stow-safe` | Stow only safe packages |
| `make stow-unsafe` | Stow only unsafe packages (with no-folding) |
| `make stow-scripts` | Stow user scripts to ~/bin |
| `make unstow` | Remove all stowed packages |
| `make adopt` | Adopt existing local files into dotfiles |

### What is Stow?

[GNU Stow](https://www.gnu.org/software/stow/) is a symlink farm manager that creates symlinks from your home directory to files in this repository. This allows you to:

- Keep all dotfiles in version control
- Easily deploy configurations across multiple machines
- Update configurations by editing files in this repository

### Adopting Existing Files

If you have existing dotfiles in your home directory, use `make adopt` to move them into this repository while creating the appropriate symlinks.

## Configuration Highlights

### Included Configurations

- **Ghostty** - Terminal emulator configuration
- **Neovim** - Editor configuration with plugins
- **Aerospace** - Window manager configuration
- **Oh My Posh** - Shell prompt configuration
- **Git** - Version control settings
- **Nix Darwin** - System configuration
- **LSD** - Modern `ls` replacement configuration
- **Zsh** - Shell configuration with vi mode

### Custom Scripts

Scripts in `scripts/bin/` are automatically made executable and linked to `~/bin`, including:
- `kubetoggle` - Kubernetes context/namespace switching utility

## Development

This repository uses:
- Nix Darwin for system configuration
- Home Manager for user environment
- direnv with Nix flakes for project-specific environments

## License

Personal configuration files - use at your own discretion.