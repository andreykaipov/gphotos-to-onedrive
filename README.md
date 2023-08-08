## gphotos-to-onedrive

I use Google Photos' 15GB of free storage as a "staging" area for my photos.

I use OneDrive as the long term backup solution.

This repo houses a workflow that "commits" my Google Photos to OneDrive.

## todo

- The copy just copies everything from 2000 to $current_year.
  Even though it only takes ~25 minutes when everything is already copied, I can probably eventually use only like the last month.
  It just feels like there's always new stray photos from years ago that pop up sometimes.

- Right now when `rclone.conf` is generated and added as a secret to this repo, it uses the refresh tokens in the config to stay connected.
  These will surely inevitably expire.
  I haven't ran this long enough to see what happens.
  🤷

  Note from two weeks later (8/7/23): seems like the Google refresh token stops working after a week.
  https://forum.rclone.org/t/rclone-google-drive-token-expires-every-week/22502 suggests it's because the Google app was in testing.
  Seems like you can just ignore the scary warnings from Google for verification and publish it to production regardless.
  Let's see what happens in a few weeks!

- ~~Maybe you might even have to automate logging into the client apps with Selenium or something lol~~

  Probably don't need to do this is the refresh token works correctly

## setup

Ideally once this is setup once, it's setup forever.
But things break, so here's documentation for you, Andrey from the future.

1. Nix, devenv, and direnv should be installed and available.
   Alternatively we can refer to the packages inside `devenv.nix`.

1. Required secrets are in a personal 1Password vault appropriately named `gphotos-to-onedrive`.
   Access to the vault is granted to a service account whose token is also in that vault.
   Set it once you have it:

   ```console
   ❯ export OP_SERVICE_ACCOUNT_TOKEN=...
   ```

1. Generate the required `rclone.conf` with `./script/generate-conf.sh`.
   Click the links to authenticate with our client apps and grant them the necessary permissions.

   ```console
   ❯ ./scripts/generate-conf.sh
   Setting up gphotos-to-onedrive
   ...
   Testing config/rclone.conf for proper refresh token
   Generating config to config/rclone.conf
   Reconnecting with Google Photos
   ...
   2023/07/23 20:21:24 NOTICE: Make sure your Redirect URL is set to "http://127.0.0.1:53682/" in your custom config.
   2023/07/23 20:21:24 NOTICE: If your browser doesn't open automatically go to the following link: http://127.0.0.1:53682/auth?state=kcMmEyTfWnxGRRLk2DRaFA
   2023/07/23 20:21:24 NOTICE: Log in and authorize rclone for access
   2023/07/23 20:21:24 NOTICE: Waiting for code...
   2023/07/23 20:21:36 NOTICE: Got code
   ...
   Reconnecting with OneDrive
   ...
   2023/07/23 20:21:37 NOTICE: Make sure your Redirect URL is set to "http://localhost:53682/" in your custom config.
   2023/07/23 20:21:37 NOTICE: If your browser doesn't open automatically go to the following link: http://127.0.0.1:53682/auth?state=It6obmR3mCIfHO6bgVJ4uA
   2023/07/23 20:21:37 NOTICE: Log in and authorize rclone for access
   2023/07/23 20:21:37 NOTICE: Waiting for code...
   2023/07/23 20:21:42 NOTICE: Got code
   ...
   ```

   Trying to generate the config again will tell you it's already good.
   We can force this by setting `FORCE=1` though.

## usage

With the generated config present, we can upload it as a secret to this repo:

1. This assumes we'll be using the workflow to copy our stuff.

   ```console
   ❯ ./scripts/upload-conf.sh
   ```

Or we can work from a VM:

1. Update `terraform.tfvars` with the proper key and deploy the VM:

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

1. On the VM will exist the `copy.sh` script:

   ```console
   root@rcloner:~# tmux
   root@rcloner:~# start=2020 end=2021 ./copy.sh # dry run by default
   root@rcloner:~# tail -f rclone.long
   root@rcloner:~# NO_DRY_RUN=1 ./copy.sh        # when we're ready
   ```

## troubleshooting

Start from the very beginning and check the custom clients you created following:

- https://rclone.org/drive/#making-your-own-client-id
- https://rclone.org/onedrive/#getting-your-own-client-id-and-key

---

### NOTE

**Please don't ever run `rclone sync ...`.**
If photos were deleted from Google Photos, they'll also be deleted from OneDrive.
It seems like Google has magically deleted a few photos that I never remember deleting, so `rclone copy` is the only way to go.
