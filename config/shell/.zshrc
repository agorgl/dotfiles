#!/bin/zsh

# Autocompletion
zmodload zsh/complist
zstyle ':completion:*' menu select

# Fuzzy match mistyped completions
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Options
setopt interactive_comments share_history complete_in_word
setopt correct no_glob_complete c_bases octal_zeroes

# Prompt
autoload -Uz promptinit; promptinit
prompt redhat

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Plugin manager
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi
source "$HOME/.zinit/bin/zinit.zsh"

# Plugins
zinit wait lucid light-mode for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
      zdharma/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions

zinit wait lucid light-mode for \
  atload"bindkey '^P' history-substring-search-up; bindkey '^N' history-substring-search-down" \
      zsh-users/zsh-history-substring-search

# Vi menu completion movement
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Bash-like keys
bindkey "^a"  beginning-of-line
bindkey "^e"  end-of-line
bindkey "^f"  forward-char
bindkey "^b"  backward-char
bindkey "^[f" forward-word
bindkey "^[b" backward-word
bindkey "^[d" kill-word
bindkey "^w"  backward-kill-word
bindkey "^k"  kill-line
bindkey "^u"  backward-kill-line

# History keys
bindkey '^R' history-incremental-search-backward
bindkey "^P" history-substring-search-up
bindkey "^N" history-substring-search-down

# Aliases
alias ls="ls --color=auto"
