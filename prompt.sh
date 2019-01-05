#!/usr/bin/env bash

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

#colors
bl="$(tput setaf 4)";
wh="$(tput setaf 7)";
yl="$(tput setaf 3)";
rd="$(tput setaf 1)";
cy="$(tput setaf 6)";
rs="$(tput sgr0)";

_arrow() {
    if [ $USER = 'root' ]; then
        echo "$rd # "
    else
        echo "$rd ➜ "
    fi
}

_cwd() {
    if [ $PWD = $HOME ]; then
        echo "$bl~"
    else
        echo "$bl$(basename $PWD)"
    fi
}

_repo_info() {
    repo_type=$(_repo_type)
    if [ $repo_type ]; then
        repo_branch=$(_repo_branch_name $repo_type)
        repo_info="$cy$repo_type:($rd$repo_branch$cy)"
    fi
    if [ $repo_type ] && [ "$(_is_repo_dirty $repo_type)" ]; then
        dirty="$yl ✗"
        repo_info="$repo_info$dirty"
    fi
    echo $repo_info
}

prompt() {
    echo "\[\$(_arrow) \$(_cwd) \$(_repo_info)\] $rs"
}
