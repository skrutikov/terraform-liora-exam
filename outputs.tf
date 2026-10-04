output "wordpress_url" {
  value = "http://${module.ec2.public_ip}"
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "ebs_volume_id" {
  value = module.ebs.volume_id
}
