
alias pico='ssh pico'
alias nicks="s /names"

alias c="printf  $'\033[2J\033[;H'"
alias cl="s /buffer clear"
alias x="exit"
alias sl="sl -e"

wipe() {
  printf  "\033[2J\033[;H"
  wee '/buffer clear'
} && export -f wipe
