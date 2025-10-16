module "vpc" {
  source = "./modules/vpc"

  project_name           = var.project_name
  cluster_name           = var.cluster_name
  vpc_cidr               = var.vpc_cidr
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
}

module "eks" {
  source = "./modules/eks"

  cluster_name           = var.cluster_name
  kubernetes_version     = var.kubernetes_version
  instance_types         = var.instance_types
  desired_size           = var.desired_size
  max_size               = var.max_size
  min_size               = var.min_size
  private_subnet_ids     = module.vpc.private_subnet_ids
  public_subnet_ids      = module.vpc.public_subnet_ids
  security_group_id      = module.vpc.security_group_id
  node_security_group_id = module.vpc.node_security_group_id
}

module "k8s" {
  source = "./modules/k8s"

  cluster_name            = var.cluster_name
  cluster_endpoint        = module.eks.cluster_endpoint
  cluster_ca_certificate  = module.eks.cluster_ca_certificate
}