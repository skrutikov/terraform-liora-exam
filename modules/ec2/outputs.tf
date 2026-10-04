output "instance_id" { value = aws_instance.wordpress.id }
output "public_ip" { value = aws_instance.wordpress.public_ip }
output "availability_zone" { value = aws_instance.wordpress.availability_zone }
