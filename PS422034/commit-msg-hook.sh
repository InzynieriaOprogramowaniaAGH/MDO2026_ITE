#!/bin/bash
commit_msg=$(cat "$1")
initials="PS422034"
if ! echo "$commit_msg" | grep -qE "^$initials"; then
    echo "ERROR: Commit message musi zaczynac sie od PS422034"
    exit 1
fi
