variable "cluster_name" {}
variable "eks_role_arn" {}
variable "subnet_ids" {
  type = list(string)
}
