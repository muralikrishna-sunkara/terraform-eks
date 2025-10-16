terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# Create demo namespace
resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo"
  }
}

# Deploy test app (nginx)
resource "kubernetes_deployment" "test_app" {
  metadata {
    name      = "test-app"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "test-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "test-app"
        }
      }

      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

# Create LoadBalancer service
resource "kubernetes_service" "test_app" {
  metadata {
    name      = "test-app-lb"
    namespace = kubernetes_namespace.demo.metadata[0].name
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
    }
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = "test-app"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    # Enable session affinity
    session_affinity = "ClientIP"
  }
}

# Wait for LoadBalancer to get DNS
data "kubernetes_service" "test_app_lb" {
  metadata {
    name      = kubernetes_service.test_app.metadata[0].name
    namespace = kubernetes_service.test_app.metadata[0].namespace
  }

  depends_on = [kubernetes_service.test_app]
}

output "loadbalancer_dns" {
  description = "LoadBalancer DNS name"
  value       = try(data.kubernetes_service.test_app_lb.status[0].load_balancer[0].ingress[0].hostname, "Pending...")
}

output "loadbalancer_url" {
  description = "Test app URL"
  value       = try("http://${data.kubernetes_service.test_app_lb.status[0].load_balancer[0].ingress[0].hostname}", "Pending...")
}