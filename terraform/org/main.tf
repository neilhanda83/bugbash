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

# IAM Bindings for project sdw-data-ing-e7b15f-dbf3

# Remove roles/cloudbuild.builds.editor for group:slz-blr@google.com
resource "google_project_iam_member_remove" "remove_cloudbuild_editor_slz_blr_sdw_data_ing" {
  project = "sdw-data-ing-e7b15f-dbf3"
  role    = "roles/cloudbuild.builds.editor"
  member  = "group:slz-blr@google.com"
}

# Add roles/cloudbuild.builds.viewer for group:slz-blr@google.com
resource "google_project_iam_member" "add_cloudbuild_viewer_slz_blr_sdw_data_ing" {
  project = "sdw-data-ing-e7b15f-dbf3"
  role    = "roles/cloudbuild.builds.viewer"
  member  = "group:slz-blr@google.com"
}

# Remove roles/dataflow.admin for group:slz-blr@google.com
resource "google_project_iam_member_remove" "remove_dataflow_admin_slz_blr_sdw_data_ing" {
  project = "sdw-data-ing-e7b15f-dbf3"
  role    = "roles/dataflow.admin"
  member  = "group:slz-blr@google.com"
}

# Note: The 'ADD roles/dataflow.developer' and 'REMOVE roles/dataflow.developer' actions for 'group:slz-blr@google.com'
# cancel each other out, resulting in no net change for this specific role and member.