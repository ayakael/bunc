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
#   _color <command> [<color>]
# 
# COMMAND
#   fg
#       Sets foreground to defined color
#
#   bfg
#       Set foreground to bold and defined color
#
#   bg
#       Sets background to defined color
#
#   rs
#       Resets text to terminal default
#
# COLOR
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
# }

cmdoptArray=(fg bfg bg rs)
coloptArray=(blk red grn yel blu mag cyn gry)

_color_to_ansi() {
    COL=${1}
    for no in {0..7}; do
        if [ "${COL}" == "${coloptArray[${no}]}" ]; then
            echo $(( ${no} + 30 ))
        fi
    done 
}
_color() {
    CMD=${1}
    COL=${2}

    # Sanity check for COMMAND argument
    for cmdopt in ${cmdoptArray[@]}; do
        if [ "${cmdopt}" == "${CMD}" ]; then
            CMD_EXIST=true
        fi
    done
    if ! ${CMD_EXIST}; then
        _msg ECHO "_color(): ${CMD} not a command"
    fi

    # Sanity check for COLOR argument
    for colopt in ${coloptArray[@]}; do
        if [ "${colopt}" == "${COL}" ]; then
            OPT_EXIT=true
        fi
    done
    if ! ${OPT_EXIT}; then
        _msg ECHO "_color(): ${COL} not a color"
    fi

    # Converts color to associated ANSI value
    ANSI="$(_color_to_ansi ${COL})"

    case ${CMD} in
        bfg)
            BOLD="1;"
        ;;

        bg)
            ANSI=$(( ${ANSI} + 10 ))
        ;;
        
        rs)
            ANSI=0
        ;;
    esac

    echo -e "\033[${BOLD}${ANSI}m"
}
