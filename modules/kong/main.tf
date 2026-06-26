
resource "helm_release" "kong" {
  name             = "kong"
  namespace        = "kong"
  create_namespace = true

  repository = "https://charts.konghq.com"
  chart      = "kong"

  set {
    name  = "ingressController.installCRDs"
    value = "false"
  }

  set {
    name  = "ingressController.gatewayAPI.enabled"
    value = "true"
  }

  set {
    name  = "proxy.type"
    value = "LoadBalancer"
  }

  set {
    name  = "proxy.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "proxy.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "proxy.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  set {
    name  = "proxy.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
    value = "ip"
  }
}


resource "kubernetes_ingress_v1" "kong_ingress" {
  depends_on = [
    helm_release.kong
  ]
  metadata {
    name      = "${var.name}-ingress"
    namespace = var.namespace

    annotations = {
      "konghq.com/strip-path" = "true"
    }

    labels = {
      app = var.name
    }
  }

  spec {
    ingress_class_name = "kong"

    rule {
      host = var.host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = var.name
              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }
  }
}
