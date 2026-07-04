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

# Data source for the target project for new IAM bindings
data "google_project" "target_project_sdw_data_ing" {
  project_id = "sdw-data-ing-3ef33c-e649"
}

# Remove roles/storage.objectViewer for serviceAccount:sa-dataflow-controller@sdw-data-ing-3ef33c-e649.iam.gserviceaccount.com
resource "google_project_iam_member_remove" "remove_storage_object_viewer_for_dataflow_controller" {
  project = data.google_project.target_project_sdw_data_ing.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:sa-dataflow-controller@sdw-data-ing-3ef33c-e649.iam.gserviceaccount.com"
}

# Add organizations/9454078371/roles/pamproberscustomrole for serviceAccount:sa-dataflow-controller@sdw-data-ing-3ef33c-e649.iam.gserviceaccount.com
resource "google_project_iam_member" "add_pamprobers_custom_role_for_dataflow_controller" {
  project = data.google_project.target_project_sdw_data_ing.project_id
  role    = "organizations/9454078371/roles/pamproberscustomrole"
  member  = "serviceAccount:sa-dataflow-controller@sdw-data-ing-3ef33c-e649.iam.gserviceaccount.com"
}