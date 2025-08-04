#!/bin/sh

if [ ! -f $(which brew) ]; then
	echo "Installing homebrew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Installing bundles..."
brew bundle install

echo "Installing fzf integration..."
yes | $(brew --prefix)/opt/fzf/install

ln -sf ~/.dotfiles/config/gitignore ~/.gitignore
ln -sf ~/.dotfiles/config/gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/config/editorconfig ~/.editorconfig
ln -sf ~/.dotfiles/.zshrc ~/.zshrc

echo "Making zsh the default shell..."
chsh -s $(which zsh)
exec ${SHELL} -l
