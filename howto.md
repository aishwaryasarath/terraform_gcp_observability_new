terraform-modules-gcp
├── environments
│   ├── dev
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── provider.tf
│   │   ├── terraform.tfvars
│   │   └── variables.tf
│   ├── modules
│   │   ├── compute_instance
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   └── gcs_bucket
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       └── variables.tf
│   ├── nonprod
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── provider.tf
│   │   ├── terraform.tfvars
│   │   └── variables.tf
│   └── prod
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── provider.tf
│       ├── terraform.tfvars
│       └── variables.tf
└── howto.md

```
mkdir -p environments/dev environments/nonprod environments/prod environments/modules/compute_instance environments/modules/gcs_bucket && touch environments/dev/{backend.tf,main.tf,outputs.tf,provider.tf,terraform.tfvars,variables.tf} environments/nonprod/{backend.tf,main.tf,outputs.tf,provider.tf,terraform.tfvars,variables.tf} environments/prod/{backend.tf,main.tf,outputs.tf,provider.tf,terraform.tfvars,variables.tf} environments/modules/compute_instance/{main.tf,outputs.tf,variables.tf} environments/modules/gcs_bucket/{main.tf,outputs.tf,variables.tf} howto.md
```
