#!/bin/sh
# shellcheck disable=SC2086

: "${start=2000}"
: "${end=$(date +%Y)}"

mv rclone.log rclone.log.old

flags="--progress --log-file=rclone.log --log-level=DEBUG"
if [ -z "$NO_DRY_RUN" ]; then
        flags="$flags --dry-run"
fi

for y in $(seq $start "$end"); do
        for m in $(seq -w 1 12); do
                echo ">>> $y $m <<<"
                source="gphotos:/media/by-month/$y/$y-$m"
                remote="onedrive:/media/albums/$y/$m"
                rclone copy $flags "$source" "$remote"
                echo
        done
done
