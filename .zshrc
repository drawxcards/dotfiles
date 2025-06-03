fpath+=("$(brew --prefix)/share/zsh/site-functions")
export PATH="/usr/local/opt/python@3.10/libexec/bin:$PATH"

# Lazy-load nvm
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  source $(brew --prefix nvm)/nvm.sh
  nvm "$@"
}

# Prompt
autoload -U promptinit; promptinit
prompt pure

# Performance improvements
source $(brew --prefix)/etc/profile.d/z.sh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Dotfiles
[[ -f ~/.dotfiles/.aliases ]] && source ~/.dotfiles/.aliases
[[ -f ~/.dotfiles/.functions ]] && source ~/.dotfiles/.functions
