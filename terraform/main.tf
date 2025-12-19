terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.14.1"
    }
  }
}

provider "google" {
  # Configuration options
  project     = "gke-terraform-sample-franklin"
  region      = "us-central1"
}

resource "google_service_account" "this" {
  account_id   = "gkesa"
  display_name = "Custom SA for VM Instance"
}

resource "google_compute_instance" "confidential_instance" {
  name             = "myInstance"
  zone             = "us-central1-a"
  machine_type     = "e2-medium"
  min_cpu_platform = "Intel Broadwell"

  confidential_instance_config {
    enable_confidential_compute = false
    confidential_instance_type  = "SEV"
  }

  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-v20251209"
      labels = {
        my_label = "myTag"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.this.email
    scopes = ["cloud-platform"]
  }
}