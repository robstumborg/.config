# interactive check — bail early for non-interactive shells
case $- in
  *i*) ;;
  *) return;;
esac

# history
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
HISTTIMEFORMAT="%F %T "
shopt -s histappend

# misc shell options
shopt -s checkwinsize
shopt -s globstar
shopt -s cdspell

# color ls
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
fi

# bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# aliases
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# env
export EDITOR="nvim"
export VISUAL="nvim"
export LESS="-R"
export GPG_TTY=$(tty)

# path
export BUN_INSTALL="$HOME/.bun"
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$BUN_INSTALL/bin:/opt/nvim-linux-x86_64/bin:$PATH"

alias g='git'

# fzf
eval "$(fzf --bash)"

# vi mode
set -o vi

# prompt — pure-style, two lines
__set_ps1() {
  local last_exit=$?
  local reset='\[\e[0m\]'
  local cyan='\[\e[38;5;111m\]'    # path (tokyo night blue)
  local gray='\[\e[38;5;241m\]'    # git branch
  local magenta='\[\e[38;5;141m\]' # prompt symbol (tokyo night purple)
  local red='\[\e[38;5;203m\]'     # prompt symbol on error

  # git info
  local git_info=""
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    local dirty=""
    [ -n "$(git status --porcelain 2>/dev/null)" ] && dirty="*"
    git_info=" ${gray}${branch}${dirty}${reset}"
  fi

  # prompt symbol color based on last exit code
  local sym_color="$magenta"
  [ "$last_exit" -ne 0 ] && sym_color="$red"

  PS1="\n${cyan}\w${reset}${git_info}\n${sym_color}❯${reset} "
}

PROMPT_COMMAND='__set_ps1'
