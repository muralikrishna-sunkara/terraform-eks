output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "loadbalancer_dns" {
  value = module.k8s.loadbalancer_dns
}

output "loadbalancer_url" {
  value = module.k8s.loadbalancer_url
}

output "test_app_access" {
  value = "Access your test app at: ${module.k8s.loadbalancer_url}"
}