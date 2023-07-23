#!/bin/sh

log() { printf '\033[1;33m%s\033[0m\n' "$*" >&2; }
enter() { while :; do echo; done; }
get() { op read "op://gphotos-to-onedrive/$1"; }

main() {
        log "Setting up gphotos-to-onedrive"
        : "${OP_SERVICE_ACCOUNT_TOKEN?needs to be set for op CLI}"
        op user get --me
        f=config/rclone.conf

        log "Testing $f for proper refresh token"
        if {
                test -z "${FORCE-}" &&
                        rclone --config "$f" lsd gphotos:/media/by-month/2000/2000-01 &&
                        rclone --config "$f" lsd onedrive:/
        } >/dev/null; then
                log "Looks good"
                exit
        fi

        log "Generating rclone config to $f"
        rclone_conf >$f

        log "Reconnecting with Google Photos"
        log "If there's a mysterious _something went wrong_ error, try it from an incognito window"
        enter | rclone --config "$f" config reconnect gphotos:

        log "Reconnecting with OneDrive"
        enter | rclone --config "$f" config reconnect onedrive:
}

rclone_conf() {
        cat <<EOF
[gphotos]
type = google photos
client_id = $(get google-client/client-id)
client_secret = $(get google-client/client-secret)
read_only = true
token = {"access_token":"","expiry":"0001-01-01T00:00:00Z"}

[onedrive]
type = onedrive
client_id = $(get microsoft-client/client-id)
client_secret = $(get microsoft-client/secret-value)
drive_id = $(get microsoft-client/drive-id)
drive_type = personal
token = {"access_token":"","expiry":"0001-01-01T00:00:00Z"}
EOF
}

set -eu
main
