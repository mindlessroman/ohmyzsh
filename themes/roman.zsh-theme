 # current time with milliseconds
current_time() {
  echo "%*"
}

directory() {
  echo "\ue5fe"
}

newline_prompt(){
  echo "\n\uf061"
}

toggle_panel(){
  # git stuff!
  is_git_dir=$(git status 2>&1)
  git_toggle=""

  if [[ "$is_git_dir" == "fatal: not a git repository (or any of the parent directories): .git" ]]
  then
    git_toggle="\uf204"
  else
    git_toggle="\uf205"
  fi

  # node stuff!
  npm_version=$(nvm current | ggrep -Pio "(?<=v)(\d+\.\d+)")

  # python!
  python_version=$(python3 --version | ggrep -Pio "(?<=Python )(\d+\.\d+)")

  #virtual env
  venv_name=$(virtualenv_prompt_info)
  venv_active=""

  if [[ -n $venv_name ]]; then
    venv_active="\uf26c"
  else
    venv_active="\ufd39"
  fi

  echo "(%F{167}\uf1d3%f ${git_toggle}  %F{191}\ue718%f ${npm_version} %F{184}\uf820%f ${python_version} %F{170}${venv_active}%f ${venv_name})"

}

# needs gnu grep - 'brew install grep'
custom_git_prompt(){

  is_git_dir=$(git status 2>&1)
  branch=''
  ZSH_THEME_GIT_PROMPT_PREFIX=''

  if [[ "$is_git_dir" != "fatal: not a git repository (or any of the parent directories): .git" ]]
  then
    detached_head=$(git status | egrep "^HEAD detached at" | wc -l | xargs)
    rebasing=$(git status | egrep "^interactive rebase in progress" | wc -l | xargs)
    merge_conflict_artifacts_unstaged_open=$(git diff | egrep "<<<<" | wc -l | xargs)
    merge_conflict_artifacts_unstaged_closed=$(git diff | egrep ">>>>" | wc -l | xargs)
    merge_conflict_artifacts_staged_open=$(git diff --staged | egrep "<<<<" | wc -l | xargs)
    merge_conflict_artifacts_staged_closed=$(git diff --staged | egrep ">>>>" | wc -l | xargs)
    nothing_to_commit=$(git status | ggrep -Pio "nothing to commit" | wc -l | xargs)

    if [[ $detached_head > 0 ]]; then
      branch=$(git status | ggrep -Pio "(?<=HEAD detached at )(\S+)")
      # Surround with warnings \uf071 and flames (\ue0c2, \ue0c0)
      ZSH_THEME_GIT_PROMPT_PREFIX=" %F{001}\ue0c2 %f%K{001} \uf071  $branch \uf071 %k%F{001}\ue0c0%f "
    elif [[ $rebasing > 0 ]]; then
      # Surround with fast forward \ufbd0
      ZSH_THEME_GIT_PROMPT_PREFIX=" %F{001}\ue0c2 %f%K{001} \ufbd0 REBASING \ufbd0 %k%F{001}\ue0c0%f "
    else
      branch=$(git symbolic-ref --short HEAD 2> /dev/null)
      # Surround with aesthetic hexagons
      ZSH_THEME_GIT_PROMPT_PREFIX=" %F{032}\ufbdf %f%K{032} $branch %k%F{032} \ufbdf%f"
    fi

    # Separate with a neutral arrow in a circle
    prompt_so_far="\n $ZSH_THEME_GIT_PROMPT_PREFIX \uf558"

    # grab some numbers to signal changes thus far
    num_added=$(git status -s | egrep "^A" | wc -l | xargs)
    num_modified=$(git status -s | egrep "^ M" | wc -l | xargs)
    num_untracked=$(git status -s | egrep "^\?\?" | wc -l | xargs)
    num_in_progress=$(git status -s | egrep "^AM" | wc -l | xargs)
    num_edited=$(git status -s | egrep "^MM" | wc -l | xargs)
    num_staged=$(git status -s | egrep "^M " | wc -l | xargs)
    num_renamed=$(git status -s | egrep "^R" | wc -l | xargs)
    num_deleted_confirmed=$(git status -s | egrep "^D " | wc -l | xargs)
    num_deleted_unconfirmed=$(git status -s | egrep "^ D" | wc -l | xargs)

    # Show off the counts of different statuses
    if [[ $merge_conflict_artifacts_unstaged_open > 0 || $merge_conflict_artifacts_unstaged_closed > 0 ]];
    then
      # f9e6 is a synching symbol with an exclamation mark - orange if unstaged
      prompt_so_far="$prompt_so_far %K{166} \uf9e6%k"
    fi
    if [[ $merge_conflict_artifacts_staged_open > 0 || $merge_conflict_artifacts_staged_closed > 0 ]];
    then
      # f9e6 is a synching symbol with an exclamation mark - red if staged
      prompt_so_far="$prompt_so_far %K{196} \uf9e6%k"
    fi
    if [[ $num_added > 0 ]];
    then
      # f055 is a plus sign
      ZSH_THEME_GIT_PROMPT_ADDED="%F{046}\uf055 \ue0b6%f%K{046}%F{232}$num_added%f%k%F{046}\ue0b4%f"
      prompt_so_far="$prompt_so_far $ZSH_THEME_GIT_PROMPT_ADDED"
    fi
    if [[ $num_in_progress > 0 ]];
    then
      # fc23 is a tilde
      prompt_so_far="$prompt_so_far %F{215}\ufc23 \ue0b6%f%K{215}%F{232}$num_in_progress%f%k%F{215}\ue0b4%f"
    fi
    if [[ $num_edited > 0 ]];
    then
      # fc23 is a tilde
      prompt_so_far="$prompt_so_far %F{215}\ufc23 \ue0b6%f%K{215}%F{232}$num_edited%f%k%F{215}\ue0b4%f"
    fi
    if [[ $num_staged > 0 ]];
    then
      # f135 is a rocket - get it, like a launchpad
      prompt_so_far="$prompt_so_far %F{120}\uf135 \ue0b6%f%K{120}%F{232}$num_staged%f%k%F{120}\ue0b4%f"
    fi
    if [[ $num_renamed > 0 ]];
    then
      # f0cc is an S with a strikethrough
      prompt_so_far="$prompt_so_far %F{122}\uf0cc \ue0b6%f%K{122}%F{232}$num_renamed%f%k%F{122}\ue0b4%f"
    fi
    if [[ $num_deleted_unconfirmed > 0 ]];
    then
      # fbca is a open trashcan
      ZSH_THEME_GIT_PROMPT_MODIFIED="%F{203}\ufbca \ue0b6%f%K{203}$num_deleted_unconfirmed%k%F{203}\ue0b4%f"
      prompt_so_far="$prompt_so_far $ZSH_THEME_GIT_PROMPT_MODIFIED"
    fi
    if [[ $num_deleted_confirmed > 0 ]];
    then
      # f48e is a closed trashcan
      ZSH_THEME_GIT_PROMPT_MODIFIED="%F{203}\uf48e \ue0b6%f%K{203}$num_deleted_confirmed%k%F{203}\ue0b4%f"
      prompt_so_far="$prompt_so_far $ZSH_THEME_GIT_PROMPT_MODIFIED"
    fi
    if [[ $num_modified > 0 ]];
    then
      # f044 is an pencil on a square
      ZSH_THEME_GIT_PROMPT_MODIFIED="%F{196}\uf044 \ue0b6%f%K{196}$num_modified%k%F{196}\ue0b4%f"
      prompt_so_far="$prompt_so_far $ZSH_THEME_GIT_PROMPT_MODIFIED"
    fi
    if [[ $num_untracked > 0 ]];
    then
      # f79f is a ghost
      ZSH_THEME_GIT_PROMPT_UNTRACKED="%F{141}\uf79f \ue0b6%f%K{141}$num_untracked%k%F{141}\ue0b4%f"
      prompt_so_far="$prompt_so_far $ZSH_THEME_GIT_PROMPT_UNTRACKED"
    fi
    if [[ $nothing_to_commit > 0 ]];
    then
      prompt_so_far="$prompt_so_far %F{074}\uf46a \uf087%f"
    fi
    prompt_so_far="$prompt_so_far"
    echo $prompt_so_far
  fi
}

# Make the prompt!
PROMPT='%F{038}♥%f %F{075}%n%f in %F{227}$(directory)%f %F{225}%0~%f $(toggle_panel)$(custom_git_prompt)$(newline_prompt) '
RPROMPT='[%K{195}%F{232}$(current_time)%f%k]'
