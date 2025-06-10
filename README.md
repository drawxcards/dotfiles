# Installation

### Homebrew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Clone dotfiles

```
git clone https://github.com/gddabe/dotfiles.git ~/.dotfiles && cd ~/.dotfiles
```

### Brewfiles

```
brew bundle install
```

### iterm2

```
# Specify the preferences directory
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/.dotfiles/iterm2"

# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
```

### zsh

```
ln -sf ~/.dotfiles/.gitignore ~/.gitignore
ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/init.lua ~/.hammerspoon/init.lua
```

### ssh

- copy all files in .ssh folder from old machine to new machine

### Brave

- go to brave://settings/shields/filters and type `cookie`
- check EasyList-Cookie List to disable cookie questions

### Karabiner-Elements

- karabiner://karabiner/assets/complex_modifications/import?url=https://raw.githubusercontent.com/Vonng/Capslock/master/mac_v3/capslock.json
