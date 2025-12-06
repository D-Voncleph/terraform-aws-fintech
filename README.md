# Terraform AWS FinTech Infrastructure

This repository contains **Infrastructure as Code (IaC)** configurations to provision cloud resources for the FinTech project. It uses **Terraform** to manage AWS resources in a declarative, version-controlled manner.

## 🏛️ Architecture

Currently, this project provisions storage infrastructure:

* **AWS S3 Bucket:** A secure, private bucket for storing e-commerce product images `voncleph-ecommerce-product-images`.

## 🛠️ Prerequisites

* **Terraform:** [Install Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.0+)
* **AWS CLI:** [Install AWS CLI](https://aws.amazon.com/cli/)
* **AWS Account:** An active AWS account with permission to create S3 buckets.

## 🔐 Setting Up AWS Credentials

Terraform needs permission to talk to your AWS account. The recommended way to set this up locally is using the AWS CLI.

1. **Run the configuration command:**
   ```bash
   aws configure
   ```

2. **Enter your credentials:**
   * **AWS Access Key ID:** `YOUR_ACCESS_KEY`
   * **AWS Secret Access Key:** `YOUR_SECRET_KEY`
   * **Default region name:** `eu-north-1` (Match the region in main.tf)
   * **Default output format:** `json`

Terraform will automatically detect these credentials stored in `~/.aws/credentials`.

---

## 🚀 Usage Guide

Follow the standard Terraform workflow (The "Core Loop") to provision infrastructure.

### 1. Initialize

Downloads the AWS provider plugins and sets up the project. Run this once per project.

```bash
terraform init
```

### 2. Plan (Dry Run)

Previews the changes Terraform will make. Always run this before applying.

```bash
terraform plan
```

Look for green `+` signs indicating resources to be created.

### 3. Apply (Deploy)

Provisions the actual infrastructure on AWS.

```bash
terraform apply
```

Type `yes` when prompted to confirm.

## 🛑 Cleanup (Destroy)

To tear down the infrastructure and stop incurring costs, use the destroy command. 

**Warning:** This will delete the bucket and all data inside it.

```bash
terraform destroy
```

Type `yes` to confirm.
