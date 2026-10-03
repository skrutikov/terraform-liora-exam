variable "namespace" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "user_data" {
  type      = string
  sensitive = true
}
