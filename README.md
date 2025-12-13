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





## 🧩 Resource Details

### 1. Compute Layer (`aws_instance`)
The application runs on a single EC2 instance defined as `aws_instance.app_server`.

* **`ami` (Amazon Machine Image):**
    * **Strategy:** Dynamic Lookup.
    * **Description:** Instead of hardcoding an AMI ID (which varies by region and becomes obsolete), we use a **Data Source** (`data.aws_ami.ubuntu`) to fetch the latest **Ubuntu 22.04 LTS** image from Canonical at runtime. This ensures the server always launches with the latest security patches.

* **`instance_type`:**
    * **Value:** `t3.micro`
    * **Reasoning:** Chosen for cost-efficiency in the `eu-north-1` (Stockholm) region. It provides sufficient CPU burst capability for a development/staging web server.

* **`vpc_security_group_ids`:**
    * **Description:** Attaches the `fintech-app-sg` firewall.
    * **Rules:**
        * **Ingress 22 (SSH):** For administrative access.
        * **Ingress 80 (HTTP):** For public web traffic.
        * **Egress All:** Allows the server to download updates and packages.

* **`tags`:**
    * **Description:** Metadata (`Name`, `Project`, `Environment`) used for cost allocation and resource organization in the AWS Console.

### 2. Storage Layer (`aws_s3_bucket`)
* **Bucket Name:** `voncleph-ecommerce-product-images`
* **Purpose:** persistent object storage for application assets.
* **Configuration:** `force_destroy = true` is enabled to allow automated teardowns during the development phase.
