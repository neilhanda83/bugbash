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

# Data source for the target project "pam-demo-at-next24"
data "google_project" "pam_demo_at_next24" {
  project_id = "pam-demo-at-next24"
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

# IAM BINDINGS for project "pam-demo-at-next24"

# REMOVE roles/resourcemanager.projectIamAdmin for user:NeilSlater.508830@gmail.com
resource "google_project_iam_member_remove" "remove_project_iam_admin_neil_slater" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "user:NeilSlater.508830@gmail.com"
}

# ADD organizations/9454078371/roles/CustomRole262 for user:NeilSlater.508830@gmail.com
resource "google_project_iam_member" "add_custom_role_262_neil_slater" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "organizations/9454078371/roles/CustomRole262"
  member  = "user:NeilSlater.508830@gmail.com"
}

# REMOVE roles/resourcemanager.projectIamAdmin for user:VictoriaPowell.157850@gmail.com
resource "google_project_iam_member_remove" "remove_project_iam_admin_victoria_powell" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "user:VictoriaPowell.157850@gmail.com"
}

# ADD organizations/9454078371/roles/CustomRole262 for user:VictoriaPowell.157850@gmail.com
resource "google_project_iam_member" "add_custom_role_262_victoria_powell" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "organizations/9454078371/roles/CustomRole262"
  member  = "user:VictoriaPowell.157850@gmail.com"
}

# REMOVE roles/privilegedaccessmanager.admin for user:gkmr@google.com
resource "google_project_iam_member_remove" "remove_pam_admin_gkmr" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "roles/privilegedaccessmanager.admin"
  member  = "user:gkmr@google.com"
}

# ADD roles/privilegedaccessmanager.viewer for user:gkmr@google.com
resource "google_project_iam_member" "add_pam_viewer_gkmr" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "roles/privilegedaccessmanager.viewer"
  member  = "user:gkmr@google.com"
}

# REMOVE roles/privilegedaccessmanager.admin for user:VictoriaPowell.157850@gmail.com
resource "google_project_iam_member_remove" "remove_pam_admin_victoria_powell" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "roles/privilegedaccessmanager.admin"
  member  = "user:VictoriaPowell.157850@gmail.com"
}

# ADD roles/privilegedaccessmanager.viewer for user:VictoriaPowell.157850@gmail.com
resource "google_project_iam_member" "add_pam_viewer_victoria_powell" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "roles/privilegedaccessmanager.viewer"
  member  = "user:VictoriaPowell.157850@gmail.com"
}

# REMOVE roles/accesscontextmanager.policyEditor for group:pam-abc-team@googlegroups.com
resource "google_project_iam_member_remove" "remove_acm_policy_editor_pam_abc_team" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "roles/accesscontextmanager.policyEditor"
  member  = "group:pam-abc-team@googlegroups.com"
}

# ADD roles/accesscontextmanager.policyReader for group:pam-abc-team@googlegroups.com
resource "google_project_iam_member" "add_acm_policy_reader_pam_abc_team" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "roles/accesscontextmanager.policyReader"
  member  = "group:pam-abc-team@googlegroups.com"
}

# REMOVE roles/resourcemanager.projectIamAdmin for user:gkmr@google.com
resource "google_project_iam_member_remove" "remove_project_iam_admin_gkmr" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "user:gkmr@google.com"
}

# ADD organizations/9454078371/roles/CustomRole262 for user:gkmr@google.com
resource "google_project_iam_member" "add_custom_role_262_gkmr" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "organizations/9454078371/roles/CustomRole262"
  member  = "user:gkmr@google.com"
}

# REMOVE roles/resourcemanager.projectIamAdmin for user:andreamorrison.1943@gmail.com
resource "google_project_iam_member_remove" "remove_project_iam_admin_andrea_morrison" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "user:andreamorrison.1943@gmail.com"
}

# ADD organizations/9454078371/roles/CustomRole262 for user:andreamorrison.1943@gmail.com
resource "google_project_iam_member" "add_custom_role_262_andrea_morrison" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "organizations/9454078371/roles/CustomRole262"
  member  = "user:andreamorrison.1943@gmail.com"
}

# REMOVE roles/privilegedaccessmanager.admin for user:andreamorrison.1943@gmail.com
resource "google_project_iam_member_remove" "remove_pam_admin_andrea_morrison" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "roles/privilegedaccessmanager.admin"
  member  = "user:andreamorrison.1943@gmail.com"
}

# ADD roles/privilegedaccessmanager.viewer for user:andreamorrison.1943@gmail.com
resource "google_project_iam_member" "add_pam_viewer_andrea_morrison" {
  project = data.google_project.pam_demo_at_next24.project_id
  role    = "roles/privilegedaccessmanager.viewer"
  member  = "user:andreamorrison.1943@gmail.com"
}