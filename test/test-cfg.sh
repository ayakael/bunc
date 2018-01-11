#!/bin/bash

source ../lib/if.sh
source ../lib/ansi.sh
source ../lib/msg.sh
source ../lib/cfg.sh
TMP=/tmp
testcolList=(COL1 COL2 COL3 COL4 COL5)
# cfg test

bail() {
    cat ${TMP}/test.cfg
    rm ${TMP}/test.cfg
    exit 1 
}

_test_cfg_set_file() {
    _msg EXEC "Testing _cfg_set_file()"
    _cfg_set_file ${TMP}/test.cfg
    [[ "${_CFG_PATH}" != "${TMP}/test.cfg" ]] && { _msg FAIL "_test_cfg_set_file(): \${_CFG_PATH} is '${_CFG_PATH}' rather than the expected '${TMP}/test.cfg'"; }
    [[ "${_CFG_TMP_PATH}" != "${TMP}/.test.cfg" ]] && { _msg FAIL "_test_cfg_set_file(): \${_CFG_TMP_PATH} is '${_CFG_TMP_PATH}' rather than the expected '${TMP}/.test.cfg"; }
    _msg OK
}

_test_cfg_create() {
    _msg EXEC "Testing _cfg_create()"
    local CMD="_cfg_create ${testcolList[@]}"
    eval ${CMD} >${STDERR} 2>&1 || { _msg FAIL "_test_cfg_create(): Error in function execution"; }
    
    local FC_OUTPUT="$(cat ${TMP}/test.cfg)"
    local EX_OUTPUT="$(printf '%s\t' ${testcolList[@]})"
    [[ "${FC_OUTPUT}" != "${EX_OUTPUT}" ]] && { _msg FAIL "_test_cfg_create(): Output '${FC_OUTPUT}' expected to be '${EX_OUTPUT}'"; } 
    _msg OK
}

_test_cfg_column_to_nf() {
    _msg EXEC "Testing _cfg_column_to_nf()"
    local argList=(all ${testcolList[@]})
    _cfg_column_to_nf ${argList[1]} >${STDERR} 2>&1 || { _msg FAIL "test_cfg_column_to_nf(): Error in function execution"; }

    for no in {0..5}; do
        local FC_OUTPUT="$(_cfg_column_to_nf ${argList[${no}]})"
        local EX_OUTPUT="${no}"
        [[ ${FC_OUTPUT} -ne ${EX_OUTPUT} ]] && { _msg FAIL "_test_cfg_column_to_nf(): Output '${FC_OUTPUT}' expected to be '${EX_OUTPUT}'"; }
    done
    _msg OK
}

_test_cfg_print() {
    _msg EXEC "Testing _cfg_print()"
    local argList=(all 1)
    local CMD="_cfg_print ${argList[@]}"
    eval ${CMD} >${STDERR} 2>&1 || { _msg FAIL "_test_cfg_print(): Error in function execution"; }

    local FC_OUTPUT="$(eval ${CMD})"
    local EX_OUTPUT="$(printf '%s\t' ${testcolList[@]})"
    [[ "${FC_OUTPUT}" != "${EX_OUTPUT}" ]] && { _msg FAIL "_test_cfg_print(): Output '${FC_OUTPUT}' expected to be '${EX_OUTPUT}'"; }
    _msg OK
}

_test_cfg_insert_row() {
    _msg EXEC "Testing _cfg_insert_row()"
    local argList=(EL1 EL2 EL3 EL4 EL5)
    local CMD="_cfg_insert_row ${argList[@]}"
    eval ${CMD} >${STDERR} 2>&1 || { _msg FAIL "_test_cfg_insert_row(): Error in function execution"; }

    local FC_OUTPUT="$(_cfg_print all 2)"
    local EX_OUTPUT="$(printf '%s\t' ${argList[@]})"
    [[ "${FC_OUTPUT}" != "${EX_OUTPUT}" ]] && { _msg FAIL "_test_cfg_insert_row(): Output '${FC_OUTPUT}' expected to be '${EX_OUTPUT}'"; }
    
    awk 'BEGIN {OFS="\t"}; {if (NR != 2) {print $0}}' ${_CFG_PATH} > ${_CFG_TMP_PATH} && mv ${_CFG_TMP_PATH} ${_CFG_PATH}
    _msg OK
}

_test_cfg_insert_column() {
    _msg EXEC "Testing _cfg_insert_column()"
    local argList=(COL6)
    local CMD="_cfg_insert_column ${argList[@]}"
    eval ${CMD} >${STDERR} 2>&1 || { _msg FAIL "_test_cfg_insert_column(): Error in function execution"; }
    
    local fcoutputList=($(_cfg_print all 1))
    local exoutputList=(${testcolList[@]} COL6)
   
    [[ "${fcoutputList[@]}" != "${exoutputList[@]}" ]] && { _msg FAIL "_test_cfg_insert_column(): Output '${fcoutputList[@]}' expected to be '${exoutputList[@]}'"; }
    
    awk 'BEGIN {OFS="\t"}; {$6=""; print $0}' ${_CFG_PATH} > ${_CFG_TMP_PATH} && mv ${_CFG_TMP_PATH} ${_CFG_PATH}
    _msg OK
}

_test_cfg_change() {
    _msg EXEC "Testing _cfg_change()"
    _cfg_insert_row ${testcolList[@]}
    local argList=(COL1 2 EL1_CH)
    local CMD="_cfg_change ${argList[@]}"
    eval ${CMD} >${STDERR} 2>&1 || { _msg FAIL "_test_cfg_change(): Error in function execution"; }
    local FC_OUTPUT="$(_cfg_print COL1 2)"
    local EX_OUTPUT="EL1_CH"
    [[ "${FC_OUTPUT}" != "${EX_OUTPUT}" ]] && { _msg FAIL "_test_cfg_change(): Output '${FC_OUTPUT}' expected to be '${EX_OUTPUT}'"; }
    _cfg_drop_row 2
    _msg OK
}

_test_cfg_drop_row() {
    _msg EXEC "Testing _cfg_drop_row()"
    _cfg_insert_row ${testcolList[@]}
    local argList=(2)
    local CMD="_cfg_drop_row ${argList[@]}"    
    eval ${CMD} >${STDERR} 2>&1 || { _msg FAIL "_test_cfg_drop_row(): Error in function execution"; }    

    FC_OUTPUT="$(awk '{print NR}' ${TMP}/test.cfg | wc -l)"
    EX_OUTPUT=1
    [[ ${FC_OUTPUT} != ${EX_OUTPUT} ]] && { _msg FAIL "_test_cfg_drop_row(): Output '${FC_OUTPUT}' expected to be ${EX_OUTPUT}'"; }
    _msg OK
}

_test_cfg_drop_column() {
    _msg EXEC "Testing _cfg_drop_column()"
    _cfg_insert_column "COL6"    
    local argList="COL6"
    local CMD="_cfg_drop_column ${argList[@]}"
    eval ${CMD} >${STDERR} 2>&1 || { _msg FAIL "_test_cfg_drop_column(): Error in function execution"; }

    FC_OUTPUT="$(printf '%s ' $(awk 'BEGIN{OFS="\t"}; {if (NR == 1) {print $0}}' ${_CFG_PATH}))"
    EX_OUTPUT="$(printf '%s ' ${testcolList[@]})"
    [[ "${FC_OUTPUT}" != "${EX_OUTPUT}" ]] && { _msg FAIL "_test_cfg_drop_column(): Output '${FC_OUTPUT}' expected to be '${EX_OUTPUT}'"; }
    _msg OK
}

_test_cfg_query() {
    _msg EXEC "Testing _cfg_query"
    _cfg_insert_row "EL1 EL2 EL3 EL4 EL5"
    _cfg_insert_row "EL6 EL7 EL8 EL9 EL10"
    local ARG="\$1==\"EL6\""
    local CMD="_cfg_query '${ARG}'"
    eval ${CMD} >${STDERR} 2>&1 || { _msg FAIL "_test_cfg_query(): Error in function execution"; }

    FC_OUTPUT=$(eval ${CMD})
    EX_OUTPUT=3
    [[ "${FC_OUTPUT}" != "${EX_OUTPUT}" ]] && { _msg FAIL "_test_cfg_query(): Output '${FC_OUTPUT}' expected to be '${EX_OUTPUT}'"; }

awk 'BEGIN {OFS="\t"}; {if (NR == 1) {print $0}}' ${_CFG_PATH} > ${_CFG_TMP_PATH} && mv ${_CFG_TMP_PATH} ${_CFG_PATH}
    _msg OK
}

testList=(cfg_set_file cfg_create cfg_column_to_nf cfg_print cfg_query cfg_insert_row cfg_insert_column cfg_drop_row cfg_drop_column cfg_change)

_msg ECHO "cfg function test suite started"
for test in ${testList[@]}; do
    eval _test_${test}
done
rm ${TMP}/test.cfg
_msg ECHO "cfg function test suite ended"
