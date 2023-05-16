output "cluster_endpoint" {
  description = "Kubernetes Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = kubernetes_service.workload.
}