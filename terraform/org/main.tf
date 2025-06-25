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

# Data source for the target project where IAM bindings are to be removed
data "google_project" "target_project_sdw_data_gov" {
  project_id = "sdw-data-gov-6cc88e-38db"
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

# IAM Binding removals for project sdw-data-gov-6cc88e-38db
resource "google_project_iam_member_remove" "remove_dlp_user_test_bqdw_automate" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/dlp.user"
  member  = "serviceAccount:test-bqdw-automate@diogod-tests.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_resourcemanager_projectiamadmin_test_bqdw_automate" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:test-bqdw-automate@diogod-tests.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_datacatalog_admin_test_bqdw_automate" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/datacatalog.admin"
  member  = "serviceAccount:test-bqdw-automate@diogod-tests.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_dlp_deidentifytemplatesreader_sa_dataflow_controller" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/dlp.deidentifyTemplatesReader"
  member  = "serviceAccount:sa-dataflow-controller@sdw-data-ing-6cc88e-b604.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_serviceusage_serviceusageadmin_test_bqdw_automate" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:test-bqdw-automate@diogod-tests.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_dlp_inspecttemplatesreader_sa_dataflow_controller" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/dlp.inspectTemplatesReader"
  member  = "serviceAccount:sa-dataflow-controller@sdw-data-ing-6cc88e-b604.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_dlp_inspecttemplatesreader_sa_dataflow_controller_reid" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/dlp.inspectTemplatesReader"
  member  = "serviceAccount:sa-dataflow-controller-reid@sdw-conf-6cc88e-a8b6.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_iam_serviceaccounttokencreator_test_bqdw_automate" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:test-bqdw-automate@diogod-tests.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_dlp_deidentifytemplatesreader_sa_dataflow_controller_reid" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/dlp.deidentifyTemplatesReader"
  member  = "serviceAccount:sa-dataflow-controller-reid@sdw-conf-6cc88e-a8b6.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_dlp_deidentifytemplateseditor_test_bqdw_automate" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/dlp.deidentifyTemplatesEditor"
  member  = "serviceAccount:test-bqdw-automate@diogod-tests.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_cloudkms_admin_test_bqdw_automate" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/cloudkms.admin"
  member  = "serviceAccount:test-bqdw-automate@diogod-tests.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_dlp_user_sa_dataflow_controller" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/dlp.user"
  member  = "serviceAccount:sa-dataflow-controller@sdw-data-ing-6cc88e-b604.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_dlp_inspecttemplateseditor_test_bqdw_automate" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/dlp.inspectTemplatesEditor"
  member  = "serviceAccount:test-bqdw-automate@diogod-tests.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_dlp_user_sa_dataflow_controller_reid" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/dlp.user"
  member  = "serviceAccount:sa-dataflow-controller-reid@sdw-conf-6cc88e-a8b6.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_storage_admin_test_bqdw_automate" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:test-bqdw-automate@diogod-tests.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_iam_serviceaccountadmin_test_bqdw_automate" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:test-bqdw-automate@diogod-tests.iam.gserviceaccount.com"
}

resource "google_project_iam_member_remove" "remove_secretmanager_admin_test_bqdw_automate" {
  project = data.google_project.target_project_sdw_data_gov.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:test-bqdw-automate@diogod-tests.iam.gserviceaccount.com"
}