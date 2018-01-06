#!/bin/bash

# doc color {
#
# NAME
#   color
# 
# DESCRIPTION
#   Sets color variables for easy color change
# 
# USAGE
#   _color <command> [<arg>]
# 
# COMMAND
#   fg <color>
#       Sets foreground to defined color
#
#   bfg <color>
#       Set foreground to bold and defined color
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


cmdoptArray=(fg bfg bg rs)
coloptArray=(blk red grn yel blu mag cyn gry)

_color_to_ansi() {
    local COL=${1}
    for no in {0..7}; do
        if [ "${COL}" == "${coloptArray[${no}]}" ]; then
            echo $(( ${no} + 30 ))
        fi
    done 
}

_color() {
    local CMD=${1}
    local COL=${2}
    # Sanity check for COMMAND argument
    if [ -z ${1+x} ]; then
        _msg ECHO "_color(): Command not defined"
    elif ! _if_array_contains "${CMD}" "${cmdoptArray[@]}"; then
        _msg ECHO "_color(): ${CMD} not a command"
    fi

    # Sanity check for COLOR argument
    [ ! "${CMD}" == "rs" ] && {
        if [ -z ${2+x} ]; then
            _msg ECHO "_color(): Color not defined"
        elif ! _if_array_contains "${COL}" "${coloptArray[@]}"; then
            _msg ECHO "_color(): ${COL} not a color"
        fi
    }

    # Converts color to associated ANSI value
    ANSI="$(_color_to_ansi ${COL})"

    case ${CMD} in
        bfg)
            local BOLD="1;"
        ;;

        bg)
            local ANSI=$(( ${ANSI} + 10 ))
        ;;
        
        rs)
            local ANSI=0
        ;;
    esac

    echo -e "\033[${BOLD}${ANSI}m"
}
