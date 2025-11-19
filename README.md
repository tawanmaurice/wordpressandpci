# WordPress + PCI Practice Stack (Terraform on AWS)

This repo builds a **PCI-style WordPress environment** on AWS using Terraform.

Right now the stack deploys:

- A **VPC** with public + private subnets across multiple AZs  
- An **Internet Gateway** and **NAT Gateway**
- **Security groups** for:
  - ALB (public HTTPS)
  - EC2 web servers (private)
  - RDS MySQL (private, EC2-only access)
- An **Application Load Balancer (ALB)** with:
  - HTTP → HTTPS redirect
  - ACM certificate for `site.tawanperry.top`
- A **Route 53 A record** for:  
  `https://site.tawanperry.top`
- An **Auto Scaling Group (ASG)** using a **Launch Template**
- An **RDS MySQL instance** (`wp-db`) in private subnets

For now, the EC2 user data only serves a simple test page:

> **“Hello from App1 behind the ALB! If you can see this, the ALB → Target Group → EC2 chain is working.”**

WordPress will be installed **manually** on the EC2 instances (see below).

---

## Architecture

**High-level flow:**

1. User → `https://site.tawanperry.top`
2. Route 53 → ALB (HTTPS, ACM cert)
3. ALB → Target Group → EC2 instances (in private subnets)
4. EC2 instances (Apache/PHP/WordPress) → **RDS MySQL** in private subnets

Network layout:

- **VPC**: `10.0.0.0/16` (example; see `1-vpc.tf`)
- **Public subnets**: one per AZ, for:
  - ALB
  - NAT Gateway
- **Private subnets**: one per AZ, for:
  - EC2 web servers
  - RDS MySQL

This mirrors a real-world **PCI-oriented web app**: public entry point on the ALB, sensitive data (DB) in private subnets, and controlled east–west access via security groups.

---

## Files Overview

- `0-auth.tf` – AWS provider, region, and basic setup  
- `1-vpc.tf` – VPC definition  
- `2-subnets.tf` – Public and private subnets  
- `3-igw.tf` – Internet Gateway and public routing  
- `4-nat.tf` – NAT Gateway and private route table  
- `5-route.tf` – Route associations for public/private subnets  
- `6-sg01-all.tf` / `rds-sg.tf` – Security groups for ALB, EC2, and RDS  
- `2-ami.tf` – Data source for Amazon Linux 2 AMI  
- `7-launchtemplate.tf` – Launch template for EC2 instances (user data + SGs)  
- `8-targetgroup.tf` – ALB Target Group  
- `9-loadbalancer.tf` – Application Load Balancer + listeners (HTTP/HTTPS)  
- `10-autoscalinggroup.tf` – Auto Scaling Group configuration  
- `11-route53.tf` – Route 53 DNS records and ACM validation  
- `rds.tf` – RDS MySQL instance + DB subnet group  
- `outputs.tf` – Helpful outputs (ALB DNS, ASG name, RDS endpoint)  
- `variables.tf` – Input variables (DB name, username, password, etc.)

---

## Prerequisites

- AWS account with permissions for:
  - VPC, EC2, ALB, RDS, IAM, Route 53, ACM, NAT Gateway
- Registered domain in Route 53 (here: `tawanperry.top`)
- Terraform CLI installed (v1.x+)
- AWS credentials configured locally (`aws configure` or environment variables)

---

## How to Deploy

From inside the project folder:

```bash
terraform init
terraform validate
terraform plan
terraform apply
