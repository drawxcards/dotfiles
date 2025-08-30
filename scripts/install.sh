#!/bin/bash

set -e  # Exit on any error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${LOG_FILE:-/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log}"
DRY_RUN=false
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --dry-run    Show what would be done without making changes"
            echo "  --help       Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Enable logging
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Installation started at $(date)"
echo "Log file: $LOG_FILE"
if $DRY_RUN; then
    echo "DRY RUN MODE - No changes will be made"
fi

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

print_dry_run() {
    echo -e "${BLUE}[DRY-RUN]${NC} $1"
}

# Function to prompt user for yes/no
prompt_user() {
    local prompt="$1"
    local default="${2:-n}"
    local response

    if $DRY_RUN; then
        print_dry_run "Would prompt: $prompt (default: $default)"
        return 1  # In dry-run, assume no for safety
    fi

    read -p "$prompt (y/N): " response
    response=${response:-$default}

    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# Function to execute command or simulate in dry-run
execute() {
    if $DRY_RUN; then
        print_dry_run "Would execute: $@"
        return 0
    else
        "$@"
    fi
}

# Function to detect command availability
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect zsh path intelligently
detect_zsh_path() {
    local zsh_paths=("/bin/zsh" "/usr/bin/zsh" "/usr/local/bin/zsh")

    # First try standard paths
    for path in "${zsh_paths[@]}"; do
        if [ -x "$path" ] && grep -q "^${path}$" /etc/shells 2>/dev/null; then
            echo "$path"
            return 0
        fi
    done

    # Fall back to which command
    if command_exists zsh; then
        local which_zsh="$(which zsh)"
        if [ -x "$which_zsh" ] && grep -q "^${which_zsh}$" /etc/shells 2>/dev/null; then
            echo "$which_zsh"
            return 0
        fi
    fi

    return 1
}

# Function to backup existing file
backup_file() {
    local file="$1"
    if [ ! -e "$file" ]; then
        return 0
    fi

    if ! $DRY_RUN; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$file" "$BACKUP_DIR/$(basename "$file").backup"
        print_status "Backed up $file to $BACKUP_DIR"
    else
        print_dry_run "Would backup $file to $BACKUP_DIR"
    fi
}

# Function to create symlink safely
create_symlink() {
    local source="$1"
    local target="$2"

    if [ -L "$target" ]; then
        local current_target="$(readlink "$target")"
        if [ "$current_target" = "$source" ]; then
            print_status "Symlink already exists and is correct: $target"
            return 0
        else
            print_warning "Symlink exists but points to different location: $target -> $current_target"
            backup_file "$target"
            execute rm "$target"
        fi
    elif [ -e "$target" ]; then
        print_warning "File exists at target location: $target"
        backup_file "$target"
        execute rm -rf "$target"
    fi

    execute ln -sf "$source" "$target"
    if [ $? -eq 0 ]; then
        print_status "Created symlink: $target -> $source"
    else
        print_error "Failed to create symlink: $target"
        return 1
    fi
}

print_status "Starting dotfiles installation..."

# Pre-flight checks
if [ ! -f "$DOTFILES_DIR/Brewfile" ]; then
    print_error "Brewfile not found at $DOTFILES_DIR/Brewfile"
    exit 1
fi

# Module 1: Homebrew Installation
if ! command_exists brew; then
    if prompt_user "Homebrew is not installed. Install it?"; then
        print_status "Installing Homebrew..."
        execute /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if command_exists brew; then
            print_status "Homebrew installed successfully"
        else
            print_error "Failed to install Homebrew"
            exit 1
        fi
    else
        print_warning "Skipping Homebrew installation"
    fi
else
    print_status "Homebrew is already installed"
fi

# Module 2: Brew Packages Installation
if command_exists brew; then
    if prompt_user "Install packages from Brewfile?"; then
        print_status "Installing packages from Brewfile..."
        execute brew bundle install --file="$DOTFILES_DIR/Brewfile"
        if [ $? -eq 0 ]; then
            print_status "Brew packages installed successfully"
        else
            print_error "Failed to install some packages from Brewfile"
        fi
    else
        print_warning "Skipping Brewfile installation"
    fi
else
    print_warning "Homebrew not available, skipping Brewfile installation"
fi

# Module 3: Symlinks Creation
if prompt_user "Create symlinks for configuration files?"; then
    print_status "Creating symlinks..."

    # Create backup directory if needed
    if ! $DRY_RUN && [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        print_status "Backup directory created: $BACKUP_DIR"
    fi

    # Git configuration
    create_symlink "$DOTFILES_DIR/git/gitignore" "$HOME/.gitignore"
    create_symlink "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

    # Editor configuration
    create_symlink "$DOTFILES_DIR/editor/editorconfig" "$HOME/.editorconfig"

    # Shell configuration
    create_symlink "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"
    create_symlink "$DOTFILES_DIR/shell/.aliases" "$HOME/.aliases"
    create_symlink "$DOTFILES_DIR/shell/.functions" "$HOME/.functions"
    create_symlink "$DOTFILES_DIR/shell/.history" "$HOME/.history"

    # Terminal configuration - iTerm2
    # Create .iterm2 directory if it doesn't exist
    if ! $DRY_RUN && [ ! -d "$HOME/.iterm2" ]; then
        execute mkdir -p "$HOME/.iterm2"
        print_status "Created iTerm2 preferences directory: $HOME/.iterm2"
    elif $DRY_RUN; then
        print_dry_run "Would create directory: $HOME/.iterm2"
    fi

    # Symlink the plist file directly into the .iterm2 directory
    create_symlink "$DOTFILES_DIR/terminal/iterm2/com.googlecode.iterm2.plist" "$HOME/.iterm2/com.googlecode.iterm2.plist"

    # Configure iTerm2 to use the custom preferences directory
    print_status "Configuring iTerm2 preferences..."
    execute defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/.iterm2"
    execute defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    print_status "iTerm2 preferences configured"

    print_status "All symlinks created successfully"
else
    print_warning "Skipping symlinks creation"
fi

# Module 4: Set Zsh as Default Shell
if prompt_user "Set Zsh as the default shell?"; then
    if command_exists zsh; then
        print_status "Setting Zsh as default shell..."

        zsh_path=$(detect_zsh_path)
        if [ $? -eq 0 ] && [ -n "$zsh_path" ]; then
            print_status "Using zsh at: $zsh_path"
            if execute chsh -s "$zsh_path"; then
                print_status "Zsh set as default shell successfully"
                print_status "Please restart your terminal or run 'exec \$SHELL -l' to apply changes"
            else
                print_error "Failed to set zsh as default shell"
                print_warning "You may need to add $zsh_path to /etc/shells (requires sudo)"
                print_warning "Or run: sudo sh -c 'echo $zsh_path >> /etc/shells'"
            fi
        else
            print_error "Could not find a suitable zsh installation"
            print_warning "Please ensure zsh is properly installed and in /etc/shells"
        fi
    else
        print_error "Zsh is not installed. Please install it first via Homebrew."
    fi
else
    print_warning "Skipping Zsh default shell setup"
fi

# Module 5: Security Setup
print_status "Setting up security measures..."

# Set proper permissions for SSH directory if it exists
if [ -d "$HOME/.ssh" ]; then
    print_status "Setting SSH directory permissions..."
    execute chmod 700 "$HOME/.ssh"
    if [ -f "$HOME/.ssh/id_rsa" ]; then
        execute chmod 600 "$HOME/.ssh/id_rsa"
    fi
    if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
        execute chmod 644 "$HOME/.ssh/id_rsa.pub"
    fi
    print_status "SSH permissions configured"
fi

# Module 6: Post-Installation Verification
print_status "Running post-installation verification..."

verification_passed=true

# Check symlinks
symlink_targets=(
    "$HOME/.gitignore:$DOTFILES_DIR/git/gitignore"
    "$HOME/.gitconfig:$DOTFILES_DIR/git/gitconfig"
    "$HOME/.editorconfig:$DOTFILES_DIR/editor/editorconfig"
    "$HOME/.zshrc:$DOTFILES_DIR/shell/.zshrc"
    "$HOME/.aliases:$DOTFILES_DIR/shell/.aliases"
    "$HOME/.functions:$DOTFILES_DIR/shell/.functions"
    "$HOME/.history:$DOTFILES_DIR/shell/.history"
    "$HOME/.iterm2/com.googlecode.iterm2.plist:$DOTFILES_DIR/terminal/iterm2/com.googlecode.iterm2.plist"
)

for target_pair in "${symlink_targets[@]}"; do
    IFS=':' read -r link target <<< "$target_pair"
    if [ -L "$link" ]; then
        current_target=$(readlink "$link")
        if [ "$current_target" = "$target" ]; then
            print_status "✓ $link -> $target"
        else
            print_warning "✗ $link points to $current_target (expected $target)"
            verification_passed=false
        fi
    else
        print_warning "✗ $link is not a symlink"
        verification_passed=false
    fi
done

# Check if zsh is default shell
if command_exists zsh; then
    zsh_path=$(detect_zsh_path)
    if [ -n "$zsh_path" ] && [ "$SHELL" = "$zsh_path" ]; then
        print_status "✓ Zsh is set as default shell"
    else
        print_warning "✗ Zsh is not set as default shell (current: $SHELL)"
    fi
fi

# Final summary
echo
print_status "Installation completed!"
echo "Log file: $LOG_FILE"
if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    print_status "Backup files created in: $BACKUP_DIR"
fi

if $verification_passed; then
    print_status "✓ All verifications passed"
else
    print_warning "⚠ Some verifications failed - check the log for details"
fi

if $DRY_RUN; then
    print_status "This was a dry run - no actual changes were made"
fi

echo
print_status "Next steps:"
echo "  1. Restart your terminal or run 'exec \$SHELL -l'"
echo "  2. Review the log file for any warnings or errors"
echo "  3. Test your new configuration"
