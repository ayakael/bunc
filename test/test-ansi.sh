#!/bin/bash
clean() {
	exit
}

source ../lib/msg.sh
source ../lib/ansi.sh
source ../lib/if.sh

# Possible input arrays
# All commands
cmdArray=(lt dn up rt mc sc rc cl cs fg bf bg rs)
# No argument commands
cmdopt_noargArray=(sc rc cl cs rs)
# One argument commands
cmdopt_intArray=(lt dn up rtc)
# Coord only array
cmdopt_coordArray=(mc)
# Color only commands
cmdopt_colorArray=(fg bf bg)
# All colors
coloptArray=(blk red grn yel blu mag cyn gry)

_test_cmd_to_ansi() {
    _msg EXEC "Testing _cmd_to_ansi function"
    cmdArray=(lt dn up rt mc sc rc cl cs fg bf bg rs)
    resultArray=(A B C D H s u K 2J m m m m)
    for no in {0..12}; do
        if ! [ "$(_cmd_to_ansi ${cmdArray[${no}]} ${cmdArray[@]})" == "${resultArray[${no}]}" ]; then 
            _cmd_to_ansi ${cmdArray[${no}]} ${cmdArray[@]} > ${STDERR} 
            _msg FAIL
        fi
    done
    _msg OK
}

_test_color_to_ansi() {
    _msg EXEC "Testing _color_to_ansi function"
    cmdArray=(blk red grn yel blu mag cyn gry)
    resultArray=(30 31 32 33 34 35 36 37)
    for no in {0..7}; do
        if ! [ "$(_color_to_ansi ${cmdArray[${no}]} ${cmdArray[@]})" == "${resultArray[${no}]}" ]; then 
            _color_to_ansi ${cmdArray[${no}]} ${cmdArray[@]} > ${STDERR} 
            _msg FAIL
        fi
    done
    _msg OK
}

_test_arg_to_ansi() {
    _msg EXEC "Testing _arg_to_ansi"
    cmdArray=(fg bf bg up mc rs)
    argArray=(red red red 2 '4:2' ' ')
    coloptArray=(blk red grn yel blu mag cyn gry)
    resultArray=(31 '1;31' 41 2 '4:2' '0')
    for no in {0..5}; do
        if ! [ "$(_arg_to_ansi ${cmdArray[${no}]} ${argArray[${no}]} ${coloptArray[@]})" == "${resultArray[${no}]}" ]; then
            _arg_to_ansi ${cmdArray[${no}]} ${argArray[${no}]} ${coloptArray[@]} > ${STDERR}
            _msg FAIL
        fi
    done
    _msg OK
}

_test_ansi_color() {
    cmdArray=(fg bf bg)
    coloptArray=(blk red grn yel blu mag cyn gry)
    resultArray=('\033[30m' '\033[31m' '\033[32m' '\033[1;33m' '\033[1;34m' '\033[1;35m')
    for cmd in ${cmdArray[@]}; do
        for col in ${coloptArray[@]}; do
            echo "Testing _color $(_ansi ${cmd} ${col})${cmd} ${col}"
        done
    done
}

_msg ECHO "Begin ansi.sh test"
_test_cmd_to_ansi
_test_color_to_ansi
_test_arg_to_ansi
_test_ansi_color
#_msg ECHO "Testing relative cursor commands"
#_msg INDENT +1
#for cmd in lt dn up rt; do
#    _msg ECHO "Testing ${cmd}"    
#    _msg EXEC "Testing sanity check for ${CMD} set at 0 units"
#    if $(_ansi ${cmd} 0 >${STDERR} 2>&1); then
#        _msg OK  
#    else
#       _msg FAIL
#    fi
    
#    _msg EXEC "Testing sanity check for ${CMD} set at no args"
#    if ! $(_ansi ${cmd} >${STDERR} 2>&1) ;then
#        _msg OK
#    else
#        _msg FAIL
#    fi
#
#    _msg EXEC "Testing cursor change for ${CMD} set at 5 units"
#    _ansi ${cmd} 5
#done

#for cmd in fg bfg bg; do
#    for col in blk red grn yel blu mag cyn gry; do
#        echo "Testing _color $(_ansi ${cmd} ${col})${cmd} ${col}$(_ansi rs)"
#    done
#done
_msg ECHO "End color.sh test"

