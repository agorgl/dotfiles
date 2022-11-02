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

# Key mode
bindkey -e
export KEYTIMEOUT=1

# Plugin manager
if [[ ! -f $HOME/.zcomet/bin/zcomet.zsh ]]; then
  command git clone https://github.com/agkozak/zcomet.git $HOME/.zcomet/bin
fi
source $HOME/.zcomet/bin/zcomet.zsh

# Plugins
zcomet load romkatv/powerlevel10k
zcomet load zdharma-continuum/fast-syntax-highlighting
zcomet load zsh-users/zsh-history-substring-search
zcomet load zsh-users/zsh-autosuggestions
zcomet load zsh-users/zsh-completions

# Run compinit and compile its cache
zcomet compinit

# Vi menu completion movement
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Home, End and Delete keys
bindkey "^[[H"  beginning-of-line
bindkey "^[[F"  end-of-line
bindkey "^[[3~" delete-char

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
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

# History keys
bindkey '^R' history-incremental-search-backward
bindkey "^P" history-substring-search-up
bindkey "^N" history-substring-search-down

# Aliases
alias ls="ls --color=auto"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
