provider "google" {
  project = "development-rhp0qfb"
  region  = "us-east1"
}

locals {
  user        = "andrey"
  private_key = "~/.config/ssh/keys/wsl2.pem"
}

resource "google_compute_instance" "default" {
  name         = "rcloner"
  machine_type = "e2-micro"
  zone         = "us-east1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "${local.user}:${file("${local.private_key}.pub")}"
  }
}

resource "null_resource" "provision" {
  triggers = {
    file_hashes = jsonencode({
      for f in fileset("${path.module}/config", "*") :
      f => filesha256("${path.module}/config/${f}")
    })
  }

  connection {
    type        = "ssh"
    user        = local.user
    host        = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
    private_key = file(local.private_key)
  }

  provisioner "file" {
    source      = "${path.module}/config"
    destination = "/tmp/config"
  }

  provisioner "remote-exec" {
    inline = ["sh /tmp/config/setup.sh"]
  }
}

output "ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
