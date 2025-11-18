📘 AWS WordPress + ALB + Auto Scaling Group (ASG)
Status: In Progress — Paused for Now

This project is my attempt to deploy a high-availability WordPress environment on AWS using:

Launch Templates

Auto Scaling Groups

Application Load Balancer

Private Subnets (EC2)

Public Subnets (ALB)

Route 53 (Custom Domain)

The goal is to build a full WordPress site that:

Automatically scales with traffic

Is secure and PCI-ready

Uses a real domain (site.tawanperry.top)

Loads through an ALB with HTTPS

Survives instance failures using ASG

This is a multi-day project, and today’s session ended at a natural stopping point.

✅ What Worked
✔ VPC + Subnets

Public subnets created for ALB

Private subnets created for EC2

Internet Gateway + public routes

NAT Gateway avoided (intentionally)

✔ Application Load Balancer

Successfully deployed

HTTPS certificate validated

ALB DNS working with Route 53

✔ Auto Scaling Group

ASG launched multiple EC2 instances

Health checks worked

Instances correctly registered to ALB target group

Launch Template using Amazon Linux AMI created successfully

✔ User Data

Apache installed

WordPress downloaded

Permissions fixed

Site reachable through ALB

❌ What Failed (Current Blocker)
❌ WordPress cannot connect to a database

The ASG instances are in private subnets with no public IP, which is correct for security — but:

We could not SSH into the instance

We could not install MySQL manually

WordPress cannot complete setup

RDS was not configured yet

Result: “Error establishing a database connection”

This is expected because no database exists yet.

🎯 Next Steps (Tomorrow)
Option 1: Deploy RDS MySQL (Recommended)

Create RDS MySQL database

Add ASG SG to RDS inbound

Update WordPress config

No SSH needed

PCI friendly

Option 2: Make one instance public temporarily

Add public IP

SSH in

Install MariaDB manually

Complete WP setup

Then revert to private subnets

Option 3: Build a simplified 1-EC2 WordPress

Skip ASG

Get WordPress working

Add ASG later

🔥 Teardown Instructions (Destroy EVERYTHING)

This avoids overnight AWS charges.

1️⃣ Delete Auto Scaling Group

EC2 → Auto Scaling Groups → Select ASG → Delete

2️⃣ Delete Launch Template

EC2 → Launch Templates → Select → Delete template

3️⃣ Delete Load Balancer

EC2 → Load Balancers → Select ALB → Delete

4️⃣ Delete Target Group

EC2 → Target Groups → Select → Delete

5️⃣ Delete EC2 Instances

EC2 → Instances → select any running instances → Terminate

6️⃣ Delete Security Groups (optional)

Only delete ones you created (won’t delete if still attached).

7️⃣ Delete subnets + route tables + IGW (optional)

If you want a clean restart:

Delete the IGW

Delete route tables

Delete subnets

Delete the VPC

8️⃣ Delete the domain records in Route 53 (optional)

Keep the domain itself, but remove A/AAAA/CNAME if desired.
