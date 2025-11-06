variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance (Ubuntu 22.04 LTS)"
  type        = string
  default     = "ami-0705384c0b33c194c" # Ubuntu 22.04 LTS in us-east-1
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "devops-automation-key"
}

variable "public_key" {
  description = "Public SSH key content"
  type        = string
  sensitive   = true
}
