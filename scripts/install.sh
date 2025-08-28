#!/bin/sh

if [ ! -f $(which brew) ]; then
	echo "Installing homebrew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Installing bundles..."
brew bundle install

echo "Installing fzf integration..."
yes | $(brew --prefix)/opt/fzf/install

# Create symlinks for git configuration
ln -sf ~/.dotfiles/git/gitignore ~/.gitignore
ln -sf ~/.dotfiles/git/gitconfig ~/.gitconfig

# Create symlinks for editor configuration
ln -sf ~/.dotfiles/editor/editorconfig ~/.editorconfig

# Create symlinks for shell configuration
ln -sf ~/.dotfiles/shell/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/shell/.aliases ~/.aliases
ln -sf ~/.dotfiles/shell/.functions ~/.functions
ln -sf ~/.dotfiles/shell/.history ~/.history

# Create symlinks for terminal configuration
ln -sf ~/.dotfiles/terminal/iterm2 ~/.iterm2

echo "Making zsh the default shell..."
chsh -s $(which zsh)
exec ${SHELL} -l
