//Creating a bucket 
resource "google_storage_bucket" "statebucket" {
  name          = "bucket-poc-boozt"
  location      = var.region
  project       = var.project
  storage_class = "STANDARD"
//enforced public access prevention
  public_access_prevention = "enforced"
}

resource "google_service_account" "default" {
  account_id   = "my-custom-sa"
  display_name = "Custom SA for VM Instance"
}

resource "google_compute_instance" "default" {
  name         = "my-instance"
  machine_type = "n2-standard-2"
  zone         = "europe-north1"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
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

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}



resource "google_compute_subnetwork" "poc_subnet" {
  name          = "subnetwork-poc"
  project       = var.project
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.poc_network.id
  secondary_ip_range {
    range_name    = "tf-test-secondary-range"
    ip_cidr_range = "192.168.10.0/24"
  }
}

resource "google_compute_network" "poc_network" {
  name                    = "poc-network"
  project                 = var.project
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "http_https" {
  name    = "allow-http-https"
  network = google_compute_network.poc_network.id  
  project       = var.project

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["http-https"]

  source_ranges = ["0.0.0.0/0"]  # Allow traffic from any source

}

resource "google_compute_firewall" "fw_iap" {
  name          = "allow-tcp-22"
  project       = var.project
  direction     = "INGRESS"
  network       = google_compute_network.poc_network.id
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports     =  [ "22" ]
  }
}
