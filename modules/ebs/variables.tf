variable "namespace" { type = string }
variable "availability_zone" {
  description = "Must match the EC2 Availability Zone."
  type        = string
}
variable "instance_id" { type = string }
variable "size_gb" {
  type    = number
  default = 10
}
