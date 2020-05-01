provider "google" {
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = google_compute_network.vpc_network.self_link
    access_config {
    }
  }

  metadata = {
    "block-project-ssh-keys" = "true"
    "sshKeys"                = "${var.gce_ssh_user}:${var.gce_ssh_pub_key}"
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "icmp" {
  name    = "icmp-allow"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "ssh" {
  name    = "ssh-allow"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

output "external_IP" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "internal_IP" {
  value = google_compute_instance.vm_instance.network_interface[0].network_ip
}

