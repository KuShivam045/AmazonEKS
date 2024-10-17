# Jenkins CI/CD Pipeline for Deploying Dockerized React App on AWS EKS

This repository demonstrates how to set up an end-to-end CI/CD pipeline using Jenkins for deploying a Dockerized React application to an AWS EKS cluster. It covers everything from setting up an EC2 instance for Jenkins to automating deployments using GitHub webhooks.

## Prerequisites

Before you begin, ensure you have the following:

- An AWS account with IAM user permissions for EKS, EC2, and ECR.
- An EC2 instance running Ubuntu (t2.medium recommended).
- AWS CLI, `kubectl`, and `eksctl` installed on the EC2 instance.
- A public AWS ECR repository to store Docker images.
- A GitHub repository containing your React application code.

## Table of Contents

- [Setup EC2 Instance](#setup-ec2-instance)
- [Install Jenkins](#install-jenkins)
- [Configure Jenkins](#configure-jenkins)
- [Install AWS CLI, Kubectl, and Eksctl](#install-aws-cli-kubectl-and-eksctl)
- [Setup EKS Cluster](#setup-eks-cluster)
- [Create Kubernetes Deployment](#create-kubernetes-deployment)
- [Write the Jenkinsfile](#write-the-jenkinsfile)
- [Configure GitHub Webhook](#configure-github-webhook)
- [Testing the Pipeline](#testing-the-pipeline)
- [Contributing](#contributing)
- [License](#license)

## Setup EC2 Instance

1. Create an EC2 instance using Ubuntu AMI in your preferred region. We chose **Asia Pacific (Mumbai)** (`ap-south-1`).
2. Choose an instance type, at least **t2.medium** for smooth performance.
3. Update security group inbound rules to allow the following ports:
   - `22` for SSH
   - `80` for HTTP
   - `443` for HTTPS
   - `8080` for Jenkins

## Install Jenkins

1. SSH into the EC2 instance:
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-public-ip

2. Update the Package List:
    ```bash
    sudo apt update && sudo apt upgrade -y
