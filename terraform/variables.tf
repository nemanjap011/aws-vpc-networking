```hcl
variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "az" {
  description = "Availability Zone suffix to use (e.g. 'a')"
  type        = string
  default     = "a"
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair to attach to instances"
  type        = string
}

variable "admin_ip" {
  description = "Your public IP/CIDR allowed to SSH to the bastion (e.g. '203.0.113.10/32')"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for both instances"
  type        = string
  default     = "t3.micro"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {
    Project   = "aws-vpc-networking-basics"
    ManagedBy = "Terraform"
  }
}
```
