#!/bin/bash

STDERR=$(mktemp /tmp/STDERR.XXXXXXXXXX)

function log {
		if [ ${1} = "INDENT" ]; then
			if [ -z "${1}" ]; then
				INDENT="0"
			else
				shift
				INDENT=$((${INDENT} ${1} *6 ))
			fi
		elif [ ${1} = "EXEC" ]; then
			shift
			echo -en "$(tput cuf "${INDENT}") [      ] ${1}\n"
		elif [ ${1} = "OK" ]; then
			if [ -z "${2}" ]; then
				HEIGHT=1
			else
				HEIGHT=$(( ${2} + 1))
			fi
			echo -en "$(tput cuu "${HEIGHT}")$(tput cuf "${INDENT}") [$(tput bold)$(tput setaf 2)  OK  $(tput sgr0)]$(tput cub 100)$(tput cud "${HEIGHT}")"
		elif [ ${1} = "WARN" ]; then
			shift;
			if [ -z "${2}" ]; then
				HEIGHT=1
			else
				HEIGHT=$(( ${2} + 1))
			fi
			echo -en "$(tput cuu "${HEIGHT}")$(tput cuf "${INDENT}") [$(tput bold)$(tput setaf 3) WARN $(tput sgr0)]"
			echo -en "\n$(tput cuf "${INDENT}") [>>>>>>] ${1} \n"
			if [ -n "${STDERR}" ]; then
				cat ${STDERR}
			fi
			rm ${STDERR}
			STDERR=$(mktemp /tmp/STDERR.XXXXXXXXXX)
			echo -en "$(tput cub 100)$(tput cud "${HEIGHT}")"
		elif [ ${1} = "FAIL" ]; then
			shift;
			if [ -z "${2}" ]; then
				HEIGHT=1
			else
				HEIGHT=$(( ${2} + 1))
			fi
			echo -en "$(tput cuu "${HEIGHT}")$(tput cuf "${INDENT}") [$(tput bold)$(tput setaf 1) FAIL $(tput sgr0)]"
			echo -en "\n$(tput cuf "${INDENT}") [>>>>>>] ${1} \n"
			if [ -n "${STDERR}" ]; then
				cat ${STDERR}
			fi
			rm ${STDERR}
			STDERR=$(mktemp /tmp/STDERR.XXXXXXXXXX)
			echo -en "$(tput cuf "${INDENT}") [      ] Fatal error reported. Press any key to shutdown." 
			read -n 1 -s
			echo -en "$(tput cub 100)$(tput cuf "${INDENT}") ["
			TIME=3
			while [ ${TIME} -ne 0 ]; do
				sleep 1;
				echo -en "||"
				TIME=$(( ${TIME}-1 ))
			done
			echo -en "\n$(tput cub 100)$(tput cud "${HEIGHT}")"
			exit
		elif [ ${1} = "ECHO" ]; then
			shift
			echo -e "$(tput cuf "${INDENT}") [======] ${1}"
		fi

	}
# vim: filetype=bash
