provider "google" {
  credentials = "/home/suporte-gcp/.config/gcloud/legacy_credentials/EMAIL/adc.json"
  project     = "ID_PROJECT_OBSERVABILITY"
  region      = "us-central1"
}

resource "google_compute_address" "graylog_server_static_ip" {
  name   = "graylog-server-static-ip"
  region = "us-central1"
}

resource "google_compute_address" "elk_server_static_ip" {
  name   = "elk-server-static-ip"
  region = "us-central1"
}

resource "google_compute_address" "opentelemetry_server_static_ip" {
  name   = "opentelemetry-server-static-ip"
  region = "us-central1"
}

resource "google_compute_instance" "graylog_server" {
  name         = "graylog-server"
  machine_type = "e2-standard-4"
  zone         = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.graylog_server_static_ip.address
    }
  }
}

resource "google_compute_instance" "elk_server" {
  name         = "elk-server"
  machine_type = "e2-standard-2"
  zone         = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.elk_server_static_ip.address
    }
  }
}

resource "google_compute_instance" "opentelemetry_server" {
  name         = "opentelemetry-server"
  machine_type = "e2-standard-2"
  zone         = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.opentelemetry_server_static_ip.address
    }
  }
}
