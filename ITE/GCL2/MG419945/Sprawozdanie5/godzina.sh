hour=$(date +%H)
hour=${hour#0}
[ $(($hour % 2)) -eq 1 ] && exit 1 || exit 0
