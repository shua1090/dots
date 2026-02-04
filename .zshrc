# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

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
source "$ZSH_PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

# TODO: clean this up
export PATH=/home/shynn/.cargo/bin:~/bin/:/home/shynn/tools/radiant/2025.1/bin/lin64:$PATH

# === NVM ===
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# === SDK MAN ===
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# === Aliases ===
alias gs='git status'
alias px4='cd ~/Documents/Mach/px4/'
alias monorepo='cd ~/Documents/Mach/monorepo/'
alias ls='ls --color=auto'
alias l='ls -lah'
alias grep='grep --color=auto'


# === Starship ==
eval "$(starship init zsh)"

# ==== Syntax Highlighting ===
source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"


# ---------------------------
# Autosuggestions
# ---------------------------
source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"


. "$HOME/.local/bin/env"
