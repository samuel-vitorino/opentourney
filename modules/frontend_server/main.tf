locals {
  network = "${element(split("-", var.subnet), 0)}"
}

resource "google_compute_instance" "frontend_server" {
  project      = "${var.project}"
  zone         = "us-west1-a"
  name         = "${local.network}-frontend-instance"
  machine_type = "f1-micro"

  metadata_startup_script = <<-EOF
    #!/bin/bash
    docker run -p 80:80 gcr.io/${var.project}/opentourney-frontend:latest
  EOF

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-105-lts"
    }
  }

  network_interface {
    subnetwork = "${var.subnet}"
  }

  tags = ["frontend_server"]
}
