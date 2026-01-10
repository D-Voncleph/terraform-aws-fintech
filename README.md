# 🏦 FinTech Infrastructure as Code (IaC)

This repository contains the Terraform configuration for a secure, scalable FinTech application infrastructure on AWS.

The project has been refactored from a monolithic script into a **Modular Architecture**, ensuring separation of concerns, reusability, and easier maintenance.

---

## 🏗️ Architecture

### Network Diagram

`User` -> `Internet Gateway` -> `Public Route Table` -> `Public Subnet` -> `EC2 App Server`

* **VPC:** Custom isolated network `10.0.0.0/16`
* **Public Subnet:** Hosts the Web Server `10.0.1.0/24`
* **Private Subnet:** Reserved for future Database `10.0.2.0/24`
* **Compute:** Ubuntu 22.04 EC2 Instance (Auto-scaling ready)
* **Storage:** S3 Bucket for product images

---

## 🧱 Modular Structure

This project is organized into reusable modules, separating the "Orchestrator" (Root) from the "Logic" (Modules).

```text
.
├── main.tf                 # 🧠 The Orchestrator (Calls the modules)
├── variables.tf            # ⚙️ Global Configuration
├── outputs.tf              # 📤 Global Outputs
└── modules/
    ├── vpc/                # 🔌 Networking Module
    │   ├── main.tf         # (VPC, Subnets, IGW, Route Tables)
    │   ├── variables.tf    # (Inputs: CIDR blocks, AZs)
    │   └── outputs.tf      # (Exports: VPC ID, Subnet IDs)
    └── ec2/                # 💻 Compute Module
        ├── main.tf         # (Instance, Security Group, AMI Lookup)
        ├── variables.tf    # (Inputs: Instance Type, Subnet ID)
        └── outputs.tf      # (Exports: Public IP)
```

## 🚀 Usage

### Prerequisites

* Terraform installed
* AWS CLI configured with credentials

### 1. Initialize

Download the provider plugins and initialize the modules.

```bash
terraform init
```

### 2. Plan

Preview the infrastructure changes.

```bash
terraform plan
```

### 3. Deploy

Provision the infrastructure.

```bash
terraform apply
```

## ⚙️ Configuration

You can customize the deployment by passing variables at runtime without editing the code.

| Variable | Description | Default |
| :--- | :--- | :--- |
| `aws_region` | AWS region to deploy resources into. | `eu-north-1` |
| `instance_type` | EC2 instance size. | `t3.micro` |
| `project_name` | Tag prefix for all resources. | `FinTech-IaC` |

### Example: Deploying a larger server

```bash
terraform apply -var="instance_type=t3.medium"
```

### Example: Deploying to a different region

```bash
terraform apply -var="aws_region=us-east-1"
```

## ♻️ Module Reusability

The core value of this architecture is Portability. The `modules/vpc` directory is designed to be a standalone product.

**Example:** If you wanted to reuse the network stack for a completely different project (e.g., a "Healthcare App"), you could simply reference the module like this:

```terraform
module "healthcare_network" {
  source = "./modules/vpc"

  # Override inputs for the new project
  vpc_cidr           = "10.20.0.0/16"
  public_subnet_cidr = "10.20.1.0/24"
  project_name       = "Healthcare-App"
}
```

## 📤 Outputs

After deployment, Terraform will output the following connection details:

* `server_public_ip`: The public IP address of the EC2 instance.
* `s3_bucket_name`: The unique name of the created S3 bucket.


---

## 🔐 State Management (Remote Backend)

This infrastructure uses a **Remote Backend** to store the Terraform state file, replacing the default local file. This ensures:
1.  **Collaboration:** All team members read/write to the same "Single Source of Truth."
2.  **Safety:** State Locking prevents two developers from overwriting each other's work simultaneously.

### Architecture
* **Storage (S3):** The `terraform.tfstate` file is stored in an encrypted S3 bucket.
* **Locking (DynamoDB):** A DynamoDB table tracks active sessions. If `terraform apply` is running, the table "locks" the state until the process finishes.

### ⚠️ Bootstrapping (Prerequisites)
The backend resources are **not** managed by Terraform itself (to avoid the "Chicken and Egg" problem). They must be provisioned manually before initializing the project.

**Required Resources:**
1.  **S3 Bucket:** `fintech-terraform-state-voncleph` (Must have Versioning enabled)
2.  **DynamoDB Table:** `fintech-terraform-locks` (Partition Key: `LockID`)

### Initialization
To configure the backend connection:
```bash
terraform init
