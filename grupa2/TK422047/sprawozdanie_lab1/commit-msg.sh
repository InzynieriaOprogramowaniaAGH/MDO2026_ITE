#!/bin/bash

prefix="TK422047"
msg=$(cat "$1")
if [[$msg =~$prefix]]; then
    echo "OK"
    exit 0
else
    echo "nie ma prefixa";
    exit 1
fi