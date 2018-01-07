#!/bin/bash

# doc if {
#
# NAME
#   if
# 
# DESCRIPTION
#   A collection of special if functions
# 
# USAGE
#  <function> <arg>
#
# FUNCTIONS
#   _array_contains <var>" "<Array[@]>"
#       Checks if variable exists in array 
# 
#   _is_integer <var>
#       Checks if variable is integer
# EXIT VALUES
#   0    Check succesful
#   1    Check failed
#
# }

_if_array_contains() {
    local i=${1}; shift
    local eArray=(${@})

    for e in ${eArray[@]}; do
        [[ "${e}" = "${i}" ]] && return 0
    done 
    return 1 
}

_if_is_integer () {
    local iArray=(${@})
    for i in ${iArray[@]}; do [[ ${i} =~ ^-?[0-9]+$ ]] && return 0; done
    return 1
}

_if_is_defined () {
   [[ ! ${!1} && ${!1-_} ]] && {
        echo "$1 is not set, aborting." >&2
        exit 1
    }
}

_if_has_value () {
    if is_defined $1; then
        if [[ -n ${!1} ]]; then
            return 0
        fi
    fi
    return 1
}

