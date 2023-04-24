locals {
  network = "${element(split("-", var.subnet), 0)}"
}

resource "google_compute_instance" "frontend-server" {
  project      = "${var.project}"
  zone         = "us-central1-a"
  name         = "${local.network}-frontend-instance"
  machine_type = "f1-micro"

  metadata_startup_script = "docker run --pull=always -p 80:80 gcr.io/${var.project}/opentourney-frontend:latest"

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-97-lts"
    }
  }

  network_interface {
    subnetwork = "${var.subnet}"

    access_config {
    }
  }

  tags = ["frontend-server"]
}
