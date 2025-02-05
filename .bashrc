
case $- in
*i*) ;; # interactive
*) return ;; 
esac

# ----------------------- environment variables ----------------------
#                           (also see envx)

export GITUSER="$USER"
export DOWNLOADS="$HOME/Downloads"
export DOTFILES="$HOME/repos/github.com/$GITUSER/dot"
export SNIPPETS="$HOME/repos/github.com/$GITUSER/dot/snippets"
export CLIP_DATA="$HOME/repos/github.com/$GITUSER/cmd-clip/data"
export CLIP_VOLUME=0
export GHREPOS="$HOME/repos/github.com/$GITUSER"
export HELP_BROWSER=lynx
export PICTURES="$HOME/Pictures"

export TERM=xterm-256color
export HRULEWIDTH=73
export EDITOR=vi
export VISUAL=vi
export EDITOR_PREFIX=vi

export PYTHONDONTWRITEBYTECODE=1

test -d ~/.vim/spell && export VIMSPELL=(~/.vim/spell/*.add)

export GOPRIVATE="github.com/$GITUSER/*,gitlab.com/$GITUSER/*"
export GOPATH=~/.local/share/go
export GOBIN=~/.local/bin
export GOPROXY=direct
export CGO_ENABLED=0

# ------------------------------- pager ------------------------------

if test -x /usr/bin/lesspipe; then
  export LESSOPEN="| /usr/bin/lesspipe %s";
  export LESSCLOSE="/usr/bin/lesspipe %s %s";
fi

export LESS_TERMCAP_mb="[35m" # magenta
export LESS_TERMCAP_md="[33m" # yellow
export LESS_TERMCAP_me="" # "0m"
export LESS_TERMCAP_se="" # "0m"
export LESS_TERMCAP_so="[34m" # blue
export LESS_TERMCAP_ue="" # "0m"
export LESS_TERMCAP_us="[4m"  # underline

# ----------------------------- dircolors ----------------------------

if command -v dircolors &>/dev/null; then
  if test -r ~/.dircolors; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
fi

# ------------------------------- path -------------------------------

pathappend() {
  declare arg
  for arg in "$@"; do
    test -d "${arg}" || continue
    PATH=${PATH//:${arg}:/:}
    PATH=${PATH/#${arg}:/}
    PATH=${PATH/%:${arg}/}
    export PATH="${PATH:+"${PATH}:"}${arg}"
  done
}

pathprepend() {
  for ARG in "$@"; do
    test -d "${ARG}" || continue
    PATH=${PATH//:${ARG}:/:}
    PATH=${PATH/#${ARG}:/}
    PATH=${PATH/%:${ARG}/}
    export PATH="${ARG}${PATH:+":${PATH}"}"
  done
}

# override as needed in .bashrc_{personal,private,work}
# several utilities depend on SCRIPTS being in a github repo
export SCRIPTS=~/.local/bin/scripts
mkdir -p "$SCRIPTS" &>/dev/null

# remember last arg will be first in path
pathprepend \
  /usr/local/go/bin \
  ~/.local/bin \
  "$GHREPOS/cmd-"* \
  "$SCRIPTS" 

pathappend \
  /usr/local/opt/coreutils/libexec/gnubin \
  /mingw64/bin \
  /usr/local/bin \
  /usr/local/sbin \
  /usr/local/games \
  /usr/games \
  /usr/sbin \
  /usr/bin \
  /snap/bin \
  /sbin \
  /bin

# ------------------------------ cdpath ------------------------------

export CDPATH=.:\
~/repos/github.com:\
~/repos/github.com/$GITUSER:\
~/repos/github.com/$GITUSER/dot:\
~/repos:\
/media/$USER:\
~

# ------------------------ bash shell options ------------------------

shopt -s checkwinsize
shopt -s expand_aliases
shopt -s globstar
shopt -s dotglob
shopt -s extglob
#shopt -s nullglob # bug kills completion for some
#set -o noclobber

# ------------------------------ history -----------------------------

export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export HISTFILESIZE=10000

set -o vi
shopt -s histappend

# --------------------------- smart prompt ---------------------------

PROMPT_LONG=20
PROMPT_MAX=95

__ps1() {
  local P='$'

  if test -n "${ZSH_VERSION}"; then
    local r='%F{red}'
    local g='%F{black}'
    local h='%F{blue}'
    local u='%F{yellow}'
    local p='%F{yellow}'
    local w='%F{magenta}'
    local b='%F{cyan}'
    local x='%f'
  else
    local r='\[\e[31m\]'
    local g='\[\e[30m\]'
    local h='\[\e[34m\]'
    local u='\[\e[33m\]'
    local p='\[\e[33m\]'
    local w='\[\e[35m\]'
    local b='\[\e[36m\]'
    local x='\[\e[0m\]'
  fi

  if test "${EUID}" == 0; then
    P='#'
    if test -n "${ZSH_VERSION}"; then
      u='$F{red}'
    else
      u=$r
    fi
    p=$u
  fi

  local dir;
  if test "$PWD" = "$HOME"; then
    dir='~'
  else
    dir="${PWD##*/}"
    if test "${dir}" = _; then
      dir=${PWD#*${PWD%/*/_}}
      dir=${dir#/}
    elif test "${dir}" = work; then
      dir=${PWD#*${PWD%/*/work}}
      dir=${dir#/}
    fi
  fi

  local B=$(git branch --show-current 2>/dev/null)
  test "$dir" = "$B" && B='.'
  local countme="$USER@$(hostname):$dir($B)\$ "

  test "$B" = master -o "$B" = main && b=$r
  test -n "$B" && B="$g($b$B$g)"

  if test -n "${ZSH_VERSION}"; then
    local short="$u%n$g@$h%m$g:$w$dir$B$p$P$x "
    local long="$g╔ $u%n$g@%m\h$g:$w$dir$B\n$g╚ $p$P$x "
    local double="$g╔ $u%n$g@%m\h$g:$w$dir\n$g║ $B\n$g╚ $p$P$x "
  else
    local short="$u\u$g@$h\h$g:$w$dir$B$p$P$x "
    local long="$g╔ $u\u$g@$h\h$g:$w$dir$B\n$g╚ $p$P$x "
    local double="$g╔ $u\u$g@$h\h$g:$w$dir\n$g║ $B\n$g╚ $p$P$x "
  fi

  if test ${#countme} -gt "${PROMPT_MAX}"; then
    PS1="$double"
  elif test ${#countme} -gt "${PROMPT_LONG}"; then
    PS1="$long"
  else
    PS1="$short"
  fi
}

PROMPT_COMMAND="__ps1"

# ----------------------------- keyboard -----------------------------

test -n "$DISPLAY" && setxkbmap -option caps:escape &>/dev/null

# ----------------- consistent, lexicographical sort -----------------
#                (seriously, don't use sort without it)

export LC_COLLATE=C

# ------------------------------ aliases -----------------------------
#      (use exec scripts instead, which work from vim and subprocs)

unalias -a
alias '?'=duck
alias '??'=google
alias '???'=bing
alias mkdirisosec='d=$(isosec);mkdir $d; cd $d'
alias dot='cd $DOTFILES'
alias scripts='cd $SCRIPTS'
alias snippets='cd $SNIPPETS'
alias ls='ls -h'
alias free='free -h'
alias df='df -h'
alias chmox='chmod +x'
alias sshh='sshpass -f $HOME/.sshpass ssh '
alias temp='cd $(mktemp -d)'
alias view='vi -R' # which is usually linked to vim
alias c='printf "\e[H\e[2J"'
alias clear='printf "\e[H\e[2J"'
alias coin="clip '(yes|no)'"

which vim &>/dev/null && alias vi=vim

# ----------------------------- functions ----------------------------

envx() {
  local envfile="$1"
  if test ! -e "$envfile" ; then
    if test ! -e ~/.env ; then
      echo "file not found: $envfile"
      return
    fi
    envfile=~/.env
  fi
  while IFS=$'\n' read -r line; do
    name=${line%%=*}
    value=${line#*=}
    if [[ -z "${name}" || $name =~ ^# ]]; then
      continue
    fi
    export "$name"="$value"
  done <"${envfile}"
} && export -f envx

test -e ~/.env && envx ~/.env 

newcmdbox() { 
  name="$1"
  test -z "$name" && echo "usage: newcmdbox <name>" && return 1
  test -z "$GHREPOS" && echo "GHREPOS not set" && return 1
  test ! -d "$GHREPOS" && echo "Not found: $GHREPOS" && return 1
  test -e "cmdbox-$name" && echo "exists: cmdbox-$name" && return 1
  cd "$GHREPOS"
  gh repo create -p rwxrob/template-cmdbox "cmdbox-$name"
  cd "cmdbox-$name"
} && export -f newcmdbox

newcmd() { 
  name="$1"
  test -z "$name" && echo "usage: newcmd <name>" && return 1
  test -z "$GHREPOS" && echo "GHREPOS not set" && return 1
  test ! -d "$GHREPOS" && echo "Not found: $GHREPOS" && return 1
  test -e "cmd-$name" && echo "exists: cmd-$name" && return 1
  cd "$GHREPOS"
  gh repo create -p rwxrob/template-bash-command "cmd-$name"
  cd "cmd-$name"
} && export -f newcmd

# ------------- source external dependencies / completion ------------

owncomp=(
  pdf md zet yt gl kn auth pomo config iam
  sshkey ws ./build build b ./setup clip x
  ./cmd
)

for i in ${owncomp[@]}; do complete -C $i $i; done

type gh &>/dev/null && . <(gh completion -s bash)
type pandoc &>/dev/null && . <(pandoc --bash-completion)
type kubectl &>/dev/null && . <(kubectl completion bash)
type kind &>/dev/null && . <(kind completion bash)
type yq &>/dev/null && . <(yq shell-completion bash)
type helm &>/dev/null && . <(helm completion bash)
type docker &>/dev/null && . ~/.local/share/docker/completion # with d

type k &>/dev/null && complete -o default -F __start_kubectl k

# -------------------- personalized configuration --------------------

test -r ~/.bash_personal && source ~/.bash_personal
test -r ~/.bash_private && source ~/.bash_private
test -r ~/.bash_work && source ~/.bash_work
