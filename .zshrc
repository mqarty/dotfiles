# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 7

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git colored-man-pages colorize pip python zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search dirhistory docker docker-compose aws terraform npm poetry)

source $ZSH/oh-my-zsh.sh

# User configuration

# Load secrets (API keys, tokens, etc.)
if [ -f ~/.zshrc.secrets ]; then
    source ~/.zshrc.secrets
fi

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Enhanced history configuration for devcontainers
if [ -f /.dockerenv ] || [ -n "$REMOTE_CONTAINERS" ]; then
    # We're in a container - use container-specific history with sync
    export HISTFILE="${HISTFILE:-$HOME/.zsh_history_container}"
    export HISTSIZE="${HISTSIZE:-10000}"         # Number of commands to remember in the command history
    export SAVEHIST="${SAVEHIST:-10000}"         # Number of history entries

    # History corruption protection function
    fix_corrupt_history() {
        if [[ -f "$HISTFILE" ]] && ! fc -R "$HISTFILE" 2>/dev/null; then
            echo "🔧 Fixing corrupted history file..."
            # Create backup
            cp "$HISTFILE" "${HISTFILE}.corrupt.$(date +%s)" 2>/dev/null || true
            # Try to salvage what we can
            if command -v strings >/dev/null; then
                strings "$HISTFILE" | grep -v '^$' > "${HISTFILE}.tmp" 2>/dev/null && mv "${HISTFILE}.tmp" "$HISTFILE" 2>/dev/null
            else
                # Fallback: start with fresh history
                echo "# ZSH History - Recovered $(date)" > "$HISTFILE"
            fi
            echo "✅ History file repaired"
        fi
    }

    # Sync function to merge host history (optional)
    sync_host_history() {
        if [[ -f "$HOME/.zsh_history" && -f "$HISTFILE" ]]; then
            echo "🔄 Syncing with host history..."
            # Backup current container history
            cp "$HISTFILE" "${HISTFILE}.pre-sync.$(date +%s)"
            # Try to merge (avoiding corruption)
            {
                cat "$HOME/.zsh_history" 2>/dev/null | strings 2>/dev/null
                cat "$HISTFILE" 2>/dev/null | strings 2>/dev/null
            } | sort -u > "${HISTFILE}.merged" && mv "${HISTFILE}.merged" "$HISTFILE"
        fi
    }

    # Check and fix history on startup
    fix_corrupt_history

    # Option to use separate history for container
    if [ -f "$HOME/.zsh_history_local" ]; then
        export HISTFILE="$HOME/.zsh_history_local"
    fi
else
    # Not in container, use standard history
    export HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
    export HISTSIZE="${HISTSIZE:-50000}"
    export SAVEHIST="${SAVEHIST:-50000}"
fi

# History options
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits
setopt SHARE_HISTORY             # Share history between all sessions
setopt APPEND_HISTORY            # Append to the history file, don't overwrite it
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry
setopt HIST_VERIFY               # Don't execute immediately upon history expansion
setopt HIST_FCNTL_LOCK           # Use fcntl for safer file locking (if available)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias ls='ls -A'

alias gs="git status"
alias gc="git commit"
alias dc="docker compose"
alias tf="terraform"

# History management aliases
alias fix-history='fix_corrupt_history'
alias history-backup='cp "$HISTFILE" "${HISTFILE}.backup.$(date +%Y%m%d_%H%M%S)"'
alias sync-history='sync_host_history'

# Oh My Zsh update alias
alias omz-update='omz update'

# zsh-history-substring-search key bindings
bindkey '^[[A' history-substring-search-up    # UP arrow
bindkey '^[[B' history-substring-search-down  # DOWN arrow
bindkey '^P' history-substring-search-up      # Ctrl+P
bindkey '^N' history-substring-search-down    # Ctrl+N

complete -C '/usr/local/bin/aws_completer' aws

# Enable fzf if installed (fuzzy finder for commands, files, and history)
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:wrap"
fi

# Load pyenv automatically
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

