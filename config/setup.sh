#!/bin/sh
# sudo apt get update

v=1.63.1
zip="https://github.com/rclone/rclone/releases/download/v$v/rclone-v$v-linux-amd64.zip"

cwd="$(cd "$(dirname -- "$0")" && pwd)"
cd "$cwd" || exit

dir=/tmp/rclone
mkdir -p "$dir"

curl -sLo /tmp/rclone.zip "$zip"
busybox unzip /tmp/rclone.zip -d "$dir" -j -o

cp rclone.conf "$dir"

if ! grep -q 'alias rclone' ~/.bashrc; then
        echo "alias rclone='$dir/rclone --config=$dir/rclone.conf'" >>~/.bashrc
fi

if ! grep -qE "export PATH=.:$dir" ~/.bashrc; then
        echo "export PATH=\$PATH:$dir" >>~/.bashrc
fi

cp copy.sh ~
chmod +x copy.sh
