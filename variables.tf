variable "namespace" {
  description = "Project namespace used to name and tag resources."
  type        = string
  default     = "liora"
}

variable "region" {
  description = "AWS region required by the exam."
  type        = string
  default     = "eu-west-3"
}

variable "db_name" {
  description = "Initial MySQL database used by WordPress."
  type        = string
  default     = "wordpress"
}

variable "db_username" {
  description = "RDS master username used by WordPress."
  type        = string
  default     = "wordpress_admin"
}

variable "db_password" {
  description = "RDS password. Supply it at runtime, for example with TF_VAR_db_password."
  type        = string
  sensitive   = true
}
