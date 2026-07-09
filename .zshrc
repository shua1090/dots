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

function setup_plugins() {
  mkdir -p "$ZSH_PLUGIN_DIR"
  timeout 5 git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_PLUGIN_DIR/zsh-autocomplete" || echo "autocomplete clone failed"
  timeout 5 git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" || echo "syntax highlighting clone failed"
  timeout 5 git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_PLUGIN_DIR/zsh-autosuggestions" || echo "autosuggestion clone failed"
}

# ---------------------------
# zsh-autocomplete is expensive on large shells; keep it opt-in.
# ---------------------------
if [[ -n "${ENABLE_ZSH_AUTOCOMPLETE:-}" && -r "$ZSH_PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]]; then
  source "$ZSH_PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
fi


typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/bin"
  "$HOME/tools/radiant/2025.1/bin/lin64"
  $path
)

_lazy_source_shell_tool() {
  local marker="$1"
  local init_file="$2"
  shift 2

  if [[ -n "${parameters[$marker]:-}" && -o interactive ]]; then
    unset -f "$@"
    [[ -r "$init_file" ]] && source "$init_file"
  fi
}

_load_nvm() {
  _lazy_source_shell_tool NVM_DIR "$NVM_DIR/nvm.sh" nvm node npm npx yarn pnpm corepack
}

nvm() { _load_nvm; nvm "$@"; }
node() { _load_nvm; node "$@"; }
npm() { _load_nvm; npm "$@"; }
npx() { _load_nvm; npx "$@"; }
yarn() { _load_nvm; yarn "$@"; }
pnpm() { _load_nvm; pnpm "$@"; }
corepack() { _load_nvm; corepack "$@"; }

# === NVM ===
export NVM_DIR="$HOME/.nvm"
autoload -Uz is-at-least
if (( $+commands[nvm] == 0 )); then
  nvm() {
    unset -f nvm node npm npx yarn pnpm corepack
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    nvm "$@"
  }

  node() {
    unset -f nvm node npm npx yarn pnpm corepack
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    node "$@"
  }

  npm() {
    unset -f nvm node npm npx yarn pnpm corepack
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    npm "$@"
  }

  npx() {
    unset -f nvm node npm npx yarn pnpm corepack
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    npx "$@"
  }

  yarn() {
    unset -f nvm node npm npx yarn pnpm corepack
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    yarn "$@"
  }

  pnpm() {
    unset -f nvm node npm npx yarn pnpm corepack
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    pnpm "$@"
  }

  corepack() {
    unset -f nvm node npm npx yarn pnpm corepack
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    corepack "$@"
  }
fi


# === SDK MAN ===
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
  unset -f sdk java javac gradle mvn
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk "$@"
}

java() {
  unset -f sdk java javac gradle mvn
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  java "$@"
}

javac() {
  unset -f sdk java javac gradle mvn
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  javac "$@"
}

gradle() {
  unset -f sdk java javac gradle mvn
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  gradle "$@"
}

mvn() {
  unset -f sdk java javac gradle mvn
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  mvn "$@"
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

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
# ---------------------------
# Autosuggestions
# ---------------------------
[[ -r "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ==== Syntax Highlighting ===
[[ -r "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
