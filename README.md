# Cloud Infrastructure Security with IaC Scanning

## 📌 Project Overview

This project demonstrates how Infrastructure as Code security scanning can prevent misconfigured AWS infrastructure from reaching deployment.

Terraform is used to provision AWS infrastructure, while Checkov scans Terraform code for security and compliance issues. GitHub Actions automatically executes the security checks and fails the pipeline when insecure configurations are detected.

## 🏗 Architecture

```text
Developer
    ↓
GitHub
    ↓
GitHub Actions
    ↓
Terraform Format
    ↓
Terraform Validate
    ↓
Checkov Security Scan
    ↓
Security Pass?
   ↙       ↘
 FAIL      PASS
  ↓          ↓
BLOCK    Terraform Plan
             ↓
       Secure AWS Infrastructure
```

## 🧰 Technologies

* Terraform
* AWS
* Amazon S3
* AWS IAM
* Amazon VPC
* Security Groups
* Checkov
* GitHub Actions
* Docker

## 🔐 Security Scenarios

### 1. Public S3 Bucket

The initial Terraform configuration intentionally allowed public access.

Checkov detected the insecure configuration.

The bucket was then secured using:

* S3 Public Access Block
* Server-side encryption
* Versioning

### 2. Open Security Group

The initial configuration allowed SSH traffic from:

```text
0.0.0.0/0
```

This was removed to prevent unrestricted internet access.

### 3. Over-Permissive IAM

The initial IAM policy used:

```text
Action: *
Resource: *
```

The policy was replaced with least-privilege permissions limited to the required S3 bucket.

## 🔄 DevSecOps Workflow

```text
Terraform Code
      ↓
Terraform Format
      ↓
Terraform Validate
      ↓
Checkov
      ↓
Security Policy Enforcement
      ↓
Terraform Plan
      ↓
AWS
```

## 🚨 Insecure Configuration

The project initially contains intentionally insecure infrastructure to demonstrate how IaC security scanning detects vulnerabilities.

Examples include:

* Public S3 access
* Open SSH security group
* Over-permissive IAM policy

The GitHub Actions pipeline fails when these security issues are detected.

## ✅ Secured Configuration

The final infrastructure implements:

* S3 public access blocking
* S3 server-side encryption
* S3 versioning
* Restricted network access
* IAM least privilege
* Automated IaC security scanning
* CI/CD security gates

## 🚀 Local Usage

Initialize Terraform:

```bash
terraform init
```

Format:

```bash
terraform fmt
```

Validate:

```bash
terraform validate
```

Run Checkov:

```bash
docker run --rm \
  -v "$(pwd):/tf" \
  bridgecrew/checkov \
  -d /tf
```

Create a Terraform plan:

```bash
terraform plan
```

Apply infrastructure:

```bash
terraform apply
```

Destroy the infrastructure when finished:

```bash
terraform destroy
```

## 🎯 Resume Impact

> Secured AWS infrastructure using Terraform, Checkov, and GitHub Actions by implementing automated IaC security scanning, least-privilege IAM, S3 security controls, and CI/CD policy enforcement.

## 💡 Key DevSecOps Concepts

* Infrastructure as Code Security
* Shift-left Security
* Security Gates
* Least Privilege
* AWS Security Best Practices
* CI/CD Security
* Automated Compliance Scanning
* Terraform Security
* Policy Enforcement
