#/bin/bash

# doc cfg {
#
# NAME
#   cfg
# 
# DESCRIPTION
#   Reads and writes config files delimited by tabs, like fstab, using awk.
# 
# USAGE
#  _cfg <command> <arg>
#
# COMMANDS
#   set-file <path/to/file>
#       Sets path to file
#
#   create <column-names>
#       Creates config file and assigns <column-names>.
#
#   print <column-name> <row-no>
#       Prints value from <column-name> and <row-no>.  
# 
#   change <column-name> <row-no> <value> 
#       Assigns new <value> to <column-name> and <row-no>.
#
#   drop <row|column} {no|name}
#       Drops <row-no> or <column-name>.
#
#   insert <value-for-col1> <value-for-col2> <...>
#       Inserts new row with a value per column. Number of arguments must match number of columns.
#
#   query <conditional>
#       Queries which <row-no(s)> fits the <conditional>.
#   
#
# CONDITIONALS
#   
#   
#    
# EXIT VALUES
#   0   Success
#   1   Syntax or usage error
#   2   File not found
#   3   File already present
#   4   Row or column not found
#   5   Row or column already has value
#
# }

_cfg() {
    # Sanity check and command parser
    [[ ! -z ${1+x} ]] && {_msg ECHO "_cfg(): Expected command"; return 1}
    local cmdList="(set-file create print change drop insert query)"
    local CMD=${1}; shift
    [[ ! _if_array_contains ${CMD} ${cmdList[@]} ]] && {_msg ECHO "_cfg(): Command specified not valid; return 1"}

    # Dispatcher
    _cfg_$(sed 's|-|_|' <<<"${CMD}") ${@}
}

_cfg_column_to_nf() {
    # Argument parser and sanity check
    [[ ! -z ${1+x} ]] && {_msg ECHO "_cfg(): Expected column name"; return 1}
    local COLUMN=${1}

    # Queries list of columns
    local columnList=(all $(awk 'BEGIN {FS="\t"; OFS="\t"}; {if (NR = 0) {print '${0}'}}' ${_CFG_PATH}))
    
    # Checks if queried ${COLUMN} exists
    if [ if ! _if_array_contains ${COLUMN} ${columnList[@]} ]; then
        _msg ECHO "_cfg_column_to_nf(): Column does not exist"
        return 1
    else
        # Finds what NF is associated with ${COLUMN}
        local COUNT=0
        for column ${columnList[@]}; do
            [[ "${COLUMN}" == "${column}" ]] && echo "${COUNT}"
            local COUNT=$(( ${COUNT} + 1 ))
            return 0
        done
    fi
}

_cfg_set_file() {
    # Argument parser and sanity check
    [[ $# != 1 ]] && {_msg ECHO "_cfg_set_file(): Expected 1 argument"; return 1}
    
    # Sets _CFG_PATH globally
    _CFG_PATH="${1}"
    _CFG_TMP_PATH="$(sed 's|\(.*\)\/|\1/.|' <<<"${CFG_PATH}")"
}

_cfg_create() {
    # Argument parser and sanity check
    [[ ! -z ${1+x} ]] && {_msg ECHO "_cfg_create(): Expected argument"; return 1}
    local colList=(${@})

    # Creates config file
    printf "%s\t" ${colList[@]} >> ${_CFG_PATH}
}

_cfg_print() {
    # Argument parser and sanity check
    [[ $# != 2 ]] && {_msg ECHO "_cfg_print(): Expected 2 arguments"; return 1}
    local COLUMN=${1}
    local ROW=${2}

    # Prints row of ${_CFG_PATH}
    awk 'BEGIN {FS="\t"; OFS="\t"}; {if (NR='${ROW}') {print $'$(_cfg_column_to_nf ${COLUMN})'}}' "${_CFG_PATH}"
}

_cfg_change() {
    # Argument parser and sanity check    
    [[ $# != 3 ]] && {_msg ECHO "_cfg_change(): Expected 3 arguments"; return 1}
    local COLUMN=${1}
    local ROW=${2}
    local VALUE=${3}
    [[ ! _if_is_integer ${ROW} ]] && {_msg ECHO "_cfg_change(): Expected integer; return 1"}
    
    # Writes new version of file
    awk 'BEGIN {OFS="\t"}; {if (NR == '${ROW}') {$'$(_cfg_column_to_nf ${COLUMN})'='${VALUE}'} {print $0}}' "${_CFG_PATH}" > ${_CFG_TMP_PATH} && mv ${_CFG_TMP_PATH} ${_CFG_PATH}
    
}

_cfg_drop() {
    # Argument parser and sanity check
    [[ -z $# != 2 ]] && {_msg ECHO "_cfg_drop(): Expected 2 arguments"; return 1}
    local SUBCMD=${1}; shift
    [[ ! _if_array_contains ${SUBCMD} row column ]] && {_msg ECHO "_cfg_drop(): Expected 'row' or 'column' as subcommand"; return 1}

    # Dispatcher
    _cfg_drop_${SUBCMD} ${1}
}

_cfg_drop_row() {
    # Argument parser and sanity check
    local ROW=${1}
    [[ ${ROW} -mt $(awk 'BEGIN {FS="\t"; OFS="\t"}; {print NR}' ${_CFG_PATH}) ]] && {_msg ECHO "_cfg_drop_row(): Row number higher than available"}
    
    # Writes new version of file
    awk 'BEGIN {OFS="\t"}; {if (NR == '${ROW}') {$0="\b") {print $0}}' ${_CFG_PATH} > ${_CFG_TMP_PATH} && mv ${_CFG_TMP_PATH} ${_CFG_PATH}

}

_cfg_drop_column() {
    local COLUMN=${1}
    local NF=$(_cfg_column_to_nf "${COLUMN}")

    # Writes new version of file
    awk 'BEGIN {OFS="\t"}; {$'${NF}'="\b"; print &0}' ${_CFG_PATH} > ${_CFG_TMP_PATH} && mv ${_CFG_TMP_PATH} ${_CFG_PATH}
}
   
_cfg_insert() {
    # Argument parser and sanity check
    local valueList=(${@})
    local COLUMN_NO=$(awk 'BEGIN{OFS="\t"}; {if (NR == 1) {print NF}}' ${_CFG_PATH})
    [[ "${#valueList[@]}" =! "${COLUMN_NO}" ]] && {_msg ECHO "_cfg_insert(): Number of arguments must be equal to ${COLUMN_NO}"; return 1}

    # Write row into file
    printf "%s\t" ${valueList[@]} >> ${_CFG_PATH}
}

_cfg_query() {
    # Argument parser and sanity check
    local CONDITION=${1}
    
    awk 'BEGIN {FS="\t"; OFS="\t"}; {if ('${CONDITION}') {print NR}}' "{_CFG_PATH}"
}
