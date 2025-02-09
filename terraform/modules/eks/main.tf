// Create the EKS Cluster using the cluster IAM role
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = var.eks_role_arn // This should be the cluster role ARN (from module.iam.eks_cluster_role_arn)

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = {
    Name = var.cluster_name
  }
}

output "eks_cluster_id" {
  value = aws_eks_cluster.eks_cluster.id
}

resource "aws_security_group" "node_group_sg" {
  name_prefix = "eks_node_group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-group-sg"
  }
}

// Create the EKS Node Group using the worker node IAM role
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = var.cluster_name
  node_group_name = "eks-nodes"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  depends_on = [aws_eks_cluster.eks_cluster]

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "eks-node-group"
  }
}

