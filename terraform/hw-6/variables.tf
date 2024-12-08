variable "region" {
  description = "The AWS region to deploy resources"
  default     = "eu-north-1"
}
variable "availability_zone" {
  default = "eu-north-1a"  
}
variable "cidr_pvc" {
  default = "192.168.0.0/24"
}
variable "cidr_subnet_public" {
  default = "192.168.0.0/25"
}
variable "cidr_subnet_private" {
  default = "192.168.0.128/25"
}
variable "backend_bucket" {
  description = "The name of the S3 bucket for the backend"
  default     = "your-bucket-name"
}
variable "backend_key" {
  description = "The path to the state file inside the S3 bucket"
  default     = "path/to/your/key"
}
variable "instance_type" {
  description = "Type of EC2 instance"
  default     = "t3.micro"
}
variable "ami_id_db" {
  description = "AMI image ID created in HW-3"
  default     = "ami-0d8c77da6eedc2787" 
}
variable "ami_id_web" {
  description = "AMI ID for the EC2 instances debian 12"
  default     = "ami-09c67194d68b73a93" 
}
variable "user_data_app" {
  description = "Path to the user data script from HW-3"
  default     = "../../awscli/optional-stage/app.sh"
}