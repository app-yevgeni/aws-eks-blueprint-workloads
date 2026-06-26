
variable "aws_region" {
  description = "Region"
  default = "us-west-2"  
}

variable "cluster_name" {
  description = "Cluster Name"
  default = "eks-cluster"
}

variable "cluster_version" {
  description = "Cluster Version"
  default = "1.33"
}

variable "instance_types" {
  type    = list(string)
  default  = ["t3.medium"]
}

variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig for the target cluster"
  default     = "~/.kube/config"
}

variable "namespace" {
  type        = string
  default     = "weaviate"
  description = "Kubernetes namespace where Weaviate is deployed"
}
