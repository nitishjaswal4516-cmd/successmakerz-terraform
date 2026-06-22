variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "successmakerz"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "production"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key Pair"
  type        = string
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_1" {
  default = "10.0.1.0/24"
}

variable "public_subnet_2" {
  default = "10.0.2.0/24"
}

variable "frontend_repo" {
  description = "Frontend GitHub Repository"
  type        = string
  default     = "https://github.com/nitishjaswal4516-cmd/successmakerz-frontend.git"
}

variable "backend_repo" {
  description = "Backend GitHub Repository"
  type        = string
  default     = "https://github.com/nitishjaswal4516-cmd/successmakerz-backend.git"
}