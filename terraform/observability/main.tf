provider "google" {
  credentials = "/home/suporte-gcp/.config/gcloud/legacy_credentials/EMAIL/adc.json"
  project     = "ID_PROJECT_OBSERVABILITY"
  region      = "us-central1"
}

resource "google_compute_firewall" "allow_graylog_server" {
  name    = "allow-graylog-server"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["graylog-server"]
}

resource "google_compute_firewall" "allow_rsyslog" {
  name    = "allow-rsyslog"
  network = "default"

  allow {
    protocol = "udp"
    ports    = ["514"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["rsyslog"]
}

resource "google_compute_firewall" "allow_gelf_udp" {
  name    = "allow-gelf-udp"
  network = "default"

  allow {
    protocol = "udp"
    ports    = ["12201"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gelf-udp"]
}

resource "google_compute_firewall" "allow_kibana" {
  name    = "allow-kibana"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5601"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["kibana"]
}

resource "google_compute_address" "graylog_server_static_ip" {
  name   = "graylog-server-static-ip"
  region = "us-central1"
}

resource "google_compute_address" "elk_server_static_ip" {
  name   = "elk-server-static-ip"
  region = "us-central1"
}

resource "google_compute_instance" "graylog_server" {
  name         = "graylog-server"
  machine_type = "e2-standard-4"
  zone         = "us-central1-c"
  tags         = ["graylog-server", "rsyslog", "gelf-udp"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = "30"
      type  = "pd-balanced"
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
  machine_type = "e2-standard-4"
  zone         = "us-central1-c"
  tags         = ["kibana", "http-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = "30"
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.elk_server_static_ip.address
    }
  }
}
