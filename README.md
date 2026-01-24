# 🏦 FinTech Infrastructure as Code (AWS & Terraform)

![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Status](https://img.shields.io/badge/Status-Production--Ready-success?style=for-the-badge)

## 📋 Project Overview

This repository hosts the **Infrastructure as Code (IaC)** for a FinTech application. It uses **Terraform** to provision a highly available, modular, and secure environment on AWS.

The project demonstrates modern DevOps practices, including **Modular Architecture**, **Remote State Management** (with locking), and **Immutable Infrastructure** principles.

---

## 🏗️ Architecture

The infrastructure is designed with a "Module-First" approach:

* **Networking Module:** Deploys a custom VPC `10.0.0.0/16` with isolated Public/Private subnets and Route Tables.
* **Compute Module:** Deploys EC2 instances with dynamic AMI lookups (Ubuntu) and automated Security Group attachments.
* **State Management:** Uses AWS S3 for remote state storage and DynamoDB for state locking to prevent race conditions in team environments.

---

## 🚀 Prerequisites (Bootstrapping)

> **⚠️ Important:** To solve the "Chicken and Egg" problem of Terraform state, the Backend resources must be provisioned manually before running this code.

Before running `terraform init`, ensure you have the following AWS resources created:

1. **S3 Bucket:** `fintech-terraform-state-voncleph` (Versioning & Encryption Enabled)
2. **DynamoDB Table:** `fintech-terraform-locks` (Partition Key: `LockID`)

---

## 🛠️ Usage Guide

### 1. Initialize

Download providers and configure the Remote Backend.

```bash
terraform init
```

### 2. Plan

Preview the infrastructure changes before applying.

```bash
terraform plan
```

### 3. Deploy

Provision the full stack.

```bash
terraform apply
```

## 📂 Directory Structure

```
.
├── modules/
│   ├── ec2/          # Compute logic (Instances, SG)
│   └── vpc/          # Networking logic (VPC, Subnets, IGW)
├── backend.tf        # S3 Remote State configuration
├── main.tf           # Root module (Orchestrator)
├── variables.tf      # Global input variables
└── outputs.tf        # Critical endpoints (IPs, DNS)
```

## 🤝 Outputs

After deployment, Terraform will output:

* `server_public_ip`: The IP address of the application server.
* `s3_bucket_name`: The ID of the application data bucket.


---

## 🏆 Best Practices Implemented
This project adheres to strict DevOps standards:

1.  **Remote State Management:**
    * State is stored in **S3** (not local disk) to enable team collaboration.
    * **DynamoDB Locking** is enabled to prevent race conditions during concurrent deployments.
    * **Versioning** is active on the S3 bucket to allow state recovery in case of corruption.

2.  **Modular Architecture:**
    * Resources are grouped into reusable modules (`modules/vpc`, `modules/ec2`) to adhere to the **DRY (Don't Repeat Yourself)** principle.
    * The root module acts strictly as an orchestrator, passing variables down to child modules.

3.  **Security & Safety:**
    * **No Hardcoded Secrets:** All sensitive values are passed via variables or environment variables.
    * **Least Privilege:** Security Groups are scoped to specific ports (80/22) rather than opening all traffic.

4.  **Code Quality:**
    * All code is formatted using `terraform fmt -recursive` for consistent style.
    * Inputs are strictly typed (`type = string`) with descriptive comments to ensure maintainability.
