 # current time with milliseconds
current_time() {
   echo "%*"
}

directory() {
   echo "\ue5fe"
}

newline_prompt(){
   echo "\uf061"
}

ZSH_THEME_GIT_PROMPT_RENAMED=''
ZSH_THEME_GIT_PROMPT_DELETED=''
ZSH_THEME_GIT_PROMPT_STASHED=''
ZSH_THEME_GIT_PROMPT_UNMERGED=''

ZSH_THEME_GIT_PROMPT_BEHIND=''
ZSH_THEME_GIT_PROMPT_DIVERGED=' \uf79f \ue0b6'

ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="\uf2cd"
ZSH_THEME_GIT_PROMPT_CLEAN="\ufae2"

custom_git_prompt(){

   is_git_dir=$(git status 2>&1)

   if [[ "$is_git_dir" == "fatal: not a git repository (or any of the parent directories): .git" ]]
   then
      echo "( \uf10c )"
   else
      branch=$(git symbolic-ref --short HEAD 2> /dev/null)
      ZSH_THEME_GIT_PROMPT_PREFIX="\n %F{032}\ue0d4%f%K{032}$branch%k%F{032}\ue0b0%f"

      # grab some numbers
      num_added=$(git status -s | egrep "^A" | wc -l | xargs)
      num_modified=$(git status -s | egrep "^ M" | wc -l | xargs)
      num_untracked=$(git status -s | egrep "^\?\?" | wc -l | xargs)
      num_in_progress=$(git status -s | egrep "^AM" | wc -l | xargs)
      num_staged=$(git status -s | egrep "^M " | wc -l | xargs)
      num_renamed=$(git status -s | egrep "^R" | wc -l | xargs)

      prompt_so_far="$ZSH_THEME_GIT_PROMPT_PREFIX"
      if [[ $num_added > 0 ]];
      then
         ZSH_THEME_GIT_PROMPT_ADDED="%F{046}\uf055 \ue0b6%f%K{046}%F{232}$num_added%f%k%F{046}\ue0b4%f"
         prompt_so_far="$prompt_so_far $ZSH_THEME_GIT_PROMPT_ADDED"
      fi
      if [[ $num_in_progress > 0 ]];
      then
         prompt_so_far="$prompt_so_far %F{215}\ufc23 \ue0b6%f%K{215}%F{232}$num_in_progress%f%k%F{215}\ue0b4%f"
      fi
      if [[ $num_staged > 0 ]];
      then
         prompt_so_far="$prompt_so_far %F{120}\uf135 \ue0b6%f%K{120}%F{232}$num_staged%f%k%F{120}\ue0b4%f"
         # or f102?
      fi
      if [[ $num_renamed > 0 ]];
      then
         prompt_so_far="$prompt_so_far %F{122}\uf040 \ue0b6%f%K{122}%F{232}$num_renamed%f%k%F{122}\ue0b4%f"
      fi
      if [[ $num_modified > 0 ]];
      then
         ZSH_THEME_GIT_PROMPT_MODIFIED="%F{196}\uf00d \ue0b6%f%K{196}$num_modified%k%F{196}\ue0b4%f"
         prompt_so_far="$prompt_so_far $ZSH_THEME_GIT_PROMPT_MODIFIED"
      fi
      if [[ $num_untracked > 0 ]];
      then
         ZSH_THEME_GIT_PROMPT_UNTRACKED="%F{141}\uf27b \ue0b6%f%K{141}$num_untracked%k%F{141}\ue0b4%f"
         prompt_so_far="$prompt_so_far $ZSH_THEME_GIT_PROMPT_UNTRACKED"
      fi
      echo $prompt_so_far
   fi

}

PROMPT='%F{038}♥%f %F{075}%n%f in %F{227}$(directory)%f %F{225}%0~%f $(custom_git_prompt)
 $(newline_prompt) '
RPROMPT='[%K{195}%F{232}$(current_time)%f%k]'
