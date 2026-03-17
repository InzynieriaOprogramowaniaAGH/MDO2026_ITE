#!/bin/bash
sed -i '1 { /^JS423270/! s/^/JS423270 / }' "$1"