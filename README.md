## gphotos-to-onedrive

I use Google Photos' 15GB of free storage as a "staging" area for my photos.
I use OneDrive as the long term backup solution.
Every so often I go through the following steps to copy over my Google Photos to OneDrive.
It's not fully automated.

## instructions

First set up rclone locally.
Go through the following instructions to setup new tokens and apps since it's probably been a while since you last looked at this repo:

- https://rclone.org/googlephotos/
- https://rclone.org/onedrive/

```console
❯ rclone config --config config/rclone.conf
```

This will generate a new config in `config/rclone.conf` that'll get copied to our `rcloner` VM.
We use a VM because its network will be quicker than our doodoo ISP.

Right now I'm using DigitalOcean, so get an API key from there and update `terraform.tfvars` with a local public SSH key so we can provision our VM:

```console
❯ export DIGITALOCEAN_TOKEN=...

❯ cat terraform.tfvars
ssh_keys = [
  "~/.config/ssh/keys/dustbox.pem.pub",
]

❯ terraform apply
...

❯ terraform output
ip = ...

❯ ssh root@...
```

On the VM, test it out:

```console
root@rcloner:~# DRY_RUN=1 ./copy.sh
```

### NOTE
**Please don't ever run `rclone sync ...`.**
If photos were deleted from Google Photos, they'll also be deleted from OneDrive.
It seems like Google has magically deleted a few photos that I never remember deleting, so `rclone copy` is the only way to go.
