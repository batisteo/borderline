#!/usr/bin/env bash

__borderline() {

    # Unicode symbols
    readonly triangle=$'\uE0B0'
    readonly EXIT_SYMBOL=$'\u2717'
    readonly GIT_BRANCH_SYMBOL=$'\u2387  '
    readonly GIT_BRANCH_CHANGED_SYMBOL='+'
    readonly GIT_NEED_PUSH_SYMBOL='⇡'
    readonly GIT_NEED_PULL_SYMBOL='⇣'

    __git_info() {
        [ -x "$(which git)" ] || return    # git not found

        local git_eng="env LANG=C git"   # force git output in English to make our work easier
        # get current branch name or short SHA1 hash for detached head
        local branch="$($git_eng symbolic-ref --short HEAD 2>/dev/null || $git_eng describe --tags --always 2>/dev/null)"
        [ -n "$branch" ] || return  # git branch not found

        local marks

        # branch is modified?
        [ -n "$($git_eng status --porcelain)" ] && marks+=" $GIT_BRANCH_CHANGED_SYMBOL"

        # how many commits local branch is ahead/behind of remote?
        local stat="$($git_eng status --porcelain --branch | grep '^##' | grep -o '\[.\+\]$')"
        local aheadN="$(echo $stat | grep -o 'ahead [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
        local behindN="$(echo $stat | grep -o 'behind [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
        [ -n "$aheadN" ] && marks+=" $GIT_NEED_PUSH_SYMBOL$aheadN"
        [ -n "$behindN" ] && marks+=" $GIT_NEED_PULL_SYMBOL$behindN"

        # print the git branch segment without a trailing newline
        printf "$bgB$bW$GIT_BRANCH_SYMBOL$W$bgB$branch$bgB$bW$marks$B$bgC$triangle"
    }

    __venv(){
        if [ -n "$VIRTUAL_ENV" ]; then
            printf "$W$bgY $(basename "$VIRTUAL_ENV")$Y"
            if [ -d .git ]; then
                printf "$bgB$triangle"
            else
                printf "$bgC$triangle"
            fi
        fi
    }

    ps1() {
        if [ ! $? -eq 0 ]; then
            local __exit="$bR$bgC$EXIT_SYMBOL$X"
        fi

        PS1="$(__venv)$X"
        PS1+="$(__git_info)$X"
        PS1+="$bW$bgC \W $X"
        PS1+="$__exit$bC$triangle$X "
    }

    PROMPT_COMMAND=ps1
}

__borderline
unset __borderline
