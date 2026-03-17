# Configure the Google Cloud provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"  # Use a recent version
    }
  }
}

provider "google" {
  project = "600587461297" # Replace with your project ID
}

# Data source for the project
data "google_project" "current" {
  project_id = "600587461297"
}

resource "google_compute_network" "main_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = false
}
resource "google_compute_firewall" "allow_elastic_tcp_9200" {
  name        = "iac-e2e-workflow-test-open-firewall"
  description = "Allow TCP traffic on port 9200 from any source (0.0.0.0/0)"
  network     = google_compute_network.main_network.self_link
  direction   = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["9200"]
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_instance" "example_instance" {
  name         = "example-instance-with-tag"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  tags         = ["elkstack-1-elastic"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  network_interface {
    network = google_compute_network.main_network.self_link
    access_config {}
  }
}

# Remove the unused IAM role using google_project_iam_member
resource "google_project_iam_member" "remove_unused_editor_role" {
  project = data.google_project.current.project_id
  role    = "roles/editor"
  member  = "serviceAccount:600587461297-compute@developer.gserviceaccount.com"
  # Add condition to prevent deletion of the member if it is added manually.
  lifecycle {
    ignore_changes = [
      condition,
    ]
    # prevent_destroy = true # Recommended for important resources, but not needed here
  }
}

# Example of how to add a new role if needed.
resource "google_project_iam_member" "add_new_role" {
    project = data.google_project.current.project_id
    role    = "roles/viewer"
    member  = "serviceAccount:600587461297-compute@developer.gserviceaccount.com"

    lifecycle {
      ignore_changes = [
        condition,
      ]
    }
}

# IAM bindings for project pam-demo-at-next24

# Remove roles for user:gkmr@google.com
resource "google_project_iam_member_remove" "remove_gkmr_project_iam_admin" {
  project = "pam-demo-at-next24"
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "user:gkmr@google.com"
}

resource "google_project_iam_member_remove" "remove_gkmr_pam_admin" {
  project = "pam-demo-at-next24"
  role    = "roles/privilegedaccessmanager.admin"
  member  = "user:gkmr@google.com"
}

# Add roles for user:gkmr@google.com
resource "google_project_iam_member" "add_gkmr_custom_role_262" {
  project = "pam-demo-at-next24"
  role    = "organizations/9454078371/roles/CustomRole262"
  member  = "user:gkmr@google.com"
}

resource "google_project_iam_member" "add_gkmr_pam_viewer" {
  project = "pam-demo-at-next24"
  role    = "roles/privilegedaccessmanager.viewer"
  member  = "user:gkmr@google.com"
}

# Remove roles for user:deseelam@google.com
resource "google_project_iam_member_remove" "remove_deseelam_project_iam_admin" {
  project = "pam-demo-at-next24"
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "user:deseelam@google.com"
}

# Add roles for user:deseelam@google.com
resource "google_project_iam_member" "add_deseelam_custom_role_262" {
  project = "pam-demo-at-next24"
  role    = "organizations/9454078371/roles/CustomRole262"
  member  = "user:deseelam@google.com"
}