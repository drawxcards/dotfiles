#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to prompt user for yes/no
prompt_user() {
    local prompt="$1"
    local default="${2:-n}"
    local response

    read -p "$prompt (y/N): " response
    response=${response:-$default}

    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

print_status "Starting dotfiles installation..."

# Module 1: Homebrew Installation
if ! command -v brew >/dev/null 2>&1; then
    if prompt_user "Homebrew is not installed. Install it?"; then
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print_status "Homebrew installed successfully"
    else
        print_warning "Skipping Homebrew installation"
    fi
else
    print_status "Homebrew is already installed"
fi

# Module 2: Brew Packages Installation
if command -v brew >/dev/null 2>&1; then
    if prompt_user "Install packages from Brewfile?"; then
        print_status "Installing packages from Brewfile..."
        brew bundle install
        print_status "Brew packages installed successfully"
    else
        print_warning "Skipping Brewfile installation"
    fi
else
    print_warning "Homebrew not available, skipping Brewfile installation"
fi

# Module 3: Symlinks Creation
if prompt_user "Create symlinks for configuration files?"; then
    print_status "Creating symlinks..."

    # Git configuration
    ln -sf ~/.dotfiles/git/gitignore ~/.gitignore
    ln -sf ~/.dotfiles/git/gitconfig ~/.gitconfig
    print_status "Git configuration symlinks created"

    # Editor configuration
    ln -sf ~/.dotfiles/editor/editorconfig ~/.editorconfig
    print_status "Editor configuration symlink created"

    # Shell configuration
    ln -sf ~/.dotfiles/shell/.zshrc ~/.zshrc
    ln -sf ~/.dotfiles/shell/.aliases ~/.aliases
    ln -sf ~/.dotfiles/shell/.functions ~/.functions
    ln -sf ~/.dotfiles/shell/.history ~/.history
    print_status "Shell configuration symlinks created"

    # Terminal configuration
    ln -sf ~/.dotfiles/terminal/iterm2 ~/.iterm2
    print_status "Terminal configuration symlink created"

    print_status "All symlinks created successfully"
else
    print_warning "Skipping symlinks creation"
fi

# Module 4: Set Zsh as Default Shell
if prompt_user "Set Zsh as the default shell?"; then
    if command -v zsh >/dev/null 2>&1; then
        print_status "Setting Zsh as default shell..."

        # Try to find the best zsh path
        zsh_path=""
        if [ -f "/bin/zsh" ]; then
            zsh_path="/bin/zsh"
        elif [ -f "/usr/bin/zsh" ]; then
            zsh_path="/usr/bin/zsh"
        else
            zsh_path="$(which zsh)"
        fi

        # Check if the zsh path is in allowed shells
        if grep -q "^${zsh_path}$" /etc/shells 2>/dev/null; then
            if chsh -s "${zsh_path}"; then
                print_status "Zsh set as default shell. Please restart your terminal or run 'exec \$SHELL -l' to apply changes."
            else
                print_error "Failed to set zsh as default shell. You may need to add ${zsh_path} to /etc/shells or run this with sudo."
            fi
        else
            print_error "The zsh at ${zsh_path} is not in the allowed shells list (/etc/shells)."
            print_warning "You can either:"
            print_warning "  1. Add ${zsh_path} to /etc/shells (requires sudo)"
            print_warning "  2. Use the system zsh if available"
            print_warning "  3. Skip this step for now"
        fi
    else
        print_error "Zsh is not installed. Please install it first."
    fi
else
    print_warning "Skipping Zsh default shell setup"
fi

print_status "Installation completed!"
