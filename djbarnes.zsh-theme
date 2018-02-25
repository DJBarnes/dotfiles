# mashup of eastwood, soliah, juanghurtado and antonishen themes with a lot of custom work for RPS1
# by David Barnes

# Color shortcuts
RED=$fg[red]
YELLOW=$fg[yellow]
GREEN=$fg[green]
WHITE=$fg[white]
BLUE=$fg[blue]
RED_BOLD=$fg_bold[red]
YELLOW_BOLD=$fg_bold[yellow]
GREEN_BOLD=$fg_bold[green]
WHITE_BOLD=$fg_bold[white]
BLUE_BOLD=$fg_bold[blue]
RESET_COLOR=$reset_color

# Format for git_prompt_status()
ZSH_THEME_GIT_PROMPT_UNMERGED=" %{$RED%}unmerged"
ZSH_THEME_GIT_PROMPT_DELETED=" %{$RED%}deleted"
ZSH_THEME_GIT_PROMPT_RENAMED=" %{$YELLOW%}renamed"
ZSH_THEME_GIT_PROMPT_MODIFIED=" %{$YELLOW%}modified"
ZSH_THEME_GIT_PROMPT_ADDED=" %{$GREEN%}added"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$WHITE%}untracked"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[blue]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%} (*)%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# Colors vary depending on time lapsed.
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[blue]%}"

# Format for git_prompt_ahead()
ZSH_THEME_GIT_PROMPT_AHEAD=" %{$fg[white]%}(⚡)"

# Format for git_prompt_long_sha() and git_prompt_short_sha()
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="%{$fg[yellow]%}::%{$fg[blue]%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$fg[white]%}"

# disable the default virtualenv prompt change
export VIRTUAL_ENV_DISABLE_PROMPT=1

# method that can be used to search from the current working dir up to root for a file
file_exists_up_search () {
  path=$(pwd)
  while [[ "$path" != "" && ! -e "$path/$1" ]]; do
    path=${path%/*}
  done
  echo "$path"
}

# Secondary prompt settings
rps1_custom_prompt() {

  # Check to see if there is a venv set
  python_venv="${VIRTUAL_ENV##*/}"
  # Check to see if there is a composer.json in the paths to root
  composerPath=$(file_exists_up_search composer.json)

  # Set a needed shell option
  set -o nonomatch

  # Get counts in the current directory for the various file types we are going to consider.
  python_count=`ls -1 *.py 2>/dev/null | wc -l`
  php_count=`ls -1 *.php 2>/dev/null | wc -l`
  javascript_count=`ls -1 *.js 2>/dev/null | wc -l`
  ruby_count=`ls -1 *.rb 2>/dev/null | wc -l`

  # If there are python files or an activated python venv
  if [ $python_count != 0 ] || [[ -n $python_venv ]]; then
    computedRPS1=$(create_python_prompt)
  # Else If there are php files or a composer.json in the paths to root
  elif [ $php_count != 0 ] || [[ -n $composerPath ]]; then
    computedRPS1=$(create_php_prompt)
  # Else if there are ruby files
  elif [ $ruby_count != 0 ]; then
    computedRPS1=$(create_ruby_prompt)
  # Else if there are JavaScript files
  elif [ $javascript_count != 0 ]; then
    computedRPS1=$(create_javascript_prompt)
  # Else we should us the default prompt (PHP for me)
  else
    computedRPS1=$(create_php_prompt)
  fi
  echo $computedRPS1
}

# Method for creating Python prompt
create_python_prompt() {
  if which python &> /dev/null; then
    if [[ -n $python_venv ]]; then
      # Python with virutal env
      computedRPS1="%{$fg[cyan]%}ve%{$reset_color%}:%{$fg[magenta]%}$python_venv%{$reset_color%}/%{$fg[blue]%}py%{$reset_color%}:%{$fg[yellow]%}$(python -V | grep -Eo '[0-9]*\.[0-9]*\.[0-9]*')%{$reset_color%} $EPS1"
    else
      # Python without virtual env
      computedRPS1="%{$fg[blue]%}py%{$reset_color%}:%{$fg[yellow]%}$(python -V | grep -Eo '[0-9]*\.[0-9]*\.[0-9]*')%{$reset_color%} $EPS1"
    fi
  else
    # No Python Found
    computedRPS1="%{$fg[blue]%}py%{$reset_color%}:%{$fg[yellow]%}null%{$reset_color%} $EPS1"
  fi
  echo $computedRPS1
}

# Method for creating PHP prompt
create_php_prompt() {
  if which php &> /dev/null; then
    if [[ -n $composerPath ]] && grep -q laravel "$composerPath/composer.json" && [ -d "$composerPath/vendor" ]; then
      # In a PHP Laravel Project
      laravelVersion=`php $composerPath/artisan --version | grep -Eo '[0-9]*\.[0-9]*\.[0-9]*'`
      computedRPS1="%{$fg_bold[red]%}lara%{$reset_color%}:%{$fg[yellow]%}$laravelVersion%{$reset_color%}/%{$fg_bold[magenta]%}php%{$reset_color%}:%{$fg[red]%}$(php -v | grep -Eo '.{0,20}(cli).' | grep -Eo '[0-9]*\.[0-9]*\.[0-9]*')%{$reset_color%} $EPS1"
    else
      # Plain old PHP
      computedRPS1="%{$fg_bold[magenta]%}php%{$reset_color%}:%{$fg[red]%}$(php -v | grep -Eo '.{0,20}(cli).' | grep -Eo '[0-9]*\.[0-9]*\.[0-9]*')%{$reset_color%} $EPS1"
    fi
  else
    # No PHP Found
    computedRPS1="%{$fg_bold[magenta]%}php%{$reset_color%}:%{$fg[red]%}null%{$reset_color%} $EPS1"
  fi
  echo $computedRPS1
}

# Method for creating Ruby prompt
create_ruby_prompt() {
  if [[ -s ~/.rvm/scripts/rvm ]] ; then
    # Ruby with RVM
    computedRPS1="%{$fg[red]%}rvm%{$reset_color%}:%{$fg[yellow]%}$(~/.rvm/bin/rvm-prompt)%{$reset_color%} $EPS1"
  elif which rbenv &> /dev/null; then
    # Ruby with rbenv
    computedRPS1="%{$fg[red]%}rbenv%{$reset_color%}:%{$fg[yellow]%}$(rbenv version | sed -e 's/ (set.*$//')%{$reset_color%} $EPS1"
  elif which ruby &> /dev/null; then
    # Ruby with Regular Ruby Version
    computedRPS1="%{$fg[red]%}ruby%{$reset_color%}:%{$fg[yellow]%}$(ruby -v | grep -Eo '.{0,20}(cli).' | grep -Eo '[0-9]*\.[0-9]*\.[0-9]*')%{$reset_color%} $EPS1"
  else
    # No Ruby Found
    computedRPS1="%{$fg[red]%}ruby%{$reset_color%}:%{$fg[yellow]%}null%{$reset_color%} $EPS1"
  fi
  echo $computedRPS1
}

# Method for creating JavaScript prompt
create_javascript_prompt() {
  if which node &> /dev/null; then
    # Node with node
    computedRPS1="%{$fg[green]%}node%{$reset_color%}:%{$fg[yellow]%}$(node -v | grep -Eo '[0-9]*\.[0-9]*\.[0-9]*')%{$reset_color%} $EPS1"
  else
    # Node with no node
    computedRPS1="%{$fg[green]%}node%{$reset_color%}:%{$fg[yellow]%}null%{$reset_color%} $EPS1"
  fi
  echo $computedRPS1
}

# Set the RPS1 prompt
RPS1='$(rps1_custom_prompt)'

# old pos was after current_branch for... $(git_prompt_short_sha)
# old pos was before dirty status for...$(git_prompt_status)
git_custom_status() {
  local cb=$(current_branch)
  if [ -n "$cb" ]; then
    echo "%{$reset_color%} on $ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$ZSH_THEME_GIT_PROMPT_SUFFIX $(my_git_time)$(parse_git_dirty)$(git_prompt_ahead)"
  fi
}

function my_git_time() {
  echo "%{$reset_color%}(%{$reset_color%}$(git_time_since_commit)%{$reset_color%})"
}

# Determine the time since last commit. If branch is clean,
# use a neutral color, otherwise colors will vary according to time.
function git_time_since_commit() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    # Only proceed if there is actually a commit.
    if [[ $(git log 2>&1 > /dev/null | grep -c "^fatal: bad default revision") == 0 ]]; then
      # Get the last commit.
      last_commit=`git log --pretty=format:'%at' -1 2> /dev/null`
      now=`date +%s`
      seconds_since_last_commit=$((now-last_commit))

      # Totals
      MINUTES=$((seconds_since_last_commit / 60))
      HOURS=$((seconds_since_last_commit/3600))

      # Sub-hours and sub-minutes
      DAYS=$((seconds_since_last_commit / 86400))
      SUB_HOURS=$((HOURS % 24))
      SUB_MINUTES=$((MINUTES % 60))

      if [[ -n $(git status -s 2> /dev/null) ]]; then
        if [ "$MINUTES" -gt 30 ]; then
          COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG"
        elif [ "$MINUTES" -gt 10 ]; then
          COLOR="$ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM"
        else
          COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT"
        fi
      else
        COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
      fi

      if [ "$HOURS" -gt 24 ]; then
        echo "$COLOR${DAYS}d${SUB_HOURS}h${SUB_MINUTES}m%{$reset_color%}"
      elif [ "$MINUTES" -gt 60 ]; then
        echo "$COLOR${HOURS}h${SUB_MINUTES}m%{$reset_color%}"
      else
        echo "$COLOR${MINUTES}m%{$reset_color%}"
      fi
    else
      COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
      echo "%{$reset_color%}"
    fi
  fi
}

PROMPT='%{$fg[magenta]%}%n%{$reset_color%} at %{$fg[yellow]%}%m%{$reset_color%} in %{$fg[cyan]%}%c% $(git_custom_status)
%{$fg[blue]%}> %{$reset_color%}'
