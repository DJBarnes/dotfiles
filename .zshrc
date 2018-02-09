# Zsh config
ZSH=$HOME/.oh-my-zsh

# Zsh theme
ZSH_THEME="djbarnes"

# Define Oh-My-Zsh plugins
plugins=(git brew osx composer django python pip)

# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# Load non-public .zshrc
if [ -f $HOME/.zshrc-private ]; then
  source $HOME/.zshrc-private
fi

# Allow auto cd-ing
setopt auto_cd

# make <C-s> work in terminal vim
stty -ixon

# ignore duplicate history entries
setopt histignoredups

# Bindings
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line

###################
# Functions
###################

# Check for OS
onLinux () {
  if [[ `uname` == 'Linux' ]]; then
    return true
  # Assuming only used on Linux and Mac so else should be
  # equivalent to an if as follows: [[ `uname` == 'Darwin']]; then
  else
    return false
  fi
}

###################
# Aliases
###################

# directory
alias rm="rm -i"

# git
alias gco="git checkout"
alias gci="git commit -v"
alias grb="git rebase"
alias ga="git add"
alias gaa="git add --all"
alias gap="git add -p"
alias gs="git status"
alias gb="git branch"
alias gd="git diff"
alias gdc="git diff --cached"
alias gl="git l"
alias gll="git ll"
alias gp="git push"
alias gm="git merge"
alias gpl="git pull"
alias gbv="git branch -v"
alias gpr="git remote prune origin"
alias gr="git remote -v"
alias grd="git push origin --delete"
alias gltree="git log --graph --oneline --decorate --all"
alias gbtree="git log --graph --simplify-by-decoration --pretty=format:'%d' --all"

# composer
alias cdump="composer dump-autoload"
alias crequire="composer require"

# laravel
alias art="php artisan"
alias artmig="php artisan migrate"
alias artrol="php artisan migrate:rollback"
alias artseed="php artisan db:seed"

# phpunit
alias pu="./vendor/phpunit/phpunit/phpunit"
alias puf="./vendor/phpunit/phpunit/phpunit --filter"
alias puts="./vendor/phpunit/phpunit/phpunit --testsuite"
alias putc="./vendor/phpunit/phpunit/phpunit --coverage-html ~/tempCoverage"
alias putcf="./vendor/phpunit/phpunit/phpunit --coverage-html ~/tempCoverage --filter"
alias putcts="./vendor/phpunit/phpunit/phpunit --coverage-html ~/tempCoverage --testsuite"
alias pucts="./vendor/phpunit/phpunit/phpunit --coverage-html ~/coverage --testsuite"
alias puc="./vendor/phpunit/phpunit/phpunit --coverage-html ~/coverage"

# python
alias python="python3"
alias py="python"

# OS dependent
if [[ onLinux ]]; then
  # mysql
  alias mmysql='/opt/lampp/bin/mysql'
  alias mmysqldump='/opt/lampp/bin/mysqldump'
  # directory
  alias www='cd /opt/lampp/htdocs'
else
  # mysql
  alias mmysql='/Applications/MAMP/Library/bin/mysql'
  alias mmysqldump='/Applications/MAMP/Library/bin/mysqldump'
  # directory
  alias www='cd /Applications/MAMP/htdocs/'
fi

###################
# PATH additions
###################

# Beginning Appends
PATH=/usr/local/bin:$PATH
PATH=/opt/lampp/bin:$PATH
PATH=/usr/local/share/python:$PATH
PATH=$HOME/.composer/vendor/bin:$PATH

# Ending Appends
PATH=$HOME/.bin:/usr/local/sbin:/usr/local/bin:$PATH
