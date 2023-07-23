
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {}

variable "ssh_keys" {
  description = "A set of file names of public SSH keys."
  type        = set(string)
}

resource "digitalocean_ssh_key" "home" {
  for_each   = var.ssh_keys
  name       = basename(each.value)
  public_key = file(each.value)
}

resource "digitalocean_droplet" "rcloner" {
  name              = "rcloner"
  image             = "ubuntu-22-04-x64"
  region            = "nyc1"
  size              = "s-1vcpu-512mb-10gb" # smallest size
  ssh_keys          = [for k in digitalocean_ssh_key.home : k.fingerprint]
  backups           = false
  monitoring        = true
  resize_disk       = false
  droplet_agent     = false
  graceful_shutdown = false
}

resource "null_resource" "provision-rcloner" {
  triggers = {
    id = digitalocean_droplet.rcloner.id
    file_hashes = jsonencode({
      for f in fileset("${path.module}/config", "*") :
      f => filesha256("${path.module}/config/${f}")
    })
  }

  connection {
    type = "ssh"
    user = "root"
    host = digitalocean_droplet.rcloner.ipv4_address
  }

  provisioner "file" {
    source      = "${path.module}/config"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = ["sh /tmp/config/setup.sh"]
  }
}

output "ip" {
  value = digitalocean_droplet.rcloner.ipv4_address
}
