data "google_client_config" "default" {
}


resource "google_service_account" "gke-service-ac" {
  account_id   = "gke-service-account"
  display_name = "GKE service account"

}

resource "google_container_cluster" "test-gke-cluster" {
  name                     = var.gke-cluster-name
  location                 = var.zone-name
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = var.vpc-name
  subnetwork               = var.subnet-name

  ip_allocation_policy {

    cluster_secondary_range_name  = var.cluster-range-name
    services_secondary_range_name = var.service-range-name
  }
  release_channel {
    channel = "REGULAR"
  }
  networking_mode = "VPC_NATIVE"

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master-cidr-range
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = var.master-auth-cidr-block
    }

  }

}


resource "google_container_node_pool" "node-pool-1" {
  name              = "node-pool-one"
  location          = var.zone-name
  cluster           = google_container_cluster.test-gke-cluster.name
  node_count        = 1
  max_pods_per_node = 30
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  node_config {
    machine_type    = "e2-medium"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke-service-ac.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      machine = "medium"
      dept    = "testing"
    }
    tags = ["gke", "dev"]

  }

}


resource "google_container_node_pool" "node-pool-2" {
  name              = "node-pool-two"
  location          = var.zone-name
  cluster           = google_container_cluster.test-gke-cluster.name
  node_count        = 1
  max_pods_per_node = 30
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  node_config {
    machine_type    = "e2-small"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke-service-ac.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      machine = "small"
      dept    = "testing"
    }
    tags = ["gke", "dev"]
  }

}



provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.test-gke-cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.test-gke-cluster.master_auth.0.cluster_ca_certificate)
  }

}


resource "helm_release" "test-pkg" {
  name  = var.chart-name
  chart = "./helm"

  depends_on = [
    google_container_cluster.test-gke-cluster
  ]
}
