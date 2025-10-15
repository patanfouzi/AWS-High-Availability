# High-Availability Infrastructure Deployment with Terraform & AWS
This repository contains scripts and Terraform configurations to set up a highly available, auto-scaling, and resilient infrastructure on AWS. The setup includes an Application Load Balancer (ALB), Auto Scaling Group (ASG), secure networking, monitoring, and backend state management for Terraform.

---
# Project Overview
High Availability & Auto-Scaling: Uses AWS ALB, ASG with targeted scaling policies, and multiple subnets across availability zones.

State Management: Automates creation of S3 bucket and DynamoDB table as a backend for Terraform, facilitating remote state locking and consistency.

Infrastructure as Code: All resources (VPC, subnets, NAT Gateway, security groups, launch templates, etc.) are managed via Terraform scripts.

Monitoring & Alerts: Configures CloudWatch alarms to track CPU utilization and sends notifications via SNS.

Secure & Resilient: Implements security groups, public/private subnets with NAT Gateway, IAM roles, and proper tagging for resource managemen

---

It provisions a highly available web application architecture with:
* ✅ VPC (Public & Private Subnets, IGW, NAT)
* ✅ Application Load Balancer (ALB)
* ✅ Auto Scaling Group (ASG)
* ✅ Launch Template from existing EC2 AMI
* ✅ IAM Roles, Instance Profiles & Policies
* ✅ CloudWatch Alarms + SNS Alerts
* ✅ S3 + DynamoDB for Terraform remote backend
* ✅ GitHub Actions workflow for automated provisioning

---

## 🧱 Architecture Overview

```
                    +---------------------------+
                    |     GitHub Actions CI/CD   |
                    +---------------------------+
                                  |
                                  v
                      +--------------------+
                      |  Terraform Backend  |
                      | (S3 + DynamoDB)     |
                      +--------------------+
                                  |
                                  v
                 +------------------------------------+
                 |               AWS VPC              |
                 |------------------------------------|
                 |  • Public Subnets (ALB, NAT)       |
                 |  • Private Subnets (EC2, ASG)      |
                 |  • Security Groups (ALB/App)       |
                 +------------------------------------+
                     |          |              |
                     |          |              |
                 +-------+   +-------+     +--------+
                 |  ALB  |→ | EC2s  | ... |  ASG    |
                 +-------+   +-------+     +--------+
```

---

## 📁 Repository Structure

| File                         | Description                                                |
| ---------------------------- | ---------------------------------------------------------- |
| `create-backend.sh`          | Creates S3 bucket and DynamoDB table for Terraform backend |
| `vpc.tf`                     | VPC, subnets, route tables, NAT, and IGW                   |
| `security.tf`                | Security Groups for ALB and application                    |
| `alb_asg.tf`                 | ALB, Target Group, Listeners, and Auto Scaling Group       |
| `launch_template.tf`         | Launch Template using AMI from existing instance           |
| `ami_from_instance.tf`       | Creates AMI from existing EC2 instance                     |
| `iam.tf`                     | IAM Roles, Policies, and Instance Profiles                 |
| `cloudwatch-alarams.tf`      | SNS Topic + CloudWatch Alarm setup                         |
| `providers.tf`               | Terraform provider configuration                           |
| `variables.tf`               | All input variables for Terraform                          |
| `terraform.tfvars`           | Variable values (region, VPC CIDR, instance settings)      |
| `outputs.tf`                 | Outputs (ALB DNS, ASG Name, AMI ID, VPC ID)                |
| `userdata.sh`                | User data script to install CloudWatch Agent on EC2        |
| `.github/workflows/main.yml` | GitHub Actions CI/CD pipeline                              |

---

## ⚙️ Prerequisites

Before using this repository, ensure you have:

* **AWS Account** with sufficient permissions
* **IAM User** with:

  * `AmazonS3FullAccess`
  * `AmazonDynamoDBFullAccess`
  * `AmazonEC2FullAccess`
  * `IAMFullAccess`
  * `CloudWatchFullAccess`
* **GitHub Secrets** configured:

| Secret Name      | Description                                  |
| ---------------- | -------------------------------------------- |
| `AWS_ACCESS_KEY` | Your AWS access key                          |
| `AWS_SECRET_KEY` | Your AWS secret key                          |
| `KEY_NAME`       | Name of the EC2 key pair used for SSH access |

---

## 🧑‍💻 Setup Instructions

### 1. Clone this Repository

```bash
git clone https://github.com/<your-username>/<your-repo-name>.git
cd <your-repo-name>
```

### 2. Initialize Backend (Optional Manual Run)

If not using GitHub Actions, you can manually create the backend:

```bash
chmod +x create-backend.sh
./create-backend.sh
```

### 3. Terraform Commands (Manual Option)

To apply from local machine:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### 4. Automated Deployment (GitHub Actions)

You can trigger deployment from **GitHub → Actions → Terraform Deploy → Run Workflow**.

The workflow:

1. Sets up AWS credentials
2. Creates backend (S3 + DynamoDB)
3. Runs `terraform init`, `plan`, and `apply`

---

## 📊 Outputs

After a successful run, Terraform provides:

| Output     | Description                               |
| ---------- | ----------------------------------------- |
| `alb_dns`  | DNS name of the Application Load Balancer |
| `asg_name` | Name of the Auto Scaling Group            |
| `ami_id`   | ID of the newly created AMI               |
| `vpc_id`   | ID of the created VPC                     |

---

## 🧩 Variables Overview

| Variable             | Description                              | Default     |
| -------------------- | ---------------------------------------- | ----------- |
| `aws_region`         | AWS region                               | `us-east-1` |
| `project`            | Project name prefix                      | `app`       |
| `source_instance_id` | Existing EC2 instance to create AMI from | —           |
| `min_size`           | Minimum ASG instances                    | `1`         |
| `desired_capacity`   | Desired ASG instances                    | `2`         |
| `max_size`           | Maximum ASG instances                    | `5`         |
| `alert_email`        | Email for SNS alerts                     | `""`        |
| `acm_cert_arn`       | Optional ACM certificate ARN for HTTPS   | `""`        |

---

## 🔔 Monitoring & Alerts

* CloudWatch alarms trigger when **CPU > 80%**.
* Alerts are sent via **SNS** to the email specified in `terraform.tfvars`.

---

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy -auto-approve
```
---
Runs backend setup, then terraform commands

