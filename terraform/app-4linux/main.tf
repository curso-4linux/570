provider "google" {
  credentials = "/home/suporte-gcp/.config/gcloud/legacy_credentials/EMAIL/adc.json"
  project     = "ID_PROJECT_DEFAULT"
  region      = "us-central1"
}

resource "google_compute_firewall" "allow_mysql" {
  name    = "allow-mysql"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["db-server"]
}

resource "google_compute_firewall" "allow_memcached" {
  name    = "allow-memcached"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["11211"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["memcached-server"]
}

resource "google_compute_address" "db_server_static_ip" {
  name   = "db-server-static-ip"
  region = "us-central1"
}

resource "google_compute_address" "web_server_static_ip" {
  name   = "web-server-static-ip"
  region = "us-central1"
}

resource "google_compute_address" "memcached_server_static_ip" {
  name   = "memcached-server-static-ip"
  region = "us-central1"
}

resource "google_compute_instance" "db_server" {
  name         = "db-server"
  machine_type = "e2-medium"
  zone         = "us-central1-c"
  tags         = ["db-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.db_server_static_ip.address
    }
  }

  metadata = {
    startup-script = <<-EOF
      #! /bin/bash
      # Instalação do Docker
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh

      # Instalação do Docker Compose
      curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose

      # Clonar repositorio do curso
      git clone https://github.com/curso-4linux/570.git

      # Inicia o container do banco de dados MySQL
      docker-compose -f /570/compose/db-server/docker-compose.yml up -d
    EOF
  }
}

resource "google_compute_instance" "web_server" {
  name         = "web-server"
  machine_type = "e2-medium"
  zone         = "us-central1-c"
  tags         = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.web_server_static_ip.address
    }
  }

  metadata = {
    startup-script = <<-EOF
      #! /bin/bash
      # Instalação do Docker
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh

      # Instalação do Docker Compose
      curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose

      # Clonar repositorio do curso
      git clone https://github.com/curso-4linux/570.git

      # Configura o nome do servidor de banco de dados
      echo "DB_HOST='db-server.us-central1-c.c.ID_PROJECT_DEFAULT.internal'" > /570/compose/web-server/.env

      # Configura o nome do servidor de cache
      sed -i 's/MEMCACHED-SERVER/memcached-server.us-central1-c.c.ID_PROJECT_DEFAULT.internal/' /570/config/php.ini

      # Inicia o container do servidor web com suporte a PHP
      docker-compose -f /570/compose/web-server/docker-compose.yml up -d
    EOF
  }
}

resource "google_compute_instance" "memcached_server" {
  name         = "memcached-server"
  machine_type = "e2-medium"
  zone         = "us-central1-c"
  tags         = ["memcached-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.memcached_server_static_ip.address
    }
  }

  metadata = {
    startup-script = <<-EOF
      #! /bin/bash
      # Instalação do Docker
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh

      # Instalação do Docker Compose
      curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose

      # Clonar repositorio do curso
      git clone https://github.com/curso-4linux/570.git

      # Inicia o container do servidor de cache
      docker-compose -f /570/compose/memcached-server/docker-compose.yml up -d
    EOF
  }
}
