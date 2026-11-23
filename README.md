# 🛡️ Terraform State Governance: Remote Backends, Locking & Drift

![Terraform Version](https://img.shields.io/badge/Terraform-1.5%2B-blue.svg?logo=terraform)
![Azure Provider](https://img.shields.io/badge/AzureRM-3.100%2B-0078D4.svg?logo=microsoft-azure)
![IaC](https://img.shields.io/badge/IaC-State%20Management-623CE4.svg)
![Validation](https://img.shields.io/badge/Validation-Pass-success.svg)

> **Repository 06 of 08 in the Terraform + Microsoft Azure Professional Learning Series**

---

## 📌 Navigation
| ⏪ Previous Repository | 📚 Current Repository | ⏩ Next Repository |
| :--- | :---: | :--- |
| [← 05. terraform-azure-nested-maps-and-dependencies](https://github.com/vishalnik002-git/terraform-azure-nested-maps-and-dependencies) | **06. terraform-azure-state-management** | [07. terraform-azure-modules-and-reuse →](https://github.com/vishalnik002-git/terraform-azure-modules-and-reuse) |

---

## 📖 Project Overview

The **Terraform State File** (`terraform.tfstate`) is the single source of truth that maps your declarative HCL code to real infrastructure objects in Microsoft Azure.
Without a state file, Terraform cannot know which resources exist, what their IDs are, or what changes are required.

This repository covers:
1. **Local vs Remote State**: Why local state files cannot be used in collaborative engineering teams.
2. **Azure Remote Backend**: Configuring Azure Blob Storage (`azurerm` backend) to store state remotely.
3. **State Locking**: How Azure Blob Lease locking prevents race conditions and concurrent write corruption.
4. **State Drift & No-Drift**: How Terraform audits differences between declared code and real cloud reality.
5. **State Inspection & Maintenance**: Using `terraform state list`, `show`, `mv`, `import`, and `force-unlock`.

> ℹ️ **Learning Note**: This repository contains learning configurations and documentation. Automated validation checks verify HCL syntax with `-backend=false` without requiring active cloud storage or provisioning live Azure resources.

---

## 🎯 Learning Objectives

By exploring this repository, you will understand:
1. The internal JSON structure of the `.tfstate` file and why it must never be committed to Git.
2. The architectural pattern for **bootstrapping** a remote backend (Storage Account + Container) separately from workload resources.
3. How Azure Blob Storage enforces **State Locking** using Azure Storage blob leases during plan and apply operations.
4. The definition of **State Drift** and **No-Drift** (when desired state matches actual cloud state perfectly).
5. Essential CLI commands for state maintenance without manual file edits:
   - `terraform state list`: List all resources tracked in state.
   - `terraform state show <addr>`: Inspect metadata of a single resource.
   - `terraform state mv <src> <dest>`: Rename resources in state without destroying them.
   - `terraform import <addr> <id>`: Bring existing Azure resources under Terraform management.
   - `terraform force-unlock <id>`: Release an abandoned state lock safely.

---

## 🏗️ Remote State & Locking Architecture

```
+-------------------------------------------------------------------------+
|                  Team Collaboration & Remote State                      |
+-------------------------------------------------------------------------+
        |                                                 |
   DevOps Engineer A                                 DevOps Engineer B
  [ terraform apply ]                               [ terraform apply ]
        |                                                 |
        +-------------------+     +-----------------------+
                            |     |
                            v     v
             +---------------------------------------+
             |       Azure Blob Remote Backend       |
             |  Resource Group: rg-terraform-tfstate |
             |  Storage Account: sttfstatebackend01  |
             |  Container: tfstate                   |
             |  Blob: production.workload.tfstate    |
             |---------------------------------------|
             |  [ LOCK GRANTED to Engineer A ]       |  --> Engineer B is locked out
             |  (Azure Storage Blob Lease Active)    |      until Engineer A completes.
             +---------------------------------------+
```

---

## 📂 Repository Structure

```
terraform-azure-state-management/
├── .github/
│   └── workflows/
│       └── validate.yml          # Automated CI validation pipeline
├── examples/
│   ├── 01-local-state-workflow/  # Local state file concepts and behavior
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── 02-remote-backend-bootstrap/ # Terraform code to provision the backend storage
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   └── versions.tf
│   └── 03-workload-backend-configuration/ # How workload code consumes the backend
│       ├── backend.tf.example    # Production backend template
│       ├── main.tf
│       ├── outputs.tf
│       └── versions.tf
├── .gitignore                    # Strictly excludes *.tfstate and *.tfvars
├── main.tf                       # Primary state governance demo
├── outputs.tf                    # Resource outputs
├── providers.tf                  # AzureRM provider configuration
├── terraform.tfvars.example      # Example input parameters
├── variables.tf                  # Parameterized configuration
├── versions.tf                   # Version constraint declarations
└── README.md                     # Comprehensive documentation
```

---

## 🧩 Technical Deep Dive

### 1. Why Remote State is Essential
If state is stored locally on an engineer's laptop:
- **No Team Sharing**: Other team members cannot see or modify existing resources.
- **Merge Conflicts & Corruption**: Multiple engineers running apply simultaneously overwrite each other's state.
- **Security Vulnerability**: Unencrypted local files can expose sensitive values.

### 2. Azure Blob Backend Configuration
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-tfstate"
    storage_account_name = "sttfstatebootstrap01"
    container_name       = "tfstate"
    key                  = "production.workload.tfstate"
  }
}
```
When configured, Terraform acquires a blob lease on `production.workload.tfstate` before any operation. If another engineer initiates an apply, Terraform informs them that the state is locked, preventing concurrent corruption.

### 3. Understanding State Drift
- **State Drift**: Occurs when cloud resources are modified outside of Terraform (e.g. manually via Azure Portal or Azure CLI).
- **No-Drift**: A condition where `terraform plan` confirms that the declared configuration exactly matches the actual infrastructure discovered in Azure (`No changes. Your infrastructure matches the configuration.`).

---

## 🛠️ Step-by-Step Getting Started Guide

### Prerequisites
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (v1.5.0+).

### 1. Format Code
```bash
terraform fmt
```

### 2. Initialize with Backend Disabled (Local Validation)
```bash
terraform init -backend=false
```

### 3. Validate Configuration
```bash
terraform validate
```

### 4. Review Plan (Educational Documentation)
```bash
terraform plan -var-file="terraform.tfvars.example"
```

### 5. Apply Changes (Educational Documentation)
```bash
terraform apply
```
> ⚠️ **IMPORTANT**: In production, `terraform apply` requires manual confirmation. In this educational repository, no cloud deployment is executed.

---

## 🔄 Terraform Resource Lifecycle & Destruction Concepts

1. **State-Driven Destruction**:
   `terraform destroy` relies exclusively on the state file to locate resources in Azure. If a state file is deleted or lost, Terraform can no longer track or destroy those resources, leaving orphaned infrastructure in your subscription.
2. **Never Edit State Files Manually**:
   Directly editing `terraform.tfstate` with a text editor can corrupt JSON checksums. Always use built-in CLI commands like `terraform state mv` or `terraform state rm`.
3. **Safe State Unlocking**:
   If a CI/CD job crashes while holding a lock, verify that no background job is running before executing `terraform force-unlock <LOCK-ID>`.

---

## 🤖 CI/CD Automation (GitHub Actions)

This repository includes automated validation via `.github/workflows/validate.yml` that validates the root module and all 3 example directories using `terraform init -backend=false` and `terraform validate` on every push and pull request.

---

## 👨‍💻 Author Information

- **Developer**: Vishal Yadav (`vishalnik002-git`)
- **Education**: MCA @ Galgotias University (2025–2027) | BCA @ MGKVP (2022–2025)
- **Role**: DevOps Intern @ DevOps Insiders
- **GitHub Profile**: [https://github.com/vishalnik002-git](https://github.com/vishalnik002-git)
