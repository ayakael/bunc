#!/bin/bash

# doc ansi {
#
# NAME
#   ansi
# 
# DESCRIPTION
#   Sets terminal properties such as cursor position and text color.
# 
# USAGE
#   _ansi <command> [<arg>]
# 
# COMMAND
#   lt <unit>
#       Moves cursor left
#
#   dn <unit>
#       Moves cursor down
#
#   up <unit>
#       Moves cursor up
#
#   rt <unit>
#       Moves cursor right
#
#   mc <column>;<line>
#       Moves cursor to <column> and <line>
#
#   sc
#       Saves cursor position
#
#   rc
#       Restores cursor position
#
#   cl
#       Clears the line
#
#   cs
#       Clears the screen
#
#   fg <color>
#       Sets foreground to defined color
#
#   bf <color>
#       Sets foreground to bold and defined color
#
#   bg <color>
#       Sets background to defined color
#
#   rs
#       Resets text to terminal default
#
# COLORS
#   blk
#       Color black
#
#   red
#       Color red
#
#   grn
#       Color green
#
#   yel
#       Color yellow
#
#   blu
#       Color blue
#
#   mag
#       Color magenta
#
#   cyn
#       Color cyan
#
#   gry
#       Color grey
#
# }


_cmd_to_ansi() {
    local CMD="${1}"; shift
    local cmdoptArray=("${@}")
    local ansiArray=(A B C D H s u K 2J m)

    for no in {0..12}; do
        if [ "${CMD}" == "${cmdoptArray[${no}]}" ]; then
            [[ ${no} -ge 9 ]] && local no=9
            echo ${ansiArray[${no}]}
        fi
    done
}


_color_to_ansi() {
    local COL=${1}; shift
    local coloptArray=(${@})

    for no in {0..7}; do
        if [ "${COL}" == "${coloptArray[${no}]}" ]; then
            echo $(( ${no} + 30 ))
        fi
    done 
}

_arg_to_ansi() {
    local CMD=${1}; shift
    local ARG=${1}; shift
    local coloptArray=(${@})

    if [ "${CMD}" == "bf" ]; then
        echo "1;$(_color_to_ansi ${ARG} ${coloptArray[@]})" 
    elif [ "${CMD}" == "fg" ]; then
        echo "$(_color_to_ansi ${ARG} ${coloptArray[@]})"
    elif [ "${CMD}" == "bg" ]; then
        echo "$(( $(_color_to_ansi ${ARG} ${coloptArray[@]}) + 10 ))"
    elif [ "${CMD}" == "rs" ]; then
        echo "0"
    else
        echo "${ARG}"
    fi
}

_ansi() {
    local CMD=${1}
    local ARG=${2}
    
    # Possible input arrays
    # All commands
    
    local cmdoptArray=(up dn rt lt mc sc rc cl cs fg bf bg rs)
    # No argument commands
    local cmdopt_noargArray=(sc rc cl cs rs)
    # One argument commands
    local cmdopt_intArray=(lt dn up rtc)
    # Coord only array
    local cmdopt_coordArray=(mc)
    # Color only commands
    local cmdopt_colorArray=(fg bf bg)
    # All colors
    local coloptArray=(blk red grn yel blu mag cyn gry)
    

    # cmd content sanity
    if [ -z ${CMD+x} ]; then
        _msg ECHO "_ansi(): Command not defined"
    elif ! _if_array_contains ${CMD} ${cmdoptArray[@]}; then
        _msg ECHO "_ansi(): ${CMD} not a command"
    fi

    # arg quantity sanity
    # no arg commands
    if _if_array_contains ${CMD} ${cmdopt_noargArray[@]}; then
        if [ -z ${ARG+x} ]; then
            _msg ECHO "_ansi(): ${CMD} expected no arguments"
            return 1
        fi
    # 1 arg commands
    elif _if_array_contains ${CMD} ${cmdopt_1argArray[@]}; then
        if [ -z ${ARG+x} ]; then
            _msg ECHO "_ansi(): ${CMD} expected 1 argument"
            return 1
        fi

    # arg content sanity
    # integer commands
    elif _if_array_contains ${CMD} ${cmdopt_intArray[@]}; then
        if ! _if_is_integer ${ARG}; then
            _msg ECHO "_ansi(): ${CMD} expected integer as argument"
            return 1
        fi
    # coord commands
    elif _if_array_contains ${CMD} ${cmdopt_coordArray[@]}; then
        if ! _if_integer $(echo ${ARG} | sed 's|;| |'); then
            _msg ECHO "_ansi(): ${CMD} expected integers as argument"
        fi
    # color commands
    elif _if_array_contains ${CMD} ${cmdopt_colorArray[@]}; then
        if ! _if_array_contains ${ARG} ${coloptArray[@]}; then
            _msg ECHO "_ansi(): ${CMD} expected argument to match ${coloptArray[@]}"
            return 1
        fi
    fi

    echo -e "\033[$(_arg_to_ansi ${CMD} ${ARG} ${coloptArray[@]})$(_cmd_to_ansi ${CMD} ${cmdoptArray[@]})" 

}
