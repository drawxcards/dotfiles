#!/bin/sh

if [ ! -f $(which brew) ]; then
	echo "Installing homebrew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Installing bundles..."
brew bundle install

echo "Installing fzf integration..."
yes | $(brew --prefix)/opt/fzf/install

echo "Getting pubkey from github..."
mkdir -p ~/.ssh
# if id_rsa.pub doesn't exist
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    curl https://github.com/drawxcards.keys | tee -a ~/.ssh/drawxcards.pub
fi

echo "Cleaning up the dock..."
dockutil --no-restart --remove all
dockutil --no-restart --add "/Applications/Brave Browser.app"
dockutil --no-restart --add "/Applications/Visual Studio Code.app"
dockutil --no-restart --add "/Applications/iTerm.app"

killall Dock

ln -sf ~/.dotfiles/.gitignore ~/.gitignore
ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/.editorconfig ~/.editorconfig
ln -sf ~/.dotfiles/.zshrc ~/.zshrc

echo "Making zsh the default shell..."
chsh -s $(which zsh)
exec ${SHELL} -l
