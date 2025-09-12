resource "kubernetes_deployment" "test_app" {
  metadata {
    name = "test-monitored-app"
    namespace = "default"
    labels = {
      app = "test-monitored-app"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "test-monitored-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "test-monitored-app"
        }
      }
      spec {
        container {
          image = "monitored-eye:latest"
          name  = "app"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 5000
            name = "http"
          }
          
          liveness_probe {
            http_get {
              path = "/"
              port = 5000
            }
            initial_delay_seconds = 30
            period_seconds = 10
            failure_threshold = 3
          }
          
          readiness_probe {
            http_get {
              path = "/"
              port = 5000
            }
            initial_delay_seconds = 30
            period_seconds = 10
            failure_threshold = 3
          }
        }
      }
    }
  }

  timeouts {
    create = "15m"
    update = "10m"
    delete = "5m"
  }
}

resource "kubernetes_service" "test_app" {
  metadata {
    name = "test-monitored-app-service"
    namespace = "default"
    labels = {
      app = "test-monitored-app"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.test_app.metadata[0].labels.app
    }
    port {
      name        = "http"
      port        = 5000
      target_port = 5000
    }
    type = "ClusterIP"
  }
}


resource "kubectl_manifest" "service_monitor" {
  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: test-monitored-app-monitor
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: test-monitored-app
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
  namespaceSelector:
    matchNames:
    - default
YAML

  depends_on = [
    helm_release.kube-prometheus-stack,
    kubernetes_service.test_app
  ]
}



resource "kubectl_manifest" "high_request_rate_alert" {
  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: high-request-rate-alert
  namespace: monitoring
spec:
  groups:
  - name: test-app-alerts
    rules:
    - alert: HighRequestRate
      expr: rate(http_requests_total[5m]) > 5
      for: 1m 
      labels:
        severity: warning
        app: test-monitored-app
      annotations:
        summary: "High request rate detected"
        description: "Request rate is above 5 requests per second for more than 1 minute"
YAML

  depends_on = [
    helm_release.kube-prometheus-stack
  ]
}
