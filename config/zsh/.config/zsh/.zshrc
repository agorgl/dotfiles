#
# zsh/.zshrc
#

# Set paths for antidote and p10k
export ANTIDOTE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/antidote"
export ANTIDOTE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/antidote-repos"
export POWERLEVEL9K_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/p10k/p10k.zsh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of .zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Configure antidote
zstyle ':antidote:bundle' use-friendly-names 'yes'
zstyle ':antidote:bundle' file "${ZDOTDIR:-$HOME}/.zsh_plugins"
zstyle ':antidote:static' file "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zsh_plugins.zsh"

# Clone antidote if necessary
if [[ ! -d "$ANTIDOTE_DIR" ]]; then
    git clone https://github.com/mattmc3/antidote "$ANTIDOTE_DIR"
fi

# Load antidote
source "${ANTIDOTE_DIR}/antidote.zsh"
antidote load

# To customize prompt, run `p10k configure` or edit $POWERLEVEL9K_CONFIG_FILE
[[ ! -f "$POWERLEVEL9K_CONFIG_FILE" ]] || source "$POWERLEVEL9K_CONFIG_FILE"

# Prompt
#autoload -Uz promptinit; promptinit
#prompt redhat

# Keymode
bindkey -e

# Interactive
[[ -f ~/.config/shell/interactive ]] && . ~/.config/shell/interactive
