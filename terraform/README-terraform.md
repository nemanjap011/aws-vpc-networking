```markdown
# Terraform Deployment Instructions

## Prereqs
- Terraform >= 1.5
- AWS credentials configured (profile or env vars)
- Existing EC2 key pair name in the target region
- Your public IP/CIDR (e.g. 198.51.100.12/32)

## Quick Start
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply -auto-approve
```
