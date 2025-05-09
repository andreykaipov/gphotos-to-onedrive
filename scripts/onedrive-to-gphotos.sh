: "${start=2001}"
: "${end=$(date +%Y)}"

flags='--config /tmp/rclone.conf --no-check-certificate --log-level INFO'

if [ -z "$NO_DRY_RUN" ]; then
        flags="$flags --dry-run"
fi

for y in $(seq $start "$end"); do
        # for m in $(seq -w 1 12); do
        echo ">>> $y $m <<<"
        source="onedrive:media/albums/$y"
        remote="gphotos:upload"
        rclone $flags copy "$source" $remote --metadata
        echo
        # done
done
