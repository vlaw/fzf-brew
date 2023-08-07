#!/usr/bin/env zs

if ! (( $+commands[brew] )); then
    echo 'brew command not found: please install via https://brew.sh/'
    exit
fi

if ! (( $+commands[fzf] )); then
    echo 'fzf command not found: please install via "brew install fzf"'
    exit
fi

FB_FORMULA_PREVIEW='HOMEBREW_COLOR=true brew info {}'
FB_FORMULA_BIND="ctrl-space:execute-silent(brew home {})"
FB_CASK_PREVIEW='HOMEBREW_COLOR=true brew info --cask {}'
FB_CASK_BIND="ctrl-space:execute-silent(brew home --cask {})"

# completion bindings
# function _fzf_complete_brew() {
#     local arguments=$@
#
#     if [[ $arguments == 'brew install --cask'* ]]; then
#         _fzf_complete -m --preview $FB_FORMULA_PREVIEW --bind $FB_FORMULA_BIND -- "$@" < <(brew casks)
#     elif [[ $arguments == 'brew uninstall --cask'* ]]; then
#         _fzf_complete -m --preview $FB_FORMULA_PREVIEW --bind $FB_FORMULA_BIND -- "$@" < <(brew list --cask)
#     elif [[ $arguments == 'brew install'* ]]; then
#         _fzf_complete -m --preview $FB_FORMULA_PREVIEW --bind $FB_FORMULA_BIND -- "$@" < <(brew formulae)
#     elif [[ $arguments == 'brew uninstall'* ]]; then
#         _fzf_complete -m --preview $FB_FORMULA_PREVIEW --bind $FB_FORMULA_BIND -- "$@" < <(brew leaves)
#     else
#         eval "zle ${fzf_default_completion:-expand-or-complete}"
#     fi
# }

# functions

function fuzzy_brew_install() {
    # Usage: brew formulae
    #
    # List all locally installable formulae including short names.
    # (2023-08-07)
    # brew formulae | wc -l # => 6791
    local inst=$(brew formulae | fzf --query="$1" -m --preview $FB_FORMULA_PREVIEW --bind $FB_FORMULA_BIND)

    if [[ $inst ]]; then
        echo ">>> Installing $inst";
        for prog in $(echo $inst); do; brew install $prog; done;
    fi
}

function fuzzy_brew_remove() {
    # Usage: brew leaves [--installed-on-request] [--installed-as-dependency]
    #
    # List installed formulae that are not dependencies of another installed formula
    # or cask.
    local uninst=$(brew leaves | fzf --query="$1" -m --preview $FB_FORMULA_PREVIEW --bind $FB_FORMULA_BIND)

    if [[ $uninst ]]; then
        echo ">>> Uninstalling $uninst";
        for prog in $(echo $uninst); do;
            brew remove $prog;
        done;
    fi
}

function fuzzy_cask_install() {
    # Usage: brew casks
    #
    # List all locally installable casks including short names.
    local inst=$(brew casks | fzf --query="$1" -m --preview $FB_CASK_PREVIEW --bind $FB_CASK_BIND)

    if [[ $inst ]]; then
        echo ">>> Installing $inst";
        for prog in $(echo $inst); do; brew install --cask $prog; done;
    fi
}

function fuzzy_cask_remove() {
    # Usage: brew list, ls [options] [installed_formula|installed_cask ...]
    #
    # List all installed formulae and casks.
    #    --cask, --casks   List only casks, or treat all named arguments as casks.
    local inst=$(brew list --cask | fzf --query="$1" -m --preview $FB_CASK_PREVIEW --bind $FB_CASK_BIND)

    if [[ $inst ]]; then
        echo ">>> Removing $inst";
        for prog in $(echo $inst); do; brew remove --cask $prog; done;
    fi
}

function fuzzy_brew_upgrade(){
    # Usage: brew outdated [options] [formula|cask ...]
    #
    # List installed casks and formulae that have an updated version available. By
    # default, version information is displayed in interactive shells, and suppressed
    # otherwise.
    # 支持formula即可，cask使用单独的扩展
    local outdated=$(brew outdated --formula | fzf --query="$1" --multi --preview $FB_CASK_PREVIEW --bind 'ctrl-a:select-all+accept');

    if [[ -n "$outdated" ]]; then
        echo ">>> Upgrading $outdated";
        for prog in $(echo $outdated);
        do
            brew upgrade $prog;
        done
    fi
}

function __setup_fzf_brew() {
    alias fbi=fuzzy_brew_install
    alias fbr=fuzzy_brew_remove     # r for remove
    alias fbu=fuzzy_brew_upgrade

    alias fci=fuzzy_cask_install
    alias fcr=fuzzy_cask_remove
}

# 好像与fzf-tab冲突了
__setup_fzf_brew
