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

# === AWS ECR + Docker helpers ===
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-992382717039}"
export AWS_REGION="${AWS_REGION:-us-east-2}"

_aws_ecr_require_env() {
  if [[ -z "${AWS_ACCOUNT_ID:-}" || -z "${AWS_REGION:-}" ]]; then
    echo "Set AWS_ACCOUNT_ID and AWS_REGION first."
    return 1
  fi
}

_aws_ecr_registry() {
  _aws_ecr_require_env || return 1
  echo "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
}

_aws_docker_resolve_tag() {
  local requested_tag="${1:-latest}"

  case "$requested_tag" in
    ts|timestamp)
      date +%Y%m%d-%H%M%S
      ;;
    git|gitsha|sha)
      local sha
      sha=$(git rev-parse --short HEAD 2>/dev/null) || {
        echo "Not in a git repo (needed for git tag mode)." >&2
        return 1
      }
      echo "$(date +%Y%m%d-%H%M%S)-$sha"
      ;;
    *)
      echo "$requested_tag"
      ;;
  esac
}

aws-docker-auth() {
  _aws_ecr_require_env || return 1
  local registry
  registry=$(_aws_ecr_registry) || return 1

  aws ecr get-login-password --region "$AWS_REGION" \
    | docker login --username AWS --password-stdin "$registry"
}

aws-docker-push() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: aws-docker-push <repo-name> <local-image[:tag]> [latest|timestamp|git|custom-tag]"
    return 1
  fi

  local repo="$1"
  local local_image="$2"
  local requested_tag="${3:-latest}"
  local tag
  tag=$(_aws_docker_resolve_tag "$requested_tag") || return 1

  _aws_ecr_require_env || return 1
  local registry ecr_uri
  registry=$(_aws_ecr_registry) || return 1
  ecr_uri="$registry/$repo"

  aws-docker-auth || return 1
  docker tag "$local_image" "$ecr_uri:$tag" || return 1
  docker push "$ecr_uri:$tag"
}

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
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
setopt INTERACTIVE_COMMENTS

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
