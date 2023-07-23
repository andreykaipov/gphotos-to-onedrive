{ pkgs
, ...
}:
{
  packages = with pkgs; [
    _1password
    gh
    rclone
    terraform
  ];

  processes = {
    generate-rclone-conf.exec = "./scripts/generate-conf.sh";
  };

  enterShell = '' '';
}
