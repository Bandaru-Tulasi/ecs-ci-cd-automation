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

## 🛠️ Project Structure

```
ecs-ci-cd-automation/
 ├── app.py
 ├── Dockerfile
 ├── requirements.txt
 ├── ecs-microservice-task.json
 ├── .github/
 │   └── workflows/
 │       └── deploy.yml
 └── README.md

```
---

## ⚙️ Step-by-Step Setup

## 1️⃣ Create Flask Application (app.py)

```
from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from NEW VERSION deployed via CI/CD!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

```
---

## 2️⃣ Create requirements.txt

```
flask

```
---

## 3️⃣ Create Dockerfile

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
---

## 4️⃣ Create ECS Task Definition JSON

File: ecs-microservice-task.json

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
---

## 🟦 5️⃣ Create GitHub Actions Workflow

Create the folder:

```
.github/workflows/deploy.yml

```
Add this content:

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

##🔐 6️⃣ Add GitHub Secrets

Go to:

```
GitHub → Repo → Settings → Secrets → Actions

```

Add:

```
Secret Name	Value
AWS_ACCESS_KEY_ID	IAM user Access Key
AWS_SECRET_ACCESS_KEY	IAM user Secret Key

```

IAM user must have permissions:

ECR Full Access

ECS Full Access

CloudWatch Logs

IAM ReadOnly

---

##🚀 7️⃣ CI/CD Pipeline Workflow

Whenever you run:

```
git add .
git commit -m "Update"
git push origin main

```

GitHub Actions automatically:

Builds Docker image

Pushes to ECR

Renders new task definition

Deploys to ECS

ALB shows new version

---

## 🌍 8️⃣ Test Your Deployment

Visit your ALB DNS name:

```
http://ecs-microservice-alb-xxxxxxxx.us-east-1.elb.amazonaws.com/

```

You should see:

```
Hello from NEW VERSION deployed via CI/CD!

```
## 📸 Screenshots Included

This project includes screenshots for verification and demonstration:

1. **ECR Repository** – showing image uploads and latest digest  
2. **ECS Cluster** – cluster overview  
3. **ECS Service** – service deployment details  
4. **Running Task** – task with correct image and port mapping  
5. **Task Definition** – updated revisions and container config  
6. **Application Load Balancer** – listeners and DNS name  
7. **Target Group** – healthy target and routing  
8. **GitHub Actions Workflow** – successful CI/CD runs  
9. **Application Output** – updated version message

---

Placed them in:

```
Screenshts.zip

```
---

##💡 Future Enhancements

Add Blue/Green Deployments with CodeDeploy

Add Health Checks + Alarms

Add Terraform/IaC automation

Add environment-based deployments (dev/stage/prod)

Add CloudWatch dashboards

---
