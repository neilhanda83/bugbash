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
  project = "pam-dp-maf-1724303557-x1-0" # Updated to target RESOURCE_NAME
}

# Data source for the project
data "google_project" "current" {
  project_id = "pam-dp-maf-1724303557-x1-0" # Updated to target RESOURCE_NAME
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

# The existing 'remove_unused_editor_role' resource is removed as 'roles/editor' for this member is explicitly REMOVED.
# The existing 'add_new_role' resource is kept as 'roles/viewer' for this member is explicitly ADDED.

# IAM BINDINGS for serviceAccount:maf-test@pam-dp-maf-1724303557-x1-0.iam.gserviceaccount.com
resource "google_project_iam_member_remove" "remove_owner_maf_test_sa" {
  project = data.google_project.current.project_id
  role    = "roles/owner"
  member  = "serviceAccount:maf-test@pam-dp-maf-1724303557-x1-0.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "add_run_services_invoker_maf_test_sa" {
  project = data.google_project.current.project_id
  role    = "roles/run.servicesInvoker"
  member  = "serviceAccount:maf-test@pam-dp-maf-1724303557-x1-0.iam.gserviceaccount.com"
  lifecycle {
    ignore_changes = [
      condition,
    ]
  }
}

# IAM BINDINGS for serviceAccount:566779154716-compute@developer.gserviceaccount.com
resource "google_project_iam_member_remove" "remove_sa_token_creator_compute_sa" {
  project = data.google_project.current.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:566779154716-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "add_sa_openid_token_creator_compute_sa" {
  project = data.google_project.current.project_id
  role    = "roles/iam.serviceAccountOpenIdTokenCreator"
  member  = "serviceAccount:566779154716-compute@developer.gserviceaccount.com"
  lifecycle {
    ignore_changes = [
      condition,
    ]
  }
}

resource "google_project_iam_member_remove" "remove_project_iam_admin_compute_sa" {
  project = data.google_project.current.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:566779154716-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "add_custom_role_262_compute_sa" {
  project = data.google_project.current.project_id
  role    = "organizations/9454078371/roles/CustomRole262"
  member  = "serviceAccount:566779154716-compute@developer.gserviceaccount.com"
  lifecycle {
    ignore_changes = [
      condition,
    ]
  }
}

# Existing resource for roles/viewer, member: serviceAccount:566779154716-compute@developer.gserviceaccount.com
resource "google_project_iam_member" "add_new_role" {
    project = data.google_project.current.project_id
    role    = "roles/viewer"
    member  = "serviceAccount:566779154716-compute@developer.gserviceaccount.com"

    lifecycle {
      ignore_changes = [
        condition,
      ]
    }
}

resource "google_project_iam_member_remove" "remove_owner_compute_sa" {
  project = data.google_project.current.project_id
  role    = "roles/owner"
  member  = "serviceAccount:566779154716-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "add_pam_admin_compute_sa" {
  project = data.google_project.current.project_id
  role    = "roles/privilegedaccessmanager.admin"
  member  = "serviceAccount:566779154716-compute@developer.gserviceaccount.com"
  lifecycle {
    ignore_changes = [
      condition,
    ]
  }
}

# This role was removed and then added for the same member, so both actions are represented.
resource "google_project_iam_member" "add_project_iam_admin_compute_sa" {
  project = data.google_project.current.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:566779154716-compute@developer.gserviceaccount.com"
  lifecycle {
    ignore_changes = [
      condition,
    ]
  }
}

resource "google_project_iam_member" "add_run_viewer_compute_sa" {
  project = data.google_project.current.project_id
  role    = "roles/run.viewer"
  member  = "serviceAccount:566779154716-compute@developer.gserviceaccount.com"
  lifecycle {
    ignore_changes = [
      condition,
    ]
  }
}