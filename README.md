# 🔒 Terraform Remote State Backend with Azure Blob Storage

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?style=flat&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![State Locking](https://img.shields.io/badge/State_Locking-Enabled-brightgreen)](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage)

---

## 📌 Project Overview

This project sets up a **Remote State Backend** for Terraform using **Microsoft Azure Blob Storage**.

In a production or team environment, storing Terraform state locally (`terraform.tfstate`) is dangerous because:
1. Team members might overwrite each other's changes.
2. State files can contain sensitive configuration data.
3. Lack of automatic state locking can cause corrupted infrastructure.

This lab provisions the dedicated Azure storage infrastructure required to host Terraform remote state files securely with native **Blob Lease Locking**.

---

## 🏗️ Architecture & Resources Provisioned

```text
Microsoft Azure (Subscription)
  └── Resource Group: rg-vishal-tfstate (East US)
        └── Storage Account: stvishaltfstate01 (Standard_LRS)
              └── Blob Container: tfstate (Private Access)
                    └── Remote State File: *.tfstate (Blob Lease Lock)
```

1. **Azure Resource Group (`azurerm_resource_group.rg`):** Dedicated resource group (`rg-vishal-tfstate`) hosted in `East US`.
2. **Azure Storage Account (`azurerm_storage_account.storage`):** Storage account (`stvishaltfstate01`) with `Standard` tier and `LRS` (Locally Redundant Storage) replication.
3. **Private Blob Container (`azurerm_storage_container.container`):** Container named `tfstate` with `private` access type to store state files securely.

---

## 💡 Key DevOps Concepts Demonstrated

* **Remote Backend Storage:** Centralizing the state file in the cloud so all pipeline runs and team members share a single source of truth.
* **State Lease Locking:** Azure Blob Storage automatically uses blob leases to lock the state file during `terraform plan` and `terraform apply`. This prevents two engineers or pipelines from modifying the same infrastructure simultaneously.
* **Implicit Dependency:** The Storage Account depends on the Resource Group, and the Storage Container depends on the Storage Account ID (`storage_account_id = azurerm_storage_account.storage.id`). Terraform automatically builds this dependency graph.

---

## 📁 Repository Structure

```text
.
├── main.tf              # Resource definitions (RG, Storage Account, Container)
├── provider.tf          # AzureRM provider configuration
├── .gitignore           # Git ignore rules for state and secret files
└── README.md            # Project documentation
```

---

## 🚀 How to Run

### Prerequisites
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed and authenticated (`az login`)
* [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (>= 1.5.0)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/vishalnik002-git/terraform-remote-state-backend.git
cd terraform-remote-state-backend

# 2. Authenticate to Microsoft Azure
az login

# 3. Initialize Terraform (downloads azurerm provider)
terraform init

# 4. Preview the infrastructure plan
terraform plan

# 5. Provision the remote state infrastructure
terraform apply -auto-approve
```

---

## 🔗 How to Use This Backend in Other Terraform Projects

Once this infrastructure is created, any other Terraform project can store its state here by adding this block to its `provider.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-vishal-tfstate"
    storage_account_name = "stvishaltfstate01"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

---

## 🧹 Clean Up

To avoid unnecessary cloud billing when the lab is complete:

```bash
terraform destroy -auto-approve
```

---

## 👤 Author
* **Vishal Yadav** — [GitHub Profile](https://github.com/vishalnik002-git) | [LinkedIn](https://www.linkedin.com/in/vishal-yadav002)
