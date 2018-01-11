#!/bin/bash

# doc msg {
#
# NAME
#   msg
# 
# DESCRIPTION
#   Messaging framework for scripts
# 
# USAGE
#   _msg <command> <arg>
# 
# COMMAND
#   INDENT +/-<unit>
#       Indents string.
#
#   EXEC <message>
#       Prints EXEC line with message
#
#   OK <lines>
#       Updates the status of an EXEC message to OK. Set <lines> when the EXEC
#       status is higher than directly above the current line.
#
#   WARN <message> <lines>
#       Updates the status of an EXEC message to WARN, a non-fatal error. If the
#       output to the warning command redirects to ${STDERR}. it will be
#       outputted. Set <lines> when the EXEC line is higher than directly
#       above the current line.
#
#   FAIL <message> <lines>
#       Updates the status to an EXEC message to FAIL, a fatal error. If the
#       output to the failed command redirects to ${STDERR}, it will be
#       outputted. The bail() function will then be executed, which defaults to
#       returning with an exit code 1, than exits. Set <lines> when the EXEC line 
#       is higher than directly above the current line.
#
#   ECHO <message>
#       Prints a normal message
# }

STDERR=$(mktemp /tmp/STDERR.XXXXXXXXXX)
INDENT=0
bail() {
    return 1
    exit
}

_msg(){
		if [ ${1} = "INDENT" ]; then
			if [ -z "${1}" ]; then
				INDENT="0"
			else
				shift
				INDENT=$((${INDENT} ${1} *6 ))
			fi
		elif [ ${1} = "EXEC" ]; then
			shift
			echo -en "$(_ansi rt "${INDENT}") [      ] ${1}\n"
		elif [ ${1} = "OK" ]; then
			if [ -z "${2}" ]; then
				HEIGHT=1
			else
				HEIGHT=$(( ${2} + 1))
			fi
			echo -en "$(_ansi up "${HEIGHT}")$(_ansi rt "${INDENT}") [$(_ansi bf grn)  OK  $(_ansi rs)]$(_ansi lt 100)$(_ansi dn "${HEIGHT}")"
		elif [ ${1} = "WARN" ]; then
			shift;
			if [ -z "${2}" ]; then
				HEIGHT=1
			else
				HEIGHT=$(( ${2} + 1))
			fi
			echo -en "$(_ansi up "${HEIGHT}")$(_ansi rt "${INDENT}") [$(_ansi bf yel) WARN $(_ansi rs)]"
			echo -en "\n$(_ansi rt "${INDENT}") [>>>>>>] ${1} \n"
			if [ -n "${STDERR}" ]; then
				cat ${STDERR}
			fi
			rm ${STDERR}
			STDERR=$(mktemp /tmp/STDERR.XXXXXXXXXX)
			echo -en "$(_ansi lt 100)$(_ansi dn "${HEIGHT}")"
		elif [ ${1} = "FAIL" ]; then
			shift;
			if [ -z "${2}" ]; then
				HEIGHT=1
			else
				HEIGHT=$(( ${2} + 1))
			fi
			echo -en "$(_ansi up "${HEIGHT}")$(_ansi rt "${INDENT}") [$(_ansi bf red) FAIL $(_ansi rs)]"
			echo -en "\n$(_ansi rt "${INDENT}") [>>>>>>] ${1} \n"
			if [ -n "${STDERR}" ]; then
				cat ${STDERR}
			fi
			rm ${STDERR}
			STDERR=$(mktemp /tmp/STDERR.XXXXXXXXXX)
			echo -en "$(_ansi lt 100)$(_ansi dn "${HEIGHT}")"
			bail
		elif [ ${1} = "ECHO" ]; then
			shift
			echo -e "$(_ansi rt "${INDENT}") [======] ${1}"
		fi

	}
# vim: filetype=bash
