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
[[ -r "$ZSH_PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]] && source "$ZSH_PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh"


# TODO: clean this up
export PATH=/home/shynn/.cargo/bin:~/bin/:/home/shynn/tools/radiant/2025.1/bin/lin64:$PATH
export PATH="/home/shynn/.local/bin:$PATH"

# === NVM ===
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"


# === SDK MAN ===
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"


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
alias lg='lazygit'

alias gp='git pull'

gP() {
  local branch remote_branch remote branch_name

  branch=$(git rev-parse --abbrev-ref HEAD) || return
  remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)

  if [[ -z "$remote_branch" ]]; then
    remote=origin
    branch_name=$branch
  else
    remote=${remote_branch%%/*}
    branch_name=${remote_branch#*/}
  fi

  {
    local output exit_code
    output=$(git push "$remote" "$branch_name" 2>&1)
    exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
      print -r -- "$output"
    fi
  } &!
}

# Quick "Worktree" clones
recl() {
    if [[ $# -ne 2 ]]; then
      echo "Error: Exactly 2 arguments are required. You provided $#." >&2
      return
    fi
    print "Recloning ${1:a} -> ${2:a}"
    read
    git clone $1 $2

    url=$(cd $1 && git remote get-url origin)
    print "Setting reclone URL to $url. Make sure to ctrl-c if you don't want that."
    read
    (cd ${2:a} && git remote set-url origin $url && git pull)
}

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

export EDITOR=nvim
export VISUAL=nvim
autoload -Uz edit-command-line
zle -N edit-command-line

# Edit current buffer
bindkey -M viins '^E' edit-command-line
bindkey -M vicmd '^E' edit-command-line


# . "$HOME/.local/bin/env"
eval "$(zoxide init zsh)"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
setopt INTERACTIVE_COMMENTS

# ---------------------------
# Autosuggestions
# ---------------------------
[[ -r "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ==== Syntax Highlighting ===
[[ -r "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
