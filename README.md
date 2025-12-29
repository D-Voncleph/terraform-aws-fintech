# 🏛️ Network Architecture

This project provisions a custom **Virtual Private Cloud (VPC)** to host the FinTech application securely, replacing the default AWS network.

## 🗺️ The Network Diagram
Traffic Flow: `User` -> `Internet Gateway` -> `Public Route Table` -> `Public Subnet` -> `EC2 App Server`

* **VPC CIDR:** `10.0.0.0/16` (The isolated network container)
* **Public Subnet:** `10.0.1.0/24` (Hosts the web server; has direct internet access)
* **Private Subnet:** `10.0.2.0/24` (Reserved for future database; no direct internet access)

## 📂 Code Structure

The Infrastructure as Code (IaC) is modularized into specific files for maintainability:

| File | Purpose |
| :--- | :--- |
| **`network.tf`** | **The Plumbing.** Defines the VPC, Subnets, Internet Gateway, and Route Tables. This is the physical network layer. |
| **`main.tf`** | **The Application.** Defines the Compute (EC2) and Storage (S3) resources that live *inside* the network. |
| **`variables.tf`** | **The Inputs.** Defines configuration parameters (Region, Instance Type, Project Name) to make the code reusable. |
| **`outputs.tf`** | **The Outputs.** Returns critical data to the CLI after deployment (e.g., Server IP, VPC ID). |
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



# ⚙️ Configuration & Customization

This project uses **Terraform Variables** to allow customization without editing the source code. You can modify the region, instance size, or project tags at runtime.

## Input Variables (`variables.tf`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `aws_region` | The AWS region to deploy resources into. | `eu-north-1` |
| `instance_type` | The EC2 instance size. | `t3.micro` |
| `project_name` | The project tag applied to all resources. | `FinTech-IaC` |

## How to Override Defaults

You do not need to edit `variables.tf` to change these values. You can override them using the `-var` flag in the CLI.

**Example: Deploying a larger server:**

```bash
terraform apply -var="instance_type=t3.medium"
```

**Example: Deploying to a different region:**

```bash
terraform apply -var="aws_region=us-east-1"
```

## 📤 Outputs

After the deployment finishes, Terraform will output the following connection details:

* `server_public_ip`: The public IP address of the EC2 instance.
* `s3_bucket_name`: The unique name of the created S3 bucket.

---

## Step 3: Commit and Push

Save the file (`Ctrl+O`, `Enter`, `Ctrl+X`) and push to GitHub.

```bash
git add README.md
git commit -m "Docs: Add variable configuration table and usage examples"
git push origin main
```
