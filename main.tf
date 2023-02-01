provider "kubernetes" {
  config_path = "./tke-spin-access"
}

provider "kubernetes" {
  config_path = "./tke-wp-access"
  alias = "wp-cluster"
}

resource "kubernetes_manifest" "sp_ns" {
  manifest = yamldecode(file("./settings/spin_ns.yaml"))
}

resource "kubernetes_manifest" "sp_sa" {
  manifest = yamldecode(file("./settings/spin_serviceaccount.yaml"))
}

resource "kubernetes_manifest" "sp_admin_role_binding" {
  manifest = yamldecode(file("./settings/spin_role_binding.yaml"))
}

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

#resource "kubernetes_manifest" "sp_sa_secret" {
#  manifest = yamldecode(file("./settings/spin_sa_secret.yaml"))
#}

#resource "kubernetes_manifest" "sp_admin_role" {
#  manifest = yamldecode(file("./settings/spin_admin_role.yaml"))
#}

#Step
#/*
resource "kubernetes_manifest" "sp_deck_expose" {
  manifest = yamldecode(file("./settings/spin_deck_expose.yaml"))
}

resource "kubernetes_manifest" "sp_gate_expose" {
  manifest = yamldecode(file("./settings/spin_gate_expose.yaml"))
}
#*/
