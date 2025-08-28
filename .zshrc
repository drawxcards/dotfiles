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

if command -v fzf >/dev/null; then
	if fzf --zsh >/dev/null; then
		source <(fzf --zsh)
	fi
fi


# Dotfiles
[[ -f ~/.dotfiles/.aliases ]] && source ~/.dotfiles/.aliases
[[ -f ~/.dotfiles/.functions ]] && source ~/.dotfiles/.functions

ssh-add --apple-load-keychain 2>/dev/null


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
