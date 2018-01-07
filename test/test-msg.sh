#!/bin/bash
source ../lib/if.sh
source ../lib/ansi.sh
source ../lib/msg.sh

clean() {
return 0
}

echo "Starting test for log library"
_msg ECHO "Testing echo"
sleep 1
_msg EXEC "Testing EXEC w/ OK"
sleep 1
_msg OK
sleep 1
_msg EXEC "Testing EXEC w/ WARN"
sleep 1
_msg WARN "This is a WARN"
sleep 1
_msg EXEC "Testing EXEC w/ FAIL"
sleep 1
_msg FAIL "This is a FAIL"
sleep 1
_msg INDENT +1
_msg EXEC "This is EXEC w/ indent of 1"
sleep 1
_msg OK
