# 🚀 AWS CI/CD Pipeline — GitHub Actions → Amazon ECR → Amazon ECS Fargate

This project demonstrates an end-to-end automated deployment pipeline for a containerized Python Flask microservice using:

GitHub Actions for CI/CD

Amazon ECR for image storage

Amazon ECS Fargate for serverless container hosting

Application Load Balancer (ALB) for traffic routing

Every push to the main branch triggers a fully automated build → package → publish → deploy workflow.

---

##📌 Features

✅ Fully automated CI/CD pipeline

✅ Docker image built & pushed to ECR on every commit

✅ ECS Task Definition updated dynamically

✅ ECS rolling deployment triggered automatically

✅ Zero-downtime deployments via ALB

✅ Follows real-world DevOps/AWS best practices

---

## 🧱 Architecture Overview

```text

Developer Commit (GitHub)
        |
        v
+------------------------+
|   GitHub Actions CI/CD |
|  (Build → Push → Deploy) |
+------------------------+
        |
        v
+------------------------+
| Amazon ECR (Image Repo)|
+------------------------+
        |
        v
+----------------------------+
| Amazon ECS Fargate Cluster |
|  (Runs the Flask App)      |
+----------------------------+
        |
        v
+-----------------------------+
| Application Load Balancer   |
+-----------------------------+
        |
        v
User → https://<your-alb-url>

```

---

## 🧰 Technologies Used

Python + Flask

Docker

GitHub Actions

Amazon ECR

Amazon ECS Fargate

Application Load Balancer (ALB)

IAM Roles

CloudWatch Logs

---

# 🛠 Project Setup

## 1️⃣ Create ECR Repository

Example:

ecs-microservice

Copy the repository URI:

766377908037.dkr.ecr.us-east-1.amazonaws.com/ecs-microservice

---

## 2️⃣ Create ECS Fargate Infrastructure

ECS Cluster

Task Definition

Service (connected to ALB)

Security Groups

IAM execution role

---

## 3️⃣ Configure GitHub Secrets

Go to:

```
GitHub → Your Repo → Settings → Secrets and Variables → Actions

```

Add:

Secret Name	Value
AWS_ACCESS_KEY_ID	IAM user key
AWS_SECRET_ACCESS_KEY	IAM user secret
AWS_REGION	us-east-1
ECR_REGISTRY	766377908037.dkr.ecr.us-east-1.amazonaws.com
ECR_REPOSITORY	ecs-microservice

---

##📄 Files Included


app.py

```
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from NEW VERSION deployed via CI/CD!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

```

Dockerfile

```
# Use official Python runtime
FROM python:3.9-slim

# Set working directory in container
WORKDIR /app

# Copy requirements.txt first (better caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app
COPY . .

# Expose port 8080
EXPOSE 8080

# Run the application
CMD ["python", "app.py"]

```

requirements.txt

```
flask

```
ecs-microservice-task.json

```
{
  "family": "ecs-microservice-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::766377908037:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::766377908037:role/ecsTaskExecutionRole",

  "containerDefinitions": [
    {
      "name": "ecs-microservice",
      "image": "766377908037.dkr.ecr.us-east-1.amazonaws.com/ecs-microservice:latest",
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/ecs-microservice",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}

```

GitHub Actions Workflow — deploy.yml

```
name: Deploy to ECS Fargate

on:
  push:
    branches: ["main"]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Login to Amazon ECR
      uses: aws-actions/amazon-ecr-login@v1

    - name: Build and push Docker image
      id: build-image
      env:
        ECR_REGISTRY: 766377908037.dkr.ecr.us-east-1.amazonaws.com
        ECR_REPOSITORY: ecs-microservice
        IMAGE_TAG: ${{ github.run_number }}
      run: |
        docker build --no-cache -t $ECR_REGISTRY/$ECR_REPOSITORY:latest .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
        echo "IMAGE_URI=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT

    - name: Render task definition
      id: render-task
      uses: aws-actions/amazon-ecs-render-task-definition@v1
      with:
        task-definition: ecs-microservice-task.json
        container-name: ecs-microservice
        image: ${{ steps.build-image.outputs.IMAGE_URI }}

    - name: Deploy to ECS
      uses: aws-actions/amazon-ecs-deploy-task-definition@v1
      with:
        task-definition: ${{ steps.render-task.outputs.task-definition }}
        service: ecs-microservice-service
        cluster: ecs-microservice-cluster
        wait-for-service-stability: true

```
---

## 🚀 How Deployment Works

Every push to main triggers:

CI Phase

GitHub Actions pulls the code

Docker image builds

Image pushed to ECR

CD Phase

ECS Task Definition updated

ECS Service deploys new task

ALB starts serving updated version

---

##🌍 Live Application URL

```
http://<your-application-load-balancer>.amazonaws.com/

```
---

##📸 Screenshots

Include screenshots of:

ECR Repository

ECS Cluster

ECS Service

Running Task

Task Definition

ALB Load Balancer

Pipeline Success (GitHub Actions run)

Placed them in:

screenshots/

---

##💡 Future Enhancements

Add Blue/Green Deployments with CodeDeploy

Add Health Checks + Alarms

Add Terraform/IaC automation

Add environment-based deployments (dev/stage/prod)

Add CloudWatch dashboards

---
