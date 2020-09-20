provider "google" {
  credentials = file("~/motion-classification-4365e9f537af.json")
  project = "motion-classification"
  region = "europe-west4"
}

resource "google_compute_firewall" "default" {
 name    = "ssh-firewall"
 network = "default"

 allow {
   protocol = "tcp"
   ports    = ["22", "80"]
 }
}

resource "google_compute_firewall" "allow_daniel" {
 name    = "allow_daniel"
 network = "default"
  direction = "ingress"
  source_ranges = ["79.182.173.166/32"]
 allow {
   protocol = "tcp"
   ports    = []
 }
}

//resource "google_compute_firewall" "allow_egress" {
// name    = "allow_daniel"
// network = "default"
//  direction = "egress"
// allow {
//   protocol = "tcp"
//   ports    = []
// }
//}


// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  byte_length = 8
}

// A single Compute Engine instance
resource "google_compute_instance" "default" {
  name = "daniel-${random_id.instance_id.hex}"
  machine_type = "f1-micro"
  zone = "europe-west4"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  // Make sure flask is installed on all new instances for later steps
  metadata_startup_script = file("setup.sh")
  metadata = {
    ssh-keys = "daniel:${file("~/.ssh/id_rsa.pub")}"
  }

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }
}


// A variable for extracting the external IP address of the instance
output "ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}