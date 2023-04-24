locals {
  network = "${element(split("-", var.subnet), 0)}"
}

resource "google_compute_instance" "frontend-server" {
  project      = "${var.project}"
  zone         = "us-central1-a"
  name         = "${local.network}-frontend-instance"
  machine_type = "f1-micro"

  metadata_startup_script = "sudo apt-get update && sudo apt-get install apache2 -y && echo '<html><body><h1>Environment: ${local.network}</h1></body></html>' | sudo tee /var/www/html/index.html"

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
