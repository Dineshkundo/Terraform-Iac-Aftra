# 📘 **README.md – Complete Terraform + Jenkins Dynamic Pipeline Guide**

## 🏗️ **1. Repository Structure**

Your repository is structured like this:

```
Terraform-Iac-Aftra/
│
├── backend.tf                 → Defines remote backend (Azure storage)
├── main.tf                    → Loads all modules dynamically
├── variables.tf               → Global variables for all modules
│
├── envs/
│   ├── dev/
│   │   ├── dynamic.tfvars
│   │   └── matching_service.tfvars
│   ├── test/
│   └── prod/
│
└── modules/
    ├── storage/
    ├── keyvault/
    └── virtual_machine/
```

### 🔥 **Meaning**

| Folder/File  | Purpose                                      |
| ------------ | -------------------------------------------- |
| `backend.tf` | Uses Azure Storage to store Terraform state  |
| `envs/<env>` | Contains `.tfvars` for each environment      |
| `modules/*`  | Reusable Terraform modules (VM, KV, Storage) |
| `main.tf`    | Loads modules using `for_each` dynamically   |

---

# ☁️ 2. **Backend Setup – Remote State**

Your `backend.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "CODA_RG"
    storage_account_name = "codadevsa"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
```

### ✔ Why this matters

Terraform will **not** store `terraform.tfstate` locally.
Instead, the pipeline reads and writes state to:

```
Azure → codadevsa → container tfstate → dev.terraform.tfstate
```

This enables:

* team collaboration
* safe apply
* no state conflicts
* same state for Jenkins + local CLI

---

# 🔄 3. **Dynamic Modules in main.tf**

Your modules use **maps + for_each** meaning:

* You can deploy many VMs, many storage accounts, many keyvaults
* Simply by adding values in `.tfvars`
* Without changing any Terraform code

Example:

```hcl
module "virtual_machine" {
  for_each = var.deploy_vm ? var.virtual_machines : {}
  source   = "./modules/virtual_machine"
  ...
}
```

### ✔ Why this is powerful

If tomorrow you add:

```hcl
virtual_machines = {
  vm1 = { ... }
  vm2 = { ... }
  vm3 = { ... }
}
```

Terraform automatically deploys **3 VMs**.

---

# 📁 4. **TFVARS Structure (Per Environment)**

Example:

```
envs/dev/matching_service.tfvars
envs/dev/dynamic.tfvars
```

Each file contains:

* which module to deploy
* properties required by that module
* resource-specific configuration

You can create unlimited `.tfvars` without pipeline changes.

---

# ⚙️ 5. **Dynamic Jenkins Pipeline (Simple & Clean)**

Your final working Jenkinsfile:

```groovy
pipeline {
  agent any

  parameters {
    choice(name: 'ENV', choices: ['dev','test','prod'], description: 'Environment folder')
    choice(name: 'ACTION', choices: ['plan','apply','destroy'], description: 'Terraform action')
    booleanParam(name: 'AUTO_APPROVE', defaultValue: false, description: 'Skip confirmation?')
  }

  stages {

    stage('Checkout') {
      steps {
        cleanWs()
        git branch: 'main', url: 'https://github.com/Dineshkundo/Terraform-Iac-Aftra.git'
      }
    }

    stage('Discover Config') {
      steps {
        script {
          def moduleList = sh(
            script: "ls -1 modules",
            returnStdout: true
          ).trim().split("\n")

          def tfvarsList = sh(
            script: "ls envs/${params.ENV}/*.tfvars | xargs -n1 basename",
            returnStdout: true
          ).trim().split("\n")

          properties([
            parameters([
              choice(name: 'ENV', choices: ['dev','test','prod']),
              choice(name: 'ACTION', choices: ['plan','apply','destroy']),
              booleanParam(name: 'AUTO_APPROVE', defaultValue: false),

              choice(name: 'MODULE', choices: moduleList.join("\n"), description: 'Select module'),
              choice(name: 'TFVARS_FILE', choices: tfvarsList.join("\n"), description: 'Select tfvars')
            ])
          ])
        }
      }
    }

    stage('Azure Login') {
      steps {
        sh "az login --identity >/dev/null"
      }
    }

    stage('Init') {
      steps {
        sh "terraform init"
      }
    }

    stage('Terraform Execute') {
      steps {
        script {
          def tfvars = "envs/${params.ENV}/${params.TFVARS_FILE}"
          def target = "-target=module.${params.MODULE}"

          if (params.ACTION == "plan") {
            sh "terraform plan -var-file=${tfvars} ${target}"
          }

          if (params.ACTION == "apply") {
            if (!params.AUTO_APPROVE) {
              input message: "Confirm APPLY for module ${params.MODULE} ?", ok: "Apply"
            }
            sh "terraform apply -auto-approve -var-file=${tfvars} ${target}"
          }

          if (params.ACTION == "destroy") {
            if (!params.AUTO_APPROVE) {
              input message: "Confirm DESTROY for module ${params.MODULE} ?", ok: "Destroy"
            }
            sh "terraform destroy -auto-approve -var-file=${tfvars} ${target}"
          }
        }
      }
    }
  }
}
```

---

# 🔍 6. **How Jenkins Pipeline Works (Step-by-Step)**

### **Step 1 — Checkout Code**

Pulls your GitHub repo fresh.

---

### **Step 2 — Discover Config**

Automatically detects:

* All modules under `modules/`
* All `.tfvars` under the selected `envs/<env>`

Then it dynamically **adds parameters to the job**:

* MODULE → (virtual_machine, storage, keyvault)
* TFVARS_FILE → (matching_service.tfvars, dynamic.tfvars)

No need to edit pipeline when adding new modules/tfvars.

---

### **Step 3 — Azure Login (MSI)**

Jenkins VM logs into Azure using:

```
az login --identity
```

MSI (Managed Identity) → no passwords → production standard.

---

### **Step 4 — Terraform Init**

Initializes the Azure backend:

```
terraform init
```

This automatically loads:

* backend.tf
* providers
* remote state file

---

### **Step 5 — Terraform Plan / Apply / Destroy**

#### Plan

```
terraform plan -var-file=envs/dev/matching_service.tfvars -target=module.virtual_machine
```

#### Apply (with optional confirmation)

```
terraform apply -auto-approve -var-file=... -target=...
```

#### Destroy

```
terraform destroy -auto-approve -var-file=... -target=...
```

---

# 🧠 7. **Why We Use -target=module.<module>**

Because your modules are dynamic (`for_each`).
Terraform doesn’t know which instance to run unless you specify a target.

Example:

```
module.virtual_machine["matching_service"]
```

Your pipeline simplifies to:

```
-target=module.virtual_machine
```

You choose the module + tfvars in Jenkins UI.

---

# 🎯 8. **How to Add New Resources (Zero Pipeline Changes)**

👉 Add a new `.tfvars` under environment
👉 Or add a new folder inside `modules/`

Pipeline auto-detects everything.

No code changes needed.

---

# 🚀 9. **How to Deploy a VM Example**

### Step 1 — Jenkins Parameters

```
ENV = dev
ACTION = plan / apply
MODULE = virtual_machine
TFVARS_FILE = matching_service.tfvars
```

### Step 2 — Run Build

Terraform will deploy only that VM.

---
# 🛠 Troubleshooting Remote State (Azure Blob Lease Lock)
```
Sometimes Terraform leaves a state lock during:

Jenkins job crash

Partial apply

Network interruption

This results in:

Error acquiring state lock
Blob is currently leased

🔍 1. Check the lease state
az storage blob show \
  --account-name codadevsa \
  --container-name tfstate \
  --name dev.terraform.tfstate \
  --query properties.lease

If output shows "leased" → lock exists
If "unlocked" → safe to continue
🔓 2. Break the Lease (Safe Reset)
az storage blob lease break \
  --account-name codadevsa \
  --container-name tfstate \
  --blob-name dev.terraform.tfstate \
  --auth-mode login


Wait a few seconds.

✔ 3. Verify Again
az storage blob show \
  --account-name codadevsa \
  --container-name tfstate \
  --name dev.terraform.tfstate \
  --query properties.lease


Should return:

"unlocked"
```
# 📌 11. **Common Questions**

### **Q1: Why does apply sometimes show “No changes”?**

Because the VM already exists and nothing changed.

---

### **Q2: Does Jenkins and Terraform CLI share the same state?**

Yes. They use Azure backend → same terraform state.

---

### **Q3: Why not check out envs/dev inside a path?**

You run Terraform from root → it loads all modules → correct usage.


