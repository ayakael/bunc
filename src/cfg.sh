#!/bin/bash

# doc cfg {
#
# NAME
#   cfg
# 
# DESCRIPTION
#   Reads and writes config files delimited by tabs, like fstab, using awk.
# 
# USAGE
#  _cfg <file> <command> <arg> 
#
# COMMANDS
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
#   insert <row|column> <value(s)>
#       Inserts new row or column. Number of row values must match number of columns.
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

_cfg_column_to_nf() {
    # Argument parser and sanity check
    [[ $# != 2 ]] && { _msg ECHO "_cfg_column_to_nf(): Expected 2 arguments"; return 1; }
    local FILE="${1}"
    local COLUMN=${2}

    # Queries list of columns
    local columnList=(all $(awk 'BEGIN {FS="\t"; OFS="\t"}; {if (NR == 1 ) {print $0}}' ${FILE}))
    
    # Checks if queried ${COLUMN} exists
     if ! _if_array_contains ${COLUMN} ${columnList[@]}; then
        _msg ECHO "_cfg_column_to_nf(): Column does not exist"
        return 1
    else
        # Finds what NF is associated with ${COLUMN}
        local COUNT=0
        for column in ${columnList[@]}; do
            [[ "${COLUMN}" == "${column}" ]] && echo "${COUNT}"
            local COUNT=$(( ${COUNT} + 1 ))
        done
        return 0
    fi
}

_cfg_tmp_file() {
    local FILE="${1}"
    
    echo -n "$(dirname ${FILE})/.$(basename ${FILE})"
}

_cfg_create() {
    # Argument parser and sanity check
    [[ $# -lt 2 ]] && { _msg ECHO "_cfg_create(): Expected at least 2 arguments"; return 1; }
    local FILE="${1}"; shift
    local colList=(${@})

    # Creates config file
    printf "%s\t" ${colList[@]} | awk 'BEGIN{OFS="\t";} {printf "%s\n",$0}'  >> ${FILE}
}

_cfg_print() {
    # Argument parser and sanity check
    [[ $# != 3 ]] && { _msg ECHO "_cfg_print(): Expected 3 arguments"; return 1; }
    local FILE="${1}"
    local COLUMN=${2}
    local ROW=${3}

    # Prints row of ${_CFG_PATH}
    awk 'BEGIN {OFS="\t"}; {if (NR == '${ROW}') {print $'$(_cfg_column_to_nf ${COLUMN})'}}' "${FILE}"
}

_cfg_change() {
    # Argument parser and sanity check    
    [[ $# != 4 ]] && { _msg ECHO "_cfg_change(): Expected 4 arguments"; return 1; }
    local FILE="${1}"
    local COLUMN=${2}
    local ROW=${3}
    local VALUE=${4}
    local TMP_FILE=$(_cfg_tmp_file ${FILE})
    local COLUMN_NO=$(_cfg_column_to_nf ${COLUMN})
    _if_is_integer ${ROW} || { _msg ECHO "_cfg_change(): Expected integer"; return 1; }
    [[ ${ROW} > $(awk 'BEGIN{FS="\t"; OFS="\t"}; {print NR}' ${_CFG_PATH} | wc -l) ]] && { _msg ECHO "_cfg_change(): Row ${ROW} does not exist"; return 1; }
    
    # Writes new version of file
    awk 'BEGIN {OFS="\t"}; {if (NR == '${ROW}') {$'${COLUMN_NO}'="'${VALUE}'"} {print $0}}' "${FILE}" > ${TMP_FILE} && mv ${TMP_FILE} ${FILE}
    
}

_cfg_drop() {
    # Argument parser and sanity check
    [[ $# != 3 ]] && { _msg ECHO "_cfg_drop(): Expected 3 arguments"; return 1; }
    local SUBCMD=${1}; shift
    _if_array_contains ${SUBCMD} row column || { _msg ECHO "_cfg_drop(): Expected 'row' or 'column' as subcommand"; return 1; }

    # Dispatcher
    eval _cfg_drop_${SUBCMD} ${@}
}

_cfg_drop_row() {
    # Argument parser and sanity check
    local FILE="${1}"
    local TMP_FILE="$(_cfg_tmp_file ${FILE})"
    local ROW=${2}
    [[ ${ROW} > $(awk 'BEGIN {FS="\t"; OFS="\t"}; {print NR}' ${FILE} | wc -l) ]] && { _msg ECHO "_cfg_drop_row(): Row ${ROW} does not exist"; return 1; }
    
    # Writes new version of file
    awk 'BEGIN {OFS="\t"}; {if (NR != '${ROW}') {print $0}}' ${FILE} > ${TMP_FILE} && mv ${TMP_FILE} ${FILE}

}

_cfg_drop_column() {
    local FILE="${1}"
    local TMP_FILE="$(_cfg_tmp_file ${FILE})"
    local COLUMN=${2}
    local NF=$(_cfg_column_to_nf "${COLUMN}")

    # Writes new version of file
    awk 'BEGIN {OFS="\t"}; $'${NF}'="";1' ${FILE} > ${TMP_FILE} && mv ${TMP_FILE} ${FILE}
}
 
_cfg_insert() {
    # Argument parser and sanity check
    local SUBCMD=${1}; shift
    _if_array_contains ${SUBCMD} row column || { _msg ECHO "_cfg_insert(): Expected 'row' or 'column' as subcommand"; return 1; }

    # Dispatcher
    eval _cfg_insert_${SUBCMD} ${@}
}

_cfg_insert_column() {
    [[ $# != 1 ]] && { _msg ECHO "_cfg_insert_column(): Expected 1 argument"; return 1; }
    # Argument parser and sanity check
    local FILE="${1}"
    local TMP_FILE="$(_cfg_tmp_file ${FILE})"
    local VALUE=${2}
    local NX_COLUMN=$(( $(awk 'BEGIN{OFS="\t"}; {if (NR == 1) {print NF}}' ${FILE}) + 1 ))

    # Write new version of header into file
    awk 'BEGIN {OFS="\t"}; {if (NR == 1) {$'${NX_COLUMN}'="'${VALUE}'"} {print $0}}' "${FILE}" > ${TMP_FILE} && mv ${TMP_FILE} ${FILE}
}
  
_cfg_insert_row() {
    [[ -z ${1+x} ]] && { _msg ECHO "_cfg_insert_row(): Expected at least 1 argument"; return 1; }
    # Argument parser and sanity check
    local FILE="${1}"; shift
    local valueList=(${@})
    local COLUMN_NO=$(awk 'BEGIN{OFS="\t"}; {if (NR == 1) {print NF}}' ${FILE})
    [[ "${#valueList[@]}" != "${COLUMN_NO}" ]] && { _msg ECHO "_cfg_insert_row(): Number of arguments must be equal to ${COLUMN_NO}"; return 1; }

    # Write row into file
    printf "%s\t" ${valueList[@]} | awk 'BEGIN{OFS="\t";} {printf "%s\n",$0}' >> ${FILE}
}

_cfg_query() {
    # Argument parser and sanity check
    local FILE="${1}"
    local CONDITION="${2}"
    
    awk 'BEGIN {FS="\t"; OFS="\t"}; {if ('${CONDITION}') {print NR}}' "${FILE}"
}

_cfg() {
    # Sanity check and command parser
    [[ -z ${1+x} ]] && { _msg ECHO "_cfg(): Expected command"; return 1; }
    local cmdList="(set-file create print change drop insert query)"
    local CMD=${1}; shift
    _if_array_contains ${CMD} ${cmdList[@]} || { _msg ECHO "_cfg(): Command specified not valid"; return 1; }

    # Dispatcher
    eval _cfg_$(sed 's|-|_|' <<<"${CMD}") ${@}
}
