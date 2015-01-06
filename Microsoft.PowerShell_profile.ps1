# Git functions
# Mark Embling (http://www.markembling.info/)
 
# Is the current directory a git repository/working copy?
function isCurrentDirectoryGitRepository {
    if ((Test-Path ".git") -eq $TRUE) {
        return $TRUE
    }
    
    # Test within parent dirs
    $checkIn = (Get-Item .).parent
    while ($checkIn -ne $NULL) {
        $pathToTest = $checkIn.fullname + '/.git'
        if ((Test-Path $pathToTest) -eq $TRUE) {
            return $TRUE
        } else {
            $checkIn = $checkIn.parent
        }
    }
    
    return $FALSE
}
 
# Get the current branch
function gitBranchName {
    $currentBranch = ''
    git branch | foreach {
        if ($_ -match "^\* (.*)") {
            $currentBranch += $matches[1]
        }
    }
    return $currentBranch
}
 
# Extracts status details about the repo
function gitStatus {
    $untracked = $FALSE
    $added = 0
    $modified = 0
    $deleted = 0
    $ahead = $FALSE
    $aheadCount = 0
    
    $output = git status
    
    $branchbits = $output[0].Split(' ')
    $branch = $branchbits[$branchbits.length - 1]

    $output | foreach {
        if ($_ -match "^\#.*origin/.*' by (\d+) commit.*") {
            $aheadCount = $matches[1]
            $ahead = $TRUE
        }
        elseif ($_ -match "deleted:") {
            $deleted += 1
        }
        elseif (($_ -match "modified:") -or ($_ -match "renamed:")) {
            $modified += 1
        }
        elseif ($_ -match "new file:") {
            $added += 1
        }
        elseif ($_ -match "Untracked files:") {
            $untracked = $TRUE
        }
    }
    if (($deleted -gt 0) -or ($modified -gt 0) -or ($added -gt 0)) {
      $dirty = $TRUE
    }
    
    return @{"untracked" = $untracked;
             "added" = $added;
             "modified" = $modified;
             "deleted" = $deleted;
             "ahead" = $ahead;
             "aheadCount" = $aheadCount;
             "branch" = $branch
             "dirty" = $dirty}
}

function getTimeInformation {
  $now = [int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-UFormat %s))
  $lastCommit = git log --pretty=format:'%at' -1
  $difference = $now - $lastCommit
  $minutes = $difference / 60
  $hours = $difference / 3600

  $days = [int]($difference / 86400)
  $subHours = [Math]::Floor([decimal]($hours % 24))
  $subMinutes = [Math]::Floor([decimal]($minutes % 60))

  $timeSinceCommit = "" + [string]$days + 'd' + [string]$subHours + 'h' + [string]$subMinutes + 'm'

  return @{"minutes" = $minutes;
           "hours" = $hours;
           "days" = $days;
           "subMinutes" = $subMinutes;
           "subHours" = $subHours; 
           "timeSinceCommit" = $timeSinceCommit}
}

function prompt
{
  $userName = $env:USERNAME
  $domainName = [System.Environment]::MachineName

  $path = ""
  $pathbits = ([string]$pwd).split("\", [System.StringSplitOptions]::RemoveEmptyEntries)
  if($pathbits.length -eq 1) {
    $path = $pathbits[0] + "\"
  } else {
    $path = $pathbits[$pathbits.length - 1]
  }

  Write-Host($userName) -NoNewline -ForegroundColor Magenta
  Write-Host(" at ") -NoNewline -ForegroundColor Gray
  Write-Host($domainName) -NoNewline -ForegroundColor Yellow
  Write-Host(" in ") -NoNewline -ForegroundColor Gray
  Write-Host($path) -NoNewline -ForegroundColor Cyan

  if (isCurrentDirectoryGitRepository) {
        $status = gitStatus
        $currentBranch = $status["branch"]
        $timeInformation = getTimeInformation
        $timeFromLastCommit = $timeInformation["timeSinceCommit"]

        Write-Host(" on ") -nonewline -foregroundcolor Gray
        Write-Host($currentBranch) -NoNewline -ForegroundColor DarkCyan
        Write-Host(" (") -NoNewline -ForegroundColor Gray

        if ($status["dirty"]) {
          if ([int]($timeInformation["minutes"]) -gt 60) {
              Write-Host($timeFromLastCommit) -NoNewline -ForegroundColor Red
          }elseif ([int]($timeInformation["minutes"]) -gt 20) {
              Write-Host($timeFromLastCommit) -NoNewline -ForegroundColor Yellow
          }else {
              Write-Host($timeFromLastCommit) -NoNewline -ForegroundColor DarkGreen
          }
        } else {
          Write-Host($timeFromLastCommit) -NoNewline -ForegroundColor DarkCyan
        }
        Write-Host(") ") -NoNewline -ForegroundColor Gray

        if ($status["dirty"]) {
          Write-Host(" (*)") -NoNewline -ForegroundColor Red
        } else {
          if ($status["ahead"]) {
            Write-Host(" (") -NoNewline -ForegroundColor Gray
            Write-Host("ϟ") -NoNewline -ForegroundColor Yellow
            Write-Host(")") -NoNewline -ForegroundColor Gray
          }
        }
    }
  Write-Host("")
  Write-Host(">") -NoNewline -ForegroundColor DarkCyan
  " "
}
function gitCheckout {git checkout $args}
Set-Alias gco gitCheckout

function gitStatusAlias {git status $args}
Set-Alias gst gitStatusAlias

function gitCommit {git commit -v $args}
Set-Alias gct gitCommit

function gitAdd {git add $args}
Set-Alias ga gitAdd

function gitAddAll {git add --all $args}
Set-Alias gaa gitAddAll

function gitBranch {git branch $args}
Set-Alias gb gitBranch

function gitPush {git push $args}
Set-Alias gph gitPush

function gitMerge {git merge $args}
Set-Alias gmg gitMerge

function gitPull {git pull $args}
Set-Alias gpl gitPull