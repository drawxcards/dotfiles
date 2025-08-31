# Path and environment setup
fpath+=("$(brew --prefix)/share/zsh/site-functions")
export PATH="/usr/local/opt/python@3.10/libexec/bin:$PATH"

# Lazy-load nvm for better performance
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  [ -s "$(brew --prefix nvm)/nvm.sh" ] && source "$(brew --prefix nvm)/nvm.sh"
  nvm "$@"
}

# Prompt setup
autoload -U promptinit && promptinit
prompt pure

# Zsh plugins and performance improvements
[ -f "$(brew --prefix)/etc/profile.d/z.sh" ] && source "$(brew --prefix)/etc/profile.d/z.sh"
[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Fzf integration
if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  fi
fi

# Completion settings
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# History search - commented out to avoid conflict with fzf's ^R binding
# bindkey '^R' history-incremental-search-backward

# Load dotfiles configuration
[[ -f ~/.dotfiles/shell/.history ]] && source ~/.dotfiles/shell/.history
[[ -f ~/.dotfiles/shell/.aliases ]] && source ~/.dotfiles/shell/.aliases
[[ -f ~/.dotfiles/shell/.functions ]] && source ~/.dotfiles/shell/.functions

# SSH keychain integration
ssh-add --apple-load-keychain 2>/dev/null || true

# ---------------------
# eza universal Dracula
# ---------------------
export EZA_COLORS="\
uu=36:\
uR=31:\
un=35:\
gu=37:\
da=2;34:\
ur=34:\
uw=95:\
ux=36:\
ue=36:\
gr=34:\
gw=35:\
gx=36:\
tr=34:\
tw=35:\
tx=36:\
xx=95:"
