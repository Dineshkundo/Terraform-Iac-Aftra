

# ✅ **1. Folder Structure Documentation**

This explains your current Terraform repo layout in a clear, production-ready format.

---

## 📁 **Repository Structure**

```
iac-terraform/
├── envs/
│   ├── dev/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── matching_service.tfvars
│   │   ├── kv.tfvars
│   │   ├── terraform.storage.tfvars
│   │   ├── vm.tfvars
│   └── test/
│   └── prod/
│
├── modules/
│   ├── vm/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── storage/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── kv/
│       ├── main.tf
│       └── variables.tf
│
└── README.md
```

---

## 📌 **Folder Purpose**

### ✔ `envs/<env-name>/`

Environment-specific deployment folders.

Each environment holds:

* backend configuration
* per-environment variables
* per-environment `.tfvars`
* environment-specific main.tf
* environment-specific secrets (NOT committed)

### ✔ `modules/`

Reusable building blocks for Terraform.

You already have:

* VM module
* Storage module
* Key Vault module

Each module contains:

* `main.tf` → logic
* `variables.tf` → inputs
* `outputs.tf` → module outputs

### ✔ Root Repo Files

* README.md
* Jenkins pipelines
* GitHub repo metadata

---

# ✅ **2. README.md for Pipeline (Production Grade)**

Here is a clean, copy-paste README for GitHub.

---

# 🚀 Terraform IaC – Automated CI/CD Pipeline (Jenkins)

This repository contains **Modular Terraform Infrastructure-as-Code** with a **Production-Grade Jenkins Pipeline** that supports:

✔ Multiple environments (dev/test/prod)
✔ Azure authentication using **MSI or Service Principal**
✔ Dynamic module deployment (VM, Storage, Key Vault)
✔ Targeted resource actions
✔ Safe destroy & apply confirmation
✔ Remote backend using Azure Storage

---

## 📁 Repository Structure

```
iac-terraform/
├── envs/
│   ├── dev/
│   ├── test/
│   └── prod/
├── modules/
│   ├── vm/
│   ├── kv/
│   └── storage/
```

---

## 🔐 Authentication Options

### **1. Managed Identity (Recommended)**

No credentials needed.

```hcl
USE_MSI = true
```

### **2. Service Principal via Key Vault**

Required KV secrets:

```
sp-client-id
sp-client-secret
tenant-id
subscription-id
```

---

## 🏗 Supported Terraform Actions

```
plan
apply
destroy
show
output
```

---

## 🚦 Jenkins Parameters

| Parameter  | Purpose                              |
| ---------- | ------------------------------------ |
| ENV        | Environment folder (dev/test/prod)   |
| ACTION     | Terraform action                     |
| TFVARS     | tfvars file for selected environment |
| TARGET     | Terraform target (optional)          |
| USE_MSI    | MSI or Key Vault Auth                |
| KV_NAME    | Key Vault name                       |
| GIT_URL    | Repo URL                             |
| GIT_BRANCH | Git branch                           |

---

## ▶ Running the Pipeline

Choose values like:

```
ENV = dev
ACTION = apply
TFVARS = matching_service.tfvars
TARGET =
USE_MSI = true
```

---

## 💣 Safety Features

* Confirmation prompt before **apply**
* Confirmation prompt before **destroy**
* No credential leaks
* Workspace automatically cleaned
* State locked by backend

---

# 💼 Use Cases

* Multi-environment Azure infrastructure
* Automated VM rollout
* Key Vault management
* Storage accounts with firewall & VNets
* Enterprise IaC delivery pipeline

---

# 🧩 Troubleshooting

Check state lock:

```
az storage blob show \
  --account-name <storage> \
  --container-name tfstate \
  --name dev.terraform.tfstate \
  --query properties.lease
```

Break lock:

```
az storage blob lease break ...
```

---

# 🏁 End

---

# ✅ **3. Visual Workflow Diagram**

Here is a simple ASCII (text-based) diagram — I can also generate a PNG/Visio-style diagram if you want.

```
                 +------------------------+
                 |   Jenkins Pipeline     |
                 +-----------+------------+
                             |
                             v
                 +------------------------+
                 |  Checkout Git Repo     |
                 +-----------+------------+
                             |
                             v
                 +------------------------+
                 | Azure Login (MSI/SP)   |
                 +-----------+------------+
                             |
                             v
                 +------------------------+
                 |  Terraform Init        |
                 +-----------+------------+
                             |
                             v
                 +------------------------+
                 | Validate & Format TF   |
                 +-----------+------------+
                             |
                             v
        +--------------------+-------------------+
        |                    |                   |
        v                    v                   v
   terraform plan      terraform apply      terraform destroy
        |                    |                   |
        +--------------------+-------------------+
                             |
                             v
                 +------------------------+
                 | terraform show/output  |
                 +-----------+------------+
                             |
                             v
                 +------------------------+
                 | Workspace Cleanup      |
                 +------------------------+
```
