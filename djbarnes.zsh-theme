# mashup of eastwood, soliah, juanghurtado and antonishen themes
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

# RVM prompt settings
if [[ -s ~/.rvm/scripts/rvm ]] ; then
  RPS1="%{$fg[yellow]%}rvm%{$fg[blue]%}:%{$reset_color%}%{$fg[red]%}\$(~/.rvm/bin/rvm-prompt)%{$reset_color%} $EPS1"
else
  if which rbenv &> /dev/null; then
    RPS1="%{$fg[yellow]%}rbenv%{$fg[blue]%}:%{$reset_color%}%{$fg[red]%}\$(rbenv version | sed -e 's/ (set.*$//')%{$reset_color%} $EPS1"
  fi
fi

# PHP prompt settings
RPS1="%{$fg[yellow]%}php%{$fg[blue]%}:%{$reset_color%}%{$fg[red]%}\$(php -v | grep -Eo '.{0,20}(cli).' | grep -Eo '[0-9]*\.[0-9]*\.[0-9]*')%{$reset_color%} $EPS1"

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
