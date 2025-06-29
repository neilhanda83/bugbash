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

# Local variable for the target project ID from IAM_BINDINGS
locals {
  target_project_id = "pam-dp-maf-1724303557-y1-2"
}

# IAM Binding updates for project: pam-dp-maf-1724303557-y1-2

# REMOVE: roles/iam.serviceAccountTokenCreator for serviceAccount:643618479314-compute@developer.gserviceaccount.com
resource "google_project_iam_member_remove" "remove_sa_643618479314_token_creator" {
  project = local.target_project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:643618479314-compute@developer.gserviceaccount.com"
}

# ADD: roles/iam.serviceAccountOpenIdTokenCreator for serviceAccount:643618479314-compute@developer.gserviceaccount.com
resource "google_project_iam_member" "add_sa_643618479314_openid_token_creator" {
  project = local.target_project_id
  role    = "roles/iam.serviceAccountOpenIdTokenCreator"
  member  = "serviceAccount:643618479314-compute@developer.gserviceaccount.com"
}

# REMOVE: roles/owner for serviceAccount:environmentgate-admin@pam-dp-maf.iam.gserviceaccount.com
resource "google_project_iam_member_remove" "remove_sa_environmentgate_owner" {
  project = local.target_project_id
  role    = "roles/owner"
  member  = "serviceAccount:environmentgate-admin@pam-dp-maf.iam.gserviceaccount.com"
}

# ADD: roles/cloudfunctions.admin for serviceAccount:environmentgate-admin@pam-dp-maf.iam.gserviceaccount.com
resource "google_project_iam_member" "add_sa_environmentgate_cloudfunctions_admin" {
  project = local.target_project_id
  role    = "roles/cloudfunctions.admin"
  member  = "serviceAccount:environmentgate-admin@pam-dp-maf.iam.gserviceaccount.com"
}

# ADD: roles/iam.serviceAccountUser for serviceAccount:environmentgate-admin@pam-dp-maf.iam.gserviceaccount.com
resource "google_project_iam_member" "add_sa_environmentgate_service_account_user" {
  project = local.target_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:environmentgate-admin@pam-dp-maf.iam.gserviceaccount.com"
}

# ADD: roles/resourcemanager.projectIamAdmin for serviceAccount:environmentgate-admin@pam-dp-maf.iam.gserviceaccount.com
resource "google_project_iam_member" "add_sa_environmentgate_project_iam_admin" {
  project = local.target_project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:environmentgate-admin@pam-dp-maf.iam.gserviceaccount.com"
}

# ADD: roles/vpcaccess.viewer for serviceAccount:environmentgate-admin@pam-dp-maf.iam.gserviceaccount.com
resource "google_project_iam_member" "add_sa_environmentgate_vpcaccess_viewer" {
  project = local.target_project_id
  role    = "roles/vpcaccess.viewer"
  member  = "serviceAccount:environmentgate-admin@pam-dp-maf.iam.gserviceaccount.com"
}

# REMOVE: roles/owner for serviceAccount:643618479314-compute@developer.gserviceaccount.com
resource "google_project_iam_member_remove" "remove_sa_643618479314_owner" {
  project = local.target_project_id
  role    = "roles/owner"
  member  = "serviceAccount:643618479314-compute@developer.gserviceaccount.com"
}

# ADD: roles/run.viewer for serviceAccount:643618479314-compute@developer.gserviceaccount.com
resource "google_project_iam_member" "add_sa_643618479314_run_viewer" {
  project = local.target_project_id
  role    = "roles/run.viewer"
  member  = "serviceAccount:643618479314-compute@developer.gserviceaccount.com"
}

# REMOVE: roles/owner for serviceAccount:maf-test@pam-dp-maf-1724303557-y1-2.iam.gserviceaccount.com
resource "google_project_iam_member_remove" "remove_sa_maf_test_owner" {
  project = local.target_project_id
  role    = "roles/owner"
  member  = "serviceAccount:maf-test@pam-dp-maf-1724303557-y1-2.iam.gserviceaccount.com"
}

# ADD: roles/run.servicesInvoker for serviceAccount:maf-test@pam-dp-maf-1724303557-y1-2.iam.gserviceaccount.com
resource "google_project_iam_member" "add_sa_maf_test_run_services_invoker" {
  project = local.target_project_id
  role    = "roles/run.servicesInvoker"
  member  = "serviceAccount:maf-test@pam-dp-maf-1724303557-y1-2.iam.gserviceaccount.com"
}

# REMOVE: roles/resourcemanager.projectIamAdmin for serviceAccount:47826083103-compute@developer.gserviceaccount.com
resource "google_project_iam_member_remove" "remove_sa_47826083103_project_iam_admin" {
  project = local.target_project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:47826083103-compute@developer.gserviceaccount.com"
}

# ADD: organizations/9454078371/roles/CustomRole262 for serviceAccount:47826083103-compute@developer.gserviceaccount.com
resource "google_project_iam_member" "add_sa_47826083103_custom_role_262" {
  project = local.target_project_id
  role    = "organizations/9454078371/roles/CustomRole262"
  member  = "serviceAccount:47826083103-compute@developer.gserviceaccount.com"
}

# REMOVE: roles/editor for serviceAccount:643618479314-compute@developer.gserviceaccount.com
resource "google_project_iam_member_remove" "remove_sa_643618479314_editor" {
  project = local.target_project_id
  role    = "roles/editor"
  member  = "serviceAccount:643618479314-compute@developer.gserviceaccount.com"
}