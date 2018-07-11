#!/bin/bash

_git_branch_name() {
    echo "$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')"
}

_is_git_dirty() {
    echo $(git status -s --ignore-submodules=dirty)
}

_is_git_repo() {
    [ -d .git ]
}

_hg_branch_name() {
    echo $(hg branch ^/dev/null)
}

_is_hg_dirty() {
    echo $(hg status -mard)
}

_is_hg_repo() {
    [ -d .hg ]
}

_repo_branch_name() {
    echo "$(_$1_branch_name)"
}

_is_repo_dirty() {
    echo "$(_is_$1_dirty)"
}

_repo_type() {
    if _is_hg_repo; then
        echo 'hg'
    elif _is_git_repo; then
        echo 'git'
    fi
}

prompt() {
    arrow="➜ "
    if [ $USER = 'root' ]; then
       arrow="# "
    fi

    cwd=$(basename $PWD)
    repo_type=$(_repo_type)

    if [ $repo_type ]; then
        repo_branch=$(_repo_branch_name $repo_type)
        repo_info="$repo_type:($repo_branch)"
    fi
    if [ $repo_type ] && [ "$(_is_repo_dirty $repo_type)" ]; then
        dirty=" ✗"
        repo_info="$repo_info$dirty"
    fi

    echo "$arrow $cwd $repo_info "
}
