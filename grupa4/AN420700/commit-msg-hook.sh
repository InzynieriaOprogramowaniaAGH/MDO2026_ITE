#!/bin/bash
commit_msg=$(cat "$1")
pattern="^AN420700"

if [[ ! $commit_msg =~ $pattern ]]; then
    	echo "Commit message must start with AN420700"
	exit 1
fi
