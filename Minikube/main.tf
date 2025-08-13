terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Build Docker image from your webapp folder
resource "docker_image" "webapp" {
  name         = "webapp:latest"
  build {
    context    = "${path.module}/webapp"
    dockerfile = "Dockerfile"
  }
}

# Kubernetes Namespace
resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo-app"
  }
}

# Kubernetes Deployment
resource "kubernetes_deployment" "demo" {
  metadata {
    name      = "demo-deployment"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "demo"
      }
    }
    template {
      metadata {
        labels = {
          app = "demo"
        }
      }
      spec {
        container {
          name  = "demo"
          image = docker_image.webapp.image_id
          port {
            container_port = 80
          }

          # Liveness probe
          liveness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          # Readiness probe
          readiness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}

# Kubernetes Service
resource "kubernetes_service" "demo" {
  metadata {
    name      = "demo-service"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  spec {
    selector = {
      app = "demo"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "NodePort"
  }
}
