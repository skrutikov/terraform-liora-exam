resource "aws_ebs_volume" "wordpress" {
  availability_zone = var.availability_zone
  size              = var.size_gb
  type              = "gp3"
  encrypted         = true

  tags = {
    Name = "${var.namespace}-wordpress-data"
  }
}

resource "aws_volume_attachment" "wordpress" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.wordpress.id
  instance_id = var.instance_id
}
