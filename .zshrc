autoload -Uz add-zsh-hook

_deferred_init_done=0
_deferred_init() {
  (( _deferred_init_done )) && return
  _deferred_init_done=1

  # --- Heavy but common ---
  source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
}

add-zsh-hook precmd _deferred_init

#  global history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000
SAVEHIST=1000

setopt APPEND_HISTORY        # Don't overwrite history
setopt SHARE_HISTORY         # Share history between terminals
setopt INC_APPEND_HISTORY    # Write to history immediately
setopt EXTENDED_HISTORY      # Timestamps in history
setopt HIST_IGNORE_DUPS      # No duplicate entries
setopt HIST_IGNORE_SPACE     # Ignore commands starting with space
setopt HIST_REDUCE_BLANKS

# Vim style keybindings
bindkey -v
bindkey -M viins 'jj' vi-cmd-mode
bindkey "^R" history-incremental-search-backward

autoload -Uz accept-and-hold
bindkey -M viins '^O' accept-and-hold
bindkey -M vicmd '^O' accept-and-hold

ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"

setup_plugins() {
  mkdir -p "$ZSH_PLUGIN_DIR"
  timeout 5 git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_PLUGIN_DIR/zsh-autocomplete" || echo "autcomplete clone failed"
  timeout 5 git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" || echo "syntax highlighting clone failed"
  timeout 5 git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_PLUGIN_DIR/zsh-autosuggestions"  || echo "autosuggestion clone failed"
}

alias setup_plugins=setup_plugins

# ---------------------------
# zsh-autocomplete (must be early)
# Remove any manual `compinit` calls when using this plugin.
# ---------------------------
_defer_autocomplete() {
  source "$ZSH_PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
  add-zsh-hook -d precmd _defer_autocomplete
}
add-zsh-hook precmd _defer_autocomplete


# TODO: clean this up
export PATH=/home/shynn/.cargo/bin:~/bin/:/home/shynn/tools/radiant/2025.1/bin/lin64:$PATH

# === NVM ===
export NVM_DIR="$HOME/.nvm"

_nvm_loaded=0
load_nvm() {
  (( _nvm_loaded )) && return
  _nvm_loaded=1
  source "$NVM_DIR/nvm.sh"
}

node() { load_nvm; command node "$@"; }
npm()  { load_nvm; command npm "$@"; }
npx()  { load_nvm; command npx "$@"; }


# === SDK MAN ===
export SDKMAN_DIR="$HOME/.sdkman"

_sdkman_loaded=0
sdk() {
  if (( ! _sdkman_loaded )); then
    _sdkman_loaded=1
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
  fi
  command sdk "$@"
}


# === Aliases ===
alias gs='git status'
alias px4='cd ~/Documents/Mach/px4/'
alias monorepo='cd ~/Documents/Mach/monorepo/'
alias school='cd ~/Documents/School/'
alias prove='cd ~/Documents/Prove/'

alias ls='ls --color=auto'
alias l='ls -lah'
alias grep='grep --color=auto'

alias please='sudo $(fc -ln -1)'
alias fix='fc -e nvim -1'

# === Starship ==
eval "$(starship init zsh)"

# Alias to better versions
alias ls='eza --icons'
alias ll='eza -lah --icons'
alias cat='bat --paging=never'


# ==== Syntax Highlighting ===
# source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"


# ---------------------------
# Autosuggestions
# ---------------------------
# source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"


# Save original prompt
PROMPT_NORMAL=$PROMPT

# Define a minimal transient prompt
PROMPT_TRANSIENT='%F{8}> %f'

function zle-line-finish {
  PROMPT=$PROMPT_TRANSIENT
  zle reset-prompt
}
zle -N zle-line-finish

function zle-line-init {
  PROMPT=$PROMPT_NORMAL
  zle reset-prompt
}
zle -N zle-line-init

function zle-keymap-select {
  case $KEYMAP in
    vicmd) echo -ne '\e[1 q' ;;  # block
    viins) echo -ne '\e[5 q' ;;  # beam
  esac
}
zle -N zle-keymap-select
echo -ne '\e[5 q'

autoload -Uz compinit
compinit -C

export EDITOR=nvim
export VISUAL=nvim
autoload -Uz edit-command-line
zle -N edit-command-line

# Edit current buffer
bindkey -M viins '^E' edit-command-line
bindkey -M vicmd '^E' edit-command-line


. "$HOME/.local/bin/env"
eval "$(zoxide init zsh)"
