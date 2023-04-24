resource "google_cloud_run_service" "server" {
  name     = "example"
  location = "us-central1"
  subnetwork = var.subnet
  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/:latest"
      }
    }
  }

  traffics {
    percent         = 100
    latest_revision = true
  }

  tags = ["server"]
}