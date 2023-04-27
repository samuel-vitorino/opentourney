locals {
  network = "${element(split("-", var.subnet), 0)}"
}

data "google_container_registry_image" "frontend-image" {
  name = "opentourney-frontend"
}

resource "null_resource" "null_im" {
  triggers = {
    im = data.google_container_registry_image.frontend-image
  }
}

data "google_compute_address" "static-ip-address" {
  name = "opentourney-${local.network}"
  region = "us-central1"
}

resource "google_compute_instance" "frontend-server" {
  project      = "${var.project}"
  zone         = "us-central1-a"
  name         = "${local.network}-frontend-instance"
  machine_type = "f1-micro"

  metadata_startup_script = "docker run -p 80:80 ${data.google_container_registry_image.frontend-image.image_url}"

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-97-lts"
    }
  }

  network_interface {
    subnetwork = "${var.subnet}"

    access_config {
      nat_ip = "${data.google_compute_address.static-ip-address.address}"
    }
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.null_im
    ]
  }

  tags = ["${local.network}-frontend-server"]
}
