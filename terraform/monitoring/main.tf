provider "google" {
  credentials = "/home/suporte-gcp/.config/gcloud/legacy_credentials/EMAIL/adc.json"
  project     = "ID_PROJECT_MONITORING"
  region      = "us-central1"
}

resource "google_compute_address" "zabbix_db_static_ip" {
  name   = "zabbix-db-static-ip"
  region = "us-central1"
}

resource "google_compute_address" "zabbix_server_static_ip" {
  name   = "zabbix-server-static-ip"
  region = "us-central1"
}

resource "google_compute_address" "prometheus_server_static_ip" {
  name   = "prometheus-server-static-ip"
  region = "us-central1"
}

resource "google_compute_instance" "zabbix_db" {
  name         = "zabbix-db"
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
      nat_ip = google_compute_address.zabbix_db_static_ip.address
    }
  }
}

resource "google_compute_instance" "zabbix_server" {
  name         = "zabbix-server"
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
      nat_ip = google_compute_address.zabbix_server_static_ip.address
    }
  }
}

resource "google_compute_instance" "prometheus_server" {
  name         = "prometheus-server"
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
      nat_ip = google_compute_address.prometheus_server_static_ip.address
    }
  }
}