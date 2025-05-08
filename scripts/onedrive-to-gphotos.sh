: "${start=2000}"
: "${end=$(date +%Y)}"

flags='/tmp/rclone.conf --no-check-certificate --log-level INFO'

if [ -z "$NO_DRY_RUN" ]; then
        flags="$flags --dry-run"
fi

for y in $(seq $start "$end"); do
        for m in $(seq -w 1 12); do
                echo ">>> $y $m <<<"
                source="onedrive:media/albums/$y/$m"
                remote="gphotos:upload"
                rclone $flags copy "$source" $remote
                echo
        done
done
