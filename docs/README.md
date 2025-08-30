# Dotfiles Repository

A comprehensive macOS development environment configuration with organized structure and automated installation.

## 📁 Repository Structure

```
.dotfiles/
├── Brewfile              # Homebrew package dependencies
├── docs/                 # Documentation
│   └── README.md        # This file
├── editor/               # Editor configuration
│   └── editorconfig     # Cross-editor formatting rules
├── git/                  # Git configuration
│   ├── gitconfig        # Git settings and aliases
│   └── gitignore        # Global gitignore patterns
├── scripts/              # Installation and utility scripts
│   └── install.sh       # Automated installation script
├── shell/                # Shell configuration
│   ├── .zshrc          # Zsh configuration
│   ├── .aliases        # Shell aliases
│   ├── .functions      # Shell functions
│   └── .history        # Shell history configuration
└── terminal/             # Terminal configuration
    └── iterm2/          # iTerm2 preferences
        └── com.googlecode.iterm2.plist
```

## 🚀 Quick Start

### Prerequisites

- macOS
- Internet connection for downloading dependencies

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/gddabe/dotfiles.git ~/.dotfiles && cd ~/.dotfiles
   ```

2. **Run the installation script:**
   ```bash
   ./scripts/install.sh
   ```

The script will:

- Install Homebrew (if not present)
- Install all packages from Brewfile
- Set up fzf integration
- Create symbolic links for all configuration files
- Set zsh as the default shell

### Git Configuration

After running the installation script, configure your git user information:

```bash
# Set your git user name
git config --global user.name "Your Name"

# Set your git user email
git config --global user.email "your.email@example.com"
```

**Optional: GPG Commit Signing**

If you want to sign your commits with GPG:

```bash
# Generate a new GPG key
gpg --full-generate-key

# List your GPG keys
gpg --list-secret-keys --keyid-format=long

# Configure git to use your GPG key
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
```

### Post-Installation Verification

Verify that everything is working correctly:

```bash
# Check shell configuration
echo $SHELL
which zsh

# Check git configuration
git config --list --show-origin | head -10

# Check key development tools
which gh && gh --version
which jq && jq --version
which eza && eza --version
which ripgrep && rg --version

# Check Docker (if installed)
which docker && docker --version

# Verify SSH permissions (should be 600 for private key)
ls -la ~/.ssh/

# Test git aliases
git aliases | head -5
```

### Customization

#### Changing Default Editor

```bash
# Set VS Code as default editor
git config --global core.editor "code --wait"

# Set Vim as default editor
git config --global core.editor "vim"
```

#### Adjusting History Size

```bash
# Change history size (default: 10000)
git config --global core.pager "less -FX"

# Adjust diff colors
git config --global color.diff.meta "yellow bold"
```

### Manual iTerm2 Setup

After running the installation script, configure iTerm2 to use the custom preferences:

```bash
# Specify the preferences directory
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/.iterm2"

# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
```

**Note:** Restart iTerm2 after running these commands for the changes to take effect.

## 🛠️ Components

### Shell Configuration (`shell/`)

- **`.zshrc`**: Main zsh configuration with:

  - Lazy-loaded nvm
  - Pure prompt
  - Zsh plugins (syntax highlighting, autosuggestions)
  - Fzf integration
  - EZA color scheme

- **`.aliases`**: Useful shell aliases including:

  - Navigation shortcuts (`..`, `...`, etc.)
  - EZA aliases for modern file listing
  - Brew update alias
  - SSH key management

- **`.functions`**: Custom shell functions:

  - `mkd`: Create directory and cd into it
  - `fd`: Fuzzy find directories with fzf
  - `gf`: Git diff with fzf preview
  - `www`: Start HTTP server
  - `ramdisk`: Create RAM disk
  - SSH backup/restore utilities

- **`.history`**: Zsh history configuration with large history size and deduplication

### Git Configuration (`git/`)

- **`gitconfig`**: Comprehensive git configuration with:

  - User information
  - 20+ useful aliases (`git l`, `git s`, `git ca`, etc.)
  - Color settings
  - Whitespace handling
  - URL shorthands for GitHub

- **`gitignore`**: Global gitignore patterns for common files and OS-specific items

### Editor Configuration (`editor/`)

- **`editorconfig`**: Cross-editor formatting rules:
  - UTF-8 encoding
  - Tab indentation (except YAML: 2 spaces)
  - LF line endings
  - Automatic whitespace trimming

### Terminal Configuration (`terminal/`)

- **`iterm2/`**: iTerm2 preferences with:
  - Dracula color scheme
  - Hack Nerd Font
  - Custom keyboard shortcuts
  - Transparency and visual effects

### Package Dependencies (`Brewfile`)

**CLI Tools:**

- `git`, `coreutils`, `tldr`, `bat`, `z`, `nvm`
- `btop`, `dust`, `gnupg`, `eza`, `fzf`
- `gh`, `jq`, `ripgrep`, `fd`, `htop`, `tree`

**Shell:**

- `zsh` with syntax highlighting and autosuggestions

**Applications:**

- `brave-browser`, `google-chrome`
- `visual-studio-code`, `iterm2`
- `karabiner-elements` for keyboard customization
- `docker` for container development
- `postman` for API testing
- `rectangle` for window management

**Fonts:**

- SF Pro, SF Mono, DM Serif fonts
- Fira Code Nerd Font, Hack Nerd Font

## 🔧 Customization

### Adding New Configurations

1. Place configuration files in the appropriate directory
2. Update `scripts/install.sh` to create symlinks
3. Update this README

### Modifying Existing Configurations

Edit files directly in their respective directories. Changes will be reflected immediately due to symlinks.

## 🐛 Troubleshooting

### Common Issues

1. **Permission denied errors:**

   ```bash
   chmod +x scripts/install.sh
   ```

2. **iTerm2 preferences not loading:**

   - Restart iTerm2 after running the setup commands
   - Check that the plist file path is correct

3. **Missing fonts:**
   - Restart your terminal application after font installation
   - Verify fonts are installed in Font Book

### Resetting Configuration

To remove all symlinks and start fresh:

```bash
# Remove symlinks
rm ~/.gitignore ~/.gitconfig ~/.editorconfig ~/.zshrc ~/.aliases ~/.functions ~/.history ~/.iterm2

# Re-run installation
./scripts/install.sh
```

## 📚 Additional Setup

### SSH Configuration

Copy SSH keys from old machine:

```bash
# Copy .ssh folder contents
cp -r /path/to/old/.ssh ~/
```

### Brave Browser

Configure cookie blocking:

- Go to `brave://settings/shields/filters`
- Enable "EasyList-Cookie List"

### Karabiner-Elements

Import CapsLock configuration:

- Open Karabiner-Elements
- Go to Complex Modifications
- Import from URL: `https://raw.githubusercontent.com/Vonng/Capslock/master/mac_v3/capslock.json`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the installation script
5. Submit a pull request

## 📄 License

This repository is provided as-is for personal use. Feel free to adapt and modify for your own needs.
