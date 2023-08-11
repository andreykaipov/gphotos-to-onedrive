#!/bin/sh
repo=andreykaipov/gphotos-to-onedrive
secret_name=${1?the secret name to create in the github repo}
f=${2?a config file that you generated}
encoded=$(base64 -w0 "$f")
gh secret set "$secret_name" --body "$encoded" -R $repo -a actions
