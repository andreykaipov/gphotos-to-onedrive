#!/bin/sh
repo=andreykaipov/gphotos-to-onedrive
encoded=$(base64 -w0 config/rclone.conf)
gh secret set RCLONE_CONFIG --body "$encoded" -R $repo -a actions
