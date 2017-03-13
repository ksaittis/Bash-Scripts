#!/bin/bash
TYPE=${1:-vtw}
COLUMNS=$(tput cols)
# set -x

source ./repos

makeline()
{
    printf "#%$((COLUMNS-1))s" " " | tr " " =
}

choose_repos()
{
    if [ $TYPE = vtw ]; then
        repos=( ${vtw_repos[@]} )
    elif [ $TYPE = auto ]; then
        repos=( ${auto_repos[@]} )
    fi
}


pull_repos()
{
    for repo in ${repos[@]}; do
        makeline
        echo "# Updating ${repo^^}"
        # git pull &
        makeline
    done
}

__main__()
{
    choose_repos
    pull_repos
}

__main__
