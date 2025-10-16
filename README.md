# terraform-eks

Terraform code to deploy a test application in Amazon EKS (Elastic Kubernetes Service).

## Overview

This repository contains reusable Terraform modules and scripts to provision an EKS cluster on AWS and deploy a sample/test application to it. The goal is to provide a straightforward way to set up EKS infrastructure for development or testing purposes.

## Features

- Automated EKS cluster provisioning using Terraform
- Configurable node groups and networking
- Shell scripts for cluster management and deployment
- Example/test application deployment
- Modular and reusable codebase

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with appropriate credentials
- [kubectl](https://kubernetes.io/docs/tasks/tools/) for interacting with the EKS cluster
- AWS account with permissions to create EKS resources

## Usage

1. **Clone the repository:**
    ```sh
    git clone https://github.com/muralikrishna-sunkara/terraform-eks.git
    cd terraform-eks
    ```

2. **Initialize Terraform:**
    ```sh
    terraform init
    ```

3. **Review and customize variables:**
    - Edit `variables.tf` and/or provide a `terraform.tfvars` file to override defaults.

4. **Plan the deployment:**
    ```sh
    terraform plan
    ```

5. **Apply the configuration:**
    ```sh
    terraform apply
    ```

6. **Configure kubectl:**
    - After successful apply, update your kubeconfig:
      ```sh
      aws eks --region <region> update-kubeconfig --name <cluster_name>
      ```

7. **Deploy the test app:**
    - Use provided scripts or Kubernetes manifests to deploy the sample app.

## Project Structure

```
.
├── modules/           # Reusable Terraform modules
├── scripts/           # Shell scripts for management
├── main.tf            # Primary Terraform configuration
├── variables.tf       # Input variables
├── outputs.tf         # Outputs from Terraform
└── README.md
```

## Cleanup

To destroy all resources created by this repository:

```sh
terraform destroy
```

## License

This project is licensed under the [MIT License](LICENSE).

---

**Author:** [muralikrishna-sunkara](https://github.com/muralikrishna-sunkara)

