# Network Systems and Administration

## Project Report: Automated Container Deployment and Administration in the Cloud

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Project Structure](#project-structure)
3. [Prerequisites](#prerequisites)
4. [Setup Instructions](#setup-instructions)
5. [Code Explanations](#code-explanations)
   - [Terraform Configuration](#terraform-configuration)
   - [Ansible Playbook](#ansible-playbook)
   - [Docker Configuration](#docker-configuration)
   - [React Application](#react-application)
   - [GitHub Actions Workflows](#github-actions-workflows)

---

## Project Overview

This project demonstrates a complete DevOps automation pipeline that deploys a React application to AWS EC2 using modern infrastructure and deployment practices. The system uses Terraform for infrastructure provisioning, Ansible for configuration management, Docker for containerization, and GitHub Actions for CI/CD automation.

**Key Features:**

- Infrastructure as Code (IaC)
- Automated infrastructure provisioning
- Continuous deployment on code push
- Containerized application delivery
- Cost-optimized (destroy when not needed)

---

## Project Structure

```
devops-automation-project/
│
├── .github/
│   └── workflows/
│       ├── infrastructure.yml    # Terraform infrastructure workflow
│       └── deploy.yml            # Application deployment workflow
│
├── terraform/
│   ├── main.tf                   # Main Terraform configuration
│   ├── variables.tf              # Variable definitions
│   ├── outputs.tf                # Output definitions
│   ├── terraform.tfvars          # Variable values
│   └── inventory.tpl             # Ansible inventory template
│
├── ansible/
│   ├── playbook.yml              # Ansible deployment playbook
│   └── inventory.ini             # Generated inventory file
│
├── docker/
│   ├── Dockerfile                # Multi-stage Docker build
│   └── nginx.conf                # Nginx configuration
│
├── src/
│   ├── App.jsx                   # React application component
│   ├── main.jsx                  # React entry point
│   └── index.css                 # Application styles
│
├── public/                       # Static assets
├── package.json                  # Node.js dependencies
├── vite.config.js                # Vite build configuration
└── README.md                     # This file
```

---

## Prerequisites

To kick off the project, the following prerequisite actions were completed: 

1. **AWS Account** with access keys
2. **GitHub Account** for repository hosting
3. **AWS EC2 Key Pair** created in your region
4. **Git** installed locally

---

##  Setup Instructions

### Step 1: Fork/Clone Repository
```bash
git clone https://github.com/yourusername/devops-automation-project.git
cd devops-automation-project
```

### Step 2: Configure GitHub Secrets

Navigate to: `Repository Settings → Secrets and Variables → Actions`

Add these secrets:
- `AWS_ACCESS_KEY_ID` - Your AWS access key
- `AWS_SECRET_ACCESS_KEY` - Your AWS secret key
- `AWS_KEY_NAME` - Name of your EC2 key pair
- `SSH_PRIVATE_KEY` - Private key content (corresponding to AWS key pair)
- `AWS_REGION` - AWS region (e.g., us-east-1)

### Step 3: Update Terraform Variables

Edit `terraform/terraform.tfvars`:
```hcl
aws_region    = "eu-north-1"
instance_type = "t3.micro"
key_name      = "your-key-pair-name"
```

### Step 4: Run Infrastructure Workflow

1. Go to GitHub Actions tab
2. Select "Provision Infrastructure"
3. Click "Run workflow"
4. Choose "apply" action
5. Wait for completion (~3 minutes)

### Step 5: Deploy Application

1. Push code to main branch 
3. Wait for deployment (~3-5 minutes)

### Step 6: Access Application

Open browser and navigate to: `http://<EC2_PUBLIC_IP>`

---

## 📖 Code Explanations

---

## Terraform Configuration

### 1. main.tf

This file contains all AWS resource definitions and is the heart of our infrastructure setup.

#### Terraform Configuration Block
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```
**Explanation:** This block specifies that we need the AWS provider plugin from HashiCorp. The version constraint `~> 5.0` means we'll use any 5.x version, allowing minor updates but preventing breaking changes from major version updates.

---

#### AWS Provider Configuration
```hcl
provider "aws" {
  region = var.aws_region
}
```
**Explanation:** This configures the AWS provider with our chosen region. The region comes from a variable, making our infrastructure flexible and reusable across different AWS regions without code changes.

---

#### Data Source - Latest Ubuntu AMI
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```
**Explanation:** Instead of hard-coding an AMI ID (which changes by region and gets outdated), this data source dynamically finds the latest Ubuntu 22.04 LTS AMI. The owner ID `099720109477` is Canonical's official AWS account. The filters ensure we get the correct Ubuntu version with hardware virtual machine (HVM) virtualization, which is required for most instance types.

---

#### Security Group Resource
```hcl
resource "aws_security_group" "app_sg" {
  name        = "devops-app-sg"
  description = "Security group for DevOps automation project"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-app-sg"
  }
}
```
**Explanation:** Security groups act as virtual firewalls for our EC2 instance. The `ingress` blocks define inbound traffic rules:
- Port 22 (SSH) allows us to connect for management and Ansible deployment
- Port 80 (HTTP) allows users to access our web application
- Port 443 (HTTPS) is open for future SSL certificate implementation
- `0.0.0.0/0` means traffic is allowed from any IP address

The `egress` block allows all outbound traffic (protocol "-1" means all protocols), which is necessary for the instance to download packages, pull Docker images, and communicate with external services.

---

#### EC2 Instance Resource
```hcl
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "devops-automation-server"
  }
}
```
**Explanation:** This creates our EC2 instance with several important configurations:
- `ami` uses the Ubuntu AMI we found with the data source
- `instance_type` from variables allows us to easily change instance size
- `key_name` specifies which SSH key pair to use for authentication
- `vpc_security_group_ids` attaches our security group, establishing the dependency
- `root_block_device` configures a 20GB GP3 volume (faster and cheaper than GP2)
- The `Name` tag helps us identify the instance in AWS console and allows AWS CLI to find it

---

#### Local File Resource - Ansible Inventory
```hcl
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    instance_ip = aws_instance.app_server.public_ip
  })
  filename = "${path.module}/../ansible/inventory.ini"

  depends_on = [aws_instance.app_server]
}
```
**Explanation:** This resource generates the Ansible inventory file automatically after the EC2 instance is created. The `templatefile` function reads inventory.tpl and replaces variables with actual values. The `depends_on` ensures this only runs after the instance exists and has a public IP. This automation eliminates manual inventory file updates.

---

### 2. variables.tf

```hcl
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair to use for EC2 instance"
  type        = string
}
```
**Explanation:** Variables make our Terraform configuration reusable and maintainable:
- `aws_region` has a default value but can be overridden
- `instance_type` defaults to t2.micro (free tier eligible) but allows upgrades
- `key_name` has no default because it must be provided (required)
- The `description` helps other developers understand each variable's purpose
- `type` enforces that only strings are accepted, preventing configuration errors

---

### 3. outputs.tf

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_instance.app_server.public_ip}"
}
```
**Explanation:** Outputs display important information after Terraform runs:
- `instance_id` is useful for AWS CLI commands and debugging
- `instance_public_ip` is what we need to access the server
- `instance_public_dns` provides the AWS-generated hostname
- `application_url` gives us a ready-to-use clickable link

These outputs appear in the GitHub Actions logs and can be queried with `terraform output` command.

---

### 4. terraform.tfvars

```hcl
aws_region    = "us-east-1"
instance_type = "t2.micro"
key_name      = "devops-key"
```
**Explanation:** This file provides actual values for our variables. It's separate from variables.tf to allow different configurations per environment. For security reasons, this file should not contain sensitive data like passwords or API keys. The key_name must match an existing key pair in your AWS account.

---

### 5. inventory.tpl

```hcl
[webservers]
${instance_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/deploy_key.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```
**Explanation:** This is a template file that Terraform uses to generate the Ansible inventory:
- `[webservers]` creates an inventory group that Ansible playbook targets
- `${instance_ip}` is a placeholder replaced with the actual EC2 IP address
- `ansible_user=ubuntu` specifies the SSH username for Ubuntu systems
- `ansible_ssh_private_key_file` points to where GitHub Actions places the SSH key
- `ansible_ssh_common_args` disables host key checking, necessary for automation

---

## Ansible Playbook

### playbook.yml

This playbook contains all the steps needed to configure the server and deploy our application.

#### Playbook Header
```yaml
---
- name: Deploy DevOps Automation Project
  hosts: webservers
  become: yes
  vars:
    app_dir: /home/ubuntu/app
    repo_url: https://github.com/yourusername/devops-automation-project.git
```
**Explanation:** 
- `name` describes what this playbook does
- `hosts: webservers` targets servers in the webservers inventory group
- `become: yes` runs tasks with sudo privileges (needed for system packages)
- `vars` defines variables used throughout the playbook, making paths and URLs easy to update

---

#### Task 1-2: System Preparation
```yaml
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Install required packages
      apt:
        name:
          - apt-transport-https
          - ca-certificates
          - curl
          - software-properties-common
          - git
        state: present
```
**Explanation:** 
- `update_cache` refreshes the package list, similar to `apt update`
- `cache_valid_time: 3600` skips update if cache is less than 1 hour old (efficiency)
- `apt-transport-https` enables downloading over HTTPS
- `ca-certificates` provides SSL certificate validation
- `software-properties-common` allows adding third-party repositories
- `state: present` ensures packages are installed but doesn't reinstall if already present

---

#### Task 3-4: Docker Repository Setup
```yaml
    - name: Add Docker GPG key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: Add Docker repository
      apt_repository:
        repo: "deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
        state: present
```
**Explanation:** 
- GPG keys verify package authenticity, preventing malicious software installation
- The repository URL uses `ansible_distribution_release` (automatically detects "jammy" for Ubuntu 22.04)
- `[arch=amd64]` specifies 64-bit packages
- This adds Docker's official repository so we get the latest version, not Ubuntu's older packaged version

---

#### Task 5-7: Docker Installation
```yaml
    - name: Install Docker
      apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
        state: present
        update_cache: yes

    - name: Start and enable Docker service
      systemd:
        name: docker
        state: started
        enabled: yes

    - name: Add ubuntu user to docker group
      user:
        name: ubuntu
        groups: docker
        append: yes
```
**Explanation:** 
- `docker-ce` is the Docker engine
- `docker-ce-cli` provides the docker command-line tool
- `containerd.io` is the container runtime
- `systemd` module ensures Docker starts now and on every boot
- Adding user to docker group allows running docker commands without sudo
- `append: yes` adds docker to existing groups instead of replacing them

---

#### Task 8-9: Repository Management
```yaml
    - name: Remove old app directory if exists
      file:
        path: "{{ app_dir }}"
        state: absent

    - name: Clone repository
      git:
        repo: "{{ repo_url }}"
        dest: "{{ app_dir }}"
        version: main
        force: yes
```
**Explanation:** 
- Removing the old directory ensures a clean slate and prevents conflicts
- `git` module clones the repository
- `version: main` checks out the main branch
- `force: yes` discards any local changes and pulls fresh code
- This guarantees we always deploy the latest version

---

#### Task 10-12: Container Cleanup
```yaml
    - name: Stop old container
      docker_container:
        name: devops-app
        state: stopped
      ignore_errors: yes

    - name: Remove old container
      docker_container:
        name: devops-app
        state: absent
      ignore_errors: yes

    - name: Remove old Docker image
      docker_image:
        name: devops-app
        state: absent
      ignore_errors: yes
```
**Explanation:** 
- These tasks clean up previous deployments
- `ignore_errors: yes` prevents failure on first run when nothing exists yet
- Stopping before removing is a best practice
- Removing old images frees disk space
- Each task is idempotent—safe to run multiple times

---

#### Task 13-14: Build and Deploy
```yaml
    - name: Build Docker image
      docker_image:
        name: devops-app
        build:
          path: "{{ app_dir }}"
          dockerfile: docker/Dockerfile
        source: build
        force_source: yes

    - name: Run Docker container
      docker_container:
        name: devops-app
        image: devops-app
        state: started
        restart_policy: always
        ports:
          - "80:80"
```
**Explanation:** 
- `build.path` sets the build context to our app directory
- `dockerfile` specifies the Dockerfile location relative to build context
- `force_source: yes` rebuilds even if an image with that name exists
- `restart_policy: always` ensures container restarts after crashes or server reboots
- `ports: "80:80"` maps container port 80 to host port 80, making the app accessible

---

#### Task 15-16: Verification
```yaml
    - name: Wait for application to be ready
      wait_for:
        port: 80
        delay: 5
        timeout: 60

    - name: Display success message
      debug:
        msg: "Application deployed successfully! Access at http://{{ ansible_default_ipv4.address }}"
```
**Explanation:** 
- `wait_for` pauses until port 80 responds, confirming the app is running
- `delay: 5` waits 5 seconds before first check, giving Nginx time to start
- `timeout: 60` fails if app doesn't respond within 60 seconds
- `debug` prints a success message with the access URL
- `ansible_default_ipv4.address` automatically gets the server's IP

---

## Docker Configuration

### 1. Dockerfile

This multi-stage Dockerfile optimizes build time and final image size.

#### Stage 1: Build Stage
```dockerfile
FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build
```
**Explanation:** 
- `FROM node:18-alpine` uses a lightweight Node.js base image (~40MB vs ~300MB for full node)
- `AS build` names this stage so we can reference it later
- `WORKDIR /app` creates and sets working directory
- Copying package files first leverages Docker layer caching—dependencies only reinstall when package.json changes
- `npm install` downloads all project dependencies
- Copying source code after install optimizes cache usage
- `npm run build` compiles React with Vite, creating optimized production files in dist/

---

#### Stage 2: Production Stage
```dockerfile
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```
**Explanation:** 
- `FROM nginx:alpine` starts fresh with just Nginx (~20MB)
- `--from=build` copies files from the build stage, discarding all build tools and node_modules
- `/usr/share/nginx/html` is Nginx's default serving directory
- Custom nginx.conf replaces default configuration
- `EXPOSE 80` documents that this container listens on port 80
- `daemon off` keeps Nginx in foreground so Docker can monitor it
- Final image is only ~25-30MB because we excluded build dependencies

---

## React Application with Nginx

### App.jsx

Sample Application made by React Vite.

---

## GitHub Actions Workflows

### 1. infrastructure.yml

This workflow manages AWS infrastructure creation and destruction.

#### Workflow Trigger
```yaml
name: Provision Infrastructure

on:
  workflow_dispatch:
    inputs:
      action:
        description: 'Terraform action (apply/destroy)'
        required: true
        default: 'apply'
        type: choice
        options:
          - apply
          - destroy
```
**Explanation:** 
- `workflow_dispatch` means manual trigger only (not automatic)
- `inputs` defines a parameter users must choose
- `choice` type creates a dropdown menu
- This prevents accidental infrastructure changes
- User must consciously choose apply or destroy

---

#### Job Configuration
```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./terraform
```
**Explanation:** 
- `runs-on: ubuntu-latest` uses GitHub's hosted Ubuntu runner
- `defaults.run.working-directory` sets terraform/ as default for all commands
- This avoids repeating `cd terraform` in every step

---

#### Checkout and AWS Setup
```yaml
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}
```
**Explanation:** 
- Downloads repository code to the runner
- Configures AWS CLI using encrypted secrets
- These credentials allow Terraform to create AWS resources
- Secrets never appear in logs

---

#### Terraform Steps
```yaml
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.6.0
          terraform_wrapper: false

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        if: github.event.inputs.action == 'apply'
        run: terraform plan

      - name: Terraform Apply
        if: github.event.inputs.action == 'apply'
        run: terraform apply -auto-approve

      - name: Terraform Destroy
        if: github.event.inputs.action == 'destroy'
        run: terraform destroy -auto-approve
```
**Explanation:** 
- Installs specific Terraform version
- `terraform_wrapper: false` prevents output formatting issues
- Init downloads provider plugins
- Plan shows what will change
- `if` conditions ensure only chosen action runs
- `-auto-approve` skips confirmation (safe for automation)

---

### 2. deploy.yml

This workflow handles application deployment.

#### Workflow Triggers
```yaml
name: Deploy Application

on:
  push:
    branches:
      - main
    paths:
      - 'src/**'
      - 'docker/**'
      - 'ansible/**'
      - 'terraform/**'
  workflow_dispatch:
```
**Explanation:** 
- Triggers automatically on push to main
- `paths` filter prevents unnecessary runs
- `workflow_dispatch` allows manual triggering
- Only triggers when relevant files change

---

#### EC2 Detection
```yaml
      - name: Check if EC2 instance exists
        id: check_instance
        run: |
          INSTANCE_ID=$(aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=devops-automation-server" \
                      "Name=instance-state-name,Values=running,pending" \
            --query "Reservations[0].Instances[0].InstanceId" \
            --output text)
          
          if [ "$INSTANCE_ID" == "None" ] || [ -z "$INSTANCE_ID" ]; then
            echo "No running EC2 instance found!"
            exit 1
          fi
          
          echo "instance_id=$INSTANCE_ID" >> $GITHUB_OUTPUT
```
**Explanation:** 
- Queries AWS for our specific instance
- Filters by tag and state
- Fails, if no instance found
- Saves instance ID for later steps
- Replaces dependency on Terraform state

---

#### SSH Setup and Connection
```yaml
      - name: Setup SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/deploy_key.pem
          chmod 600 ~/.ssh/deploy_key.pem

      - name: Test SSH connection
        run: |
          for i in {1..5}; do
            if ssh -i ~/.ssh/deploy_key.pem -o StrictHostKeyChecking=no ubuntu@${{ steps.get_ip.outputs.instance_ip }} "echo 'SSH connection successful'"; then
              exit 0
            fi
            sleep 10
          done
          exit 1
```
**Explanation:** 
- Creates SSH key with correct permissions
- Tests connection with 5 retries
- Waits for EC2 to fully boot
- Prevents Ansible from failing on slow starts

---

#### Ansible Deployment
```yaml
      - name: Install Ansible
        run: |
          sudo apt-get update
          sudo add-apt-repository --yes --update ppa:ansible/ansible
          sudo apt-get install -y ansible

      - name: Run Ansible playbook
        run: |
          cd ansible
          ansible-playbook -i inventory.ini playbook.yml
```
**Explanation:** 
- Installs latest Ansible version
- Runs playbook against EC2 instance
- All deployment tasks execute automatically
- Failure stops the workflow

---

### First-Time Setup

1. **Provision Infrastructure**
   - Actions → Provision Infrastructure → Run workflow
   - Select "apply"
   - Wait ~3 minutes

2. **Deploy Application**
   - Actions → Deploy Application → Run workflow or push to github 
   - Wait for 5 minutes
   - Access at displayed URL

---

**Thank you**