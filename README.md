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
Install Java:

sudo apt update
sudo apt install openjdk-11-jdk -y
Install Jenkins:

wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins -y
Start Jenkins:

sudo systemctl start jenkins
Configure Jenkins
Add Jenkins to the sudo user list:

sudo usermod -aG sudo jenkins
Access Jenkins using http://your-ec2-public-ip:8080 and follow the setup instructions.
Install the Docker, Git, and AWS CLI plugins.
Install AWS CLI, Kubectl, and Eksctl
Install AWS CLI:

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
Install kubectl:

curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
Install eksctl:

curl -sL https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_Linux_amd64.tar.gz | tar xz
sudo mv eksctl /usr/local/bin
Setup EKS Cluster
Create an EKS cluster:

eksctl create cluster --name mycluster --region ap-south-1 --fargate
Update kubeconfig for cluster access:

aws eks update-kubeconfig --name mycluster --region ap-south-1
Create Kubernetes Deployment
Create a k8s-deployment.yml file with the following content:

yaml
Copy code
---
apiVersion: v1
kind: Namespace
metadata:
  name: reactor
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: reactor
  name: deployment-react
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: react-deployment
  replicas: 5
  template:
    metadata:
      labels:
        app.kubernetes.io/name: react-deployment
    spec:
      containers:
      - name: react-app
        image: public.ecr.aws/o8g4t5k9/react-app:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  namespace: reactor
  name: service-react
spec:
  ports:
    - port: 80
      targetPort: 3000
      protocol: TCP
  type: NodePort
  selector:
    app.kubernetes.io/name: react-deployment
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: reactor
  name: ingress-react
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: service-react
              port:
                number: 80
Apply the Kubernetes configuration:


kubectl apply -f k8s-deployment.yml
Write the Jenkinsfile
Create a Jenkinsfile in your GitHub repository with the following content:

groovy
Copy code
pipeline {
    agent any
    environment {
        AWS_REGION = 'ap-south-1'
        ECR_PUBLIC_REGISTRY = 'public.ecr.aws/o8g4t5k9'
        ECR_REPOSITORY = 'react-app'
        IMAGE_TAG = "latest"
    }
    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/your-repo/react-app.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${ECR_PUBLIC_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}")
                }
            }
        }
        stage('Authenticate to Public AWS ECR') {
            steps {
                script {
                    sh 'aws ecr-public get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_PUBLIC_REGISTRY}'
                }
            }
        }
        stage('Tag and Push Docker Image to Public ECR') {
            steps {
                script {
                    sh "docker push ${ECR_PUBLIC_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s-deployment.yml'
            }
        }
        stage('Rollout New changes to EKS Cluster') {
            steps {
                sh 'kubectl rollout status deployment/deployment-react -n reactor'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Deployment was successful!'
        }
        failure {
            echo 'Deployment failed. Check logs for details.'
        }
    }
}
Configure GitHub Webhook
In your GitHub repository, go to Settings > Webhooks > Add webhook.
Set the Payload URL to http://your-ec2-public-ip:8080/github-webhook/.
Choose application/json as the content type.
Select Just the push event.
Click Add webhook.
Testing the Pipeline
Push a new commit to your GitHub repository.
Jenkins will automatically trigger the pipeline.
Monitor the build and deployment process through the Jenkins console.
Contributing
Feel free to submit issues and pull requests to improve this setup!

License
This project is licensed under the MIT License - see the LICENSE file for details.

javascript
Copy code

Copy this content and save it as `README.md` in your repository, then follow these steps to push it:

1. Save the content above into a `README.md` file in your project directory.
2. Open a terminal and navigate to your project directory.
3. Add the new file to Git:
   ```bash
   git add README.md
