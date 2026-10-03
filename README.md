# Terraform Liora Exam

Terraform implementation of the Liora final project in AWS Paris (`eu-west-3`).

## Architecture

- VPC with one public subnet and two private subnets in two dynamically discovered Availability Zones.
- `t3.micro` EC2 instance using the latest matching Amazon Linux 2023 AMI from an `aws_ami` data source.
- HTTP access on port 80.
- Private `db.t3.micro` MySQL RDS instance with `multi_az = true`; MySQL port 3306 is allowed only from the web-server security group.
- Additional 10 GiB EBS volume in the same Availability Zone as EC2.
- Separate `networking`, `ec2`, `rds`, and `ebs` modules.

The HTTPS bonus is intentionally left out: port 443 alone is not TLS; a certificate and TLS termination would also be required.

## Credentials

Do not put AWS access keys or the database password in source files. Configure AWS credentials with the normal AWS credential chain (for example `aws configure` or environment variables).

Supply the database password at runtime:

```bash
export TF_VAR_db_password='ChooseAValidPassword123!'
```

The variable is marked sensitive, but the value is used in EC2 user data and can therefore be present in Terraform state. Never commit state files.

## Deploy

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

After apply, use the `wordpress_url` output. WordPress may need a few minutes after EC2 starts because the bootstrap waits for the EBS attachment and installs the application.

## Destroy

Delete the complete architecture with Terraform only:

```bash
terraform destroy
```
