# Ghostty auto-injects zsh integration for the first shell it launches.
# Source it here too so nested zsh sessions keep prompt/cwd integration.
if [[ -o interactive && -n "${GHOSTTY_RESOURCES_DIR:-}" && -r "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration" ]]; then
  source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi

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

if [[ -o interactive ]]; then
  # Vim style keybindings
  bindkey -v
  bindkey -M viins 'jj' vi-cmd-mode
  bindkey "^R" history-incremental-search-backward

  autoload -Uz accept-and-hold
  bindkey -M viins '^O' accept-and-hold
  bindkey -M vicmd '^O' accept-and-hold
fi

ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZSH_COMPLETION_STYLE="${ZSH_COMPLETION_STYLE:-autocomplete}" # autocomplete|fzf|plain

mkdir -p "$ZSH_PLUGIN_DIR" "$ZSH_CACHE_DIR" 2>/dev/null
if [[ ! -d "$ZSH_CACHE_DIR" || ! -w "$ZSH_CACHE_DIR" ]]; then
  ZSH_CACHE_DIR="${TMPDIR:-/tmp}/zsh-${UID:-user}"
  mkdir -p "$ZSH_CACHE_DIR" 2>/dev/null
fi
if [[ -z "${ANTIDOTE_HOME:-}" ]]; then
  ANTIDOTE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/antidote"
  [[ -w "${ANTIDOTE_HOME:h}" ]] || ANTIDOTE_HOME="$ZSH_CACHE_DIR/antidote"
  export ANTIDOTE_HOME
fi

_zsh_run_with_timeout() {
  local seconds="$1"
  shift

  if (( $+commands[timeout] )); then
    command timeout "$seconds" "$@"
  elif (( $+commands[gtimeout] )); then
    command gtimeout "$seconds" "$@"
  else
    command "$@"
  fi
}

_zsh_clone_plugin() {
  local name="$1"
  local url="$2"
  local target="$ZSH_PLUGIN_DIR/$name"

  [[ -d "$target/.git" ]] && return 0
  _zsh_run_with_timeout 20 git clone --depth 1 -- "$url" "$target"
}

setup_plugins() {
  mkdir -p "$ZSH_PLUGIN_DIR"
  _zsh_clone_plugin zsh-autocomplete https://github.com/marlonrichert/zsh-autocomplete.git || echo "autocomplete clone failed"
  _zsh_clone_plugin zsh-completions https://github.com/zsh-users/zsh-completions.git || echo "completions clone failed"
  _zsh_clone_plugin fzf-tab https://github.com/Aloxaf/fzf-tab.git || echo "fzf-tab clone failed"
  _zsh_clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git || echo "autosuggestions clone failed"
  _zsh_clone_plugin fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting.git || echo "fast syntax highlighting clone failed"
  [[ -d "$HOME/.antidote/.git" ]] || _zsh_run_with_timeout 20 git clone --depth 1 -- https://github.com/mattmc3/antidote.git "$HOME/.antidote" || echo "antidote clone failed"
}

_zsh_source_antidote() {
  local candidate
  for candidate in \
    "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh" \
    "${HOMEBREW_PREFIX:-}/opt/antidote/share/antidote/antidote.zsh" \
    "/opt/homebrew/opt/antidote/share/antidote/antidote.zsh" \
    "/usr/local/opt/antidote/share/antidote/antidote.zsh" \
    "/usr/share/zsh-antidote/antidote.zsh"; do
    [[ -n "$candidate" && -r "$candidate" ]] || continue
    source "$candidate"
    return 0
  done

  return 1
}

_zsh_load_antidote_bundle() {
  local name="$1"
  local manifest="$2"
  local manifest_file="$ZSH_CACHE_DIR/$name.plugins.txt"
  local bundle_file="$ZSH_CACHE_DIR/$name.plugins.zsh"
  local current_manifest=""

  [[ -d "$ZSH_CACHE_DIR" && -w "$ZSH_CACHE_DIR" ]] || return 1

  [[ -r "$manifest_file" ]] && current_manifest="$(<"$manifest_file")"
  if [[ "$current_manifest" != "$manifest" ]]; then
    print -r -- "$manifest" >| "$manifest_file" || return 1
  fi

  if [[ ! -r "$bundle_file" || ! "$bundle_file" -nt "$manifest_file" ]]; then
    local bundle_tmp="$bundle_file.tmp.$$"
    _zsh_source_antidote || return 1
    antidote bundle < "$manifest_file" >| "$bundle_tmp" 2>/dev/null || {
      rm -f "$bundle_tmp"
      return 1
    }
    command mv "$bundle_tmp" "$bundle_file" || return 1
  fi

  source "$bundle_file"
}

_zsh_init_compinit() {
  autoload -Uz compinit
  local dump_file="$ZSH_CACHE_DIR/.zcompdump-${ZSH_VERSION}"

  if [[ -r "$dump_file" ]]; then
    compinit -i -C -d "$dump_file"
  else
    compinit -i -d "$dump_file"
  fi
}

_zsh_load_completion_plugins() {
  local completions_manifest='zsh-users/zsh-completions kind:fpath path:src'
  local completion_loaded=0

  if ! _zsh_load_antidote_bundle zsh-completions "$completions_manifest"; then
    [[ -d "$ZSH_PLUGIN_DIR/zsh-completions/src" ]] && fpath=("$ZSH_PLUGIN_DIR/zsh-completions/src" $fpath)
  fi

  zstyle ':completion:*' use-cache on
  zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=** r:|=**'
  zstyle ':completion:*' menu select
  zstyle ':completion:*' group-name ''
  zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'

  case "$ZSH_COMPLETION_STYLE" in
    autocomplete)
      zstyle ':autocomplete:*' delay 0.18
      zstyle ':autocomplete:*' timeout 0.25
      zstyle ':autocomplete:*' min-input 2
      zstyle ':autocomplete:*:*' list-lines 8
      zstyle ':autocomplete:recent-paths:*' list-lines 6
      zstyle ':autocomplete:*' ignored-input '..##'
      zstyle ':autocomplete:*' add-space executables aliases functions builtins reserved-words commands
      zmodload zsh/terminfo 2>/dev/null

      if [[ -z "${terminfo[kcbt]:-}" ]]; then
        _zsh_init_compinit
        return
      fi

      if _zsh_load_antidote_bundle zsh-autocomplete 'marlonrichert/zsh-autocomplete'; then
        completion_loaded=1
      elif [[ -r "$ZSH_PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]]; then
        source "$ZSH_PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
        completion_loaded=1
      fi

      (( completion_loaded )) || _zsh_init_compinit
      ;;
    fzf|fzf-tab)
      _zsh_init_compinit
      if ! _zsh_load_antidote_bundle zsh-fzf-tab 'Aloxaf/fzf-tab'; then
        [[ -r "$ZSH_PLUGIN_DIR/fzf-tab/fzf-tab.plugin.zsh" ]] && source "$ZSH_PLUGIN_DIR/fzf-tab/fzf-tab.plugin.zsh"
      fi
      ;;
    plain|none)
      _zsh_init_compinit
      ;;
    *)
      echo "Unknown ZSH_COMPLETION_STYLE=$ZSH_COMPLETION_STYLE; falling back to plain compinit." >&2
      _zsh_init_compinit
      ;;
  esac
}

_zsh_load_post_plugins() {
  local post_manifest=$'zsh-users/zsh-autosuggestions\nzdharma-continuum/fast-syntax-highlighting'

  if ! _zsh_load_antidote_bundle zsh-post "$post_manifest"; then
    [[ -r "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

    if [[ -r "$ZSH_PLUGIN_DIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]]; then
      source "$ZSH_PLUGIN_DIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
    fi
  fi
}

[[ -o interactive ]] && _zsh_load_completion_plugins

if [[ -o interactive && "$ZSH_COMPLETION_STYLE" == autocomplete && ${widgets[menu-select]-} == builtin ]]; then
  autoload -Uz _autocomplete__recent_paths
  zle -C menu-search menu-select _complete
  zle -C recent-paths menu-select _autocomplete__recent_paths
fi

typeset -U path PATH fpath FPATH
path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/bin"
  "$HOME/tools/radiant/2025.1/bin/lin64"
  $path
)

_lazy_source_shell_tool() {
  local init_file="$1"
  shift

  if [[ -o interactive ]]; then
    unset -f "$@"
    [[ -r "$init_file" ]] && source "$init_file"
  fi
}

_load_nvm() {
  _lazy_source_shell_tool "$NVM_DIR/nvm.sh" nvm node npm npx yarn pnpm corepack
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
# TODO: Consider replacing NVM + SDKMAN with mise once project/runtime behavior is settled.


# === SDK MAN ===
export SDKMAN_DIR="$HOME/.sdkman"
_load_sdkman() {
  _lazy_source_shell_tool "$SDKMAN_DIR/bin/sdkman-init.sh" sdk java javac gradle mvn
}

sdk() {
  _load_sdkman
  sdk "$@"
}

java() {
  _load_sdkman
  java "$@"
}

javac() {
  _load_sdkman
  javac "$@"
}

gradle() {
  _load_sdkman
  gradle "$@"
}

mvn() {
  _load_sdkman
  mvn "$@"
}


# === Aliases ===
alias gs='git status'
alias gp='git pull'
alias px4='cd ~/Documents/Mach/px4/'
alias monorepo='cd ~/Documents/Mach/monorepo/'
alias school='cd ~/Documents/School/'
alias prove='cd ~/Documents/Prove/'

case "$OSTYPE" in
  darwin*) alias ls='ls -G' ;;
  *) alias ls='ls --color=auto' ;;
esac
alias l='ls -lah'
case "$OSTYPE" in
  darwin*) (( $+commands[ggrep] )) && alias grep='ggrep --color=auto' ;;
  *) alias grep='grep --color=auto' ;;
esac

alias please='sudo $(fc -ln -1)'
alias fix='fc -e nvim -1'

if (( $+commands[eza] )); then
  alias ls='eza --icons'
  alias l='eza -lah --icons'
  alias ll='eza -lah --icons'
fi

(( $+commands[bat] )) && alias cat='bat --paging=never'
(( $+commands[lazygit] )) && alias lg='lazygit'

ghostty-shader() {
  "$HOME/.config/ghostty/bin/ghostty-shader" "$@"
}
alias ghostty-plain='ghostty-shader none'
alias ghostty-retro='ghostty-shader retro'
alias ghostty-tft='ghostty-shader tft'
alias ghostty-retro-tft='ghostty-shader retro-tft'
alias ghostty-retro-bloom='ghostty-shader retro-tft-bloom'

_zsh_set_cursor_for_keymap() {
  case "$KEYMAP" in
    vicmd) print -n -- $'\e[1 q' ;; # block
    viins|main|'') print -n -- $'\e[5 q' ;; # beam
  esac
}
if [[ -o interactive ]]; then
  zle -N zle-keymap-select _zsh_set_cursor_for_keymap
  _zsh_set_cursor_for_keymap
fi

# === Starship ==
if [[ -o interactive ]] && (( $+commands[starship] )); then
  eval "$(starship init zsh)"
elif [[ -o interactive ]]; then
  PROMPT='%F{cyan}%~%f %# '
fi

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
    git clone "$1" "$2"

    local url
    url=$(cd "$1" && git remote get-url origin)
    print "Setting reclone URL to $url. Make sure to ctrl-c if you don't want that."
    read
    (cd "${2:a}" && git remote set-url origin "$url" && git pull)
}

# Save original prompt
PROMPT_NORMAL=$PROMPT

# Define a minimal transient prompt
PROMPT_TRANSIENT='%F{8}> %f'

if [[ -o interactive ]]; then
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
fi

export EDITOR=nvim
export VISUAL=nvim

if [[ -o interactive ]]; then
  autoload -Uz edit-command-line
  zle -N edit-command-line

  # Edit current buffer
  bindkey -M viins '^E' edit-command-line
  bindkey -M vicmd '^E' edit-command-line
fi


# . "$HOME/.local/bin/env"
[[ -o interactive ]] && (( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
setopt INTERACTIVE_COMMENTS

[[ -r "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"

[[ -o interactive ]] && (( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"

[[ -o interactive ]] && _zsh_load_post_plugins
