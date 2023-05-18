output "cluster_endpoint" {
  description = "Kubernetes Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "load_balancer_name" {
  description = "Hostname for the load balancer"
  value       = kubernetes_service.workload.status.0.load_balancer.0.ingress.0.hostname
}