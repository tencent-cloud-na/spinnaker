#provider info for Spinnaker TKE cluster
provider "kubernetes" {
  config_path = "./tke-spin-access"
}

#provider info for Spinnaker managed TKE cluster
provider "kubernetes" {
  config_path = "./tke-wp-access"
  alias = "wp-cluster"
}

#Create namespace, service account, and binding role for Spinnaker cluster
resource "kubernetes_manifest" "sp_ns" {
  manifest = yamldecode(file("./settings/spin_ns.yaml"))
}

resource "kubernetes_manifest" "sp_sa" {
  manifest = yamldecode(file("./settings/spin_serviceaccount.yaml"))
}

resource "kubernetes_manifest" "sp_admin_role_binding" {
  manifest = yamldecode(file("./settings/spin_role_binding.yaml"))
}

#Create namespace, service account, and binding role for Spinnaker managed cluster
resource "kubernetes_manifest" "wp_sp_ns" {
  provider = kubernetes.wp-cluster

  manifest = yamldecode(file("./settings/spin_ns.yaml"))
}

resource "kubernetes_manifest" "wp_sp_sa" {
  provider = kubernetes.wp-cluster

  manifest = yamldecode(file("./settings/spin_serviceaccount.yaml"))
}

resource "kubernetes_manifest" "wp_sp_admin_role_binding" {
  provider = kubernetes.wp-cluster

  manifest = yamldecode(file("./settings/spin_role_binding.yaml"))
}

# If you are on k8s 1.24, you will need to create a secret for your service account first
#resource "kubernetes_manifest" "sp_sa_secret" {
#  manifest = yamldecode(file("./settings/spin_sa_secret.yaml"))
#}

# Custom the role that are going to bind with the service account
#resource "kubernetes_manifest" "sp_admin_role" {
#  manifest = yamldecode(file("./settings/spin_admin_role.yaml"))
#}

# Uncomment the block below when you reach Step 5
# Expose Spinnaker Services to private load balancer 
#/*
resource "kubernetes_manifest" "sp_deck_expose" {
  manifest = yamldecode(file("./settings/spin_deck_expose.yaml"))
}

resource "kubernetes_manifest" "sp_gate_expose" {
  manifest = yamldecode(file("./settings/spin_gate_expose.yaml"))
}
#*/
