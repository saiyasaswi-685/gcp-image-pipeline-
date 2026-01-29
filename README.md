


```markdown
# Serverless Image Processing Pipeline

An enterprise-grade, event-driven image processing architecture built on AWS using Terraform (Infrastructure as Code). This project automates the workflow of receiving, processing, and storing media files securely in the cloud.

## 📺 Project Demonstration
Watch the full end-to-end walkthrough and live demo here:
**[View Demo on YouTube](https://youtu.be/GitDLSMGX5s)**

---

## 🏗️ System Architecture & Workflow
The pipeline follows a decoupled, serverless architecture to ensure high availability and cost-efficiency.



1.  **API Entry**: A user sends an image via a POST request to the **AWS API Gateway**.
2.  **Security**: The request is validated using a unique **X-API-Key** in the header.
3.  **Compute**: API Gateway triggers an **AWS Lambda** function, passing the Base64 encoded image.
4.  **Storage (Raw)**: The Lambda function saves the original image to the **Uploads S3 Bucket**.
5.  **Processing**: The function performs image processing (e.g., renaming or conversion) and saves the result to the **Processed S3 Bucket**.
6.  **Separation**: Using two buckets prevents recursive triggers (infinite loops) and maintains a clean data lifecycle.

---

## 📂 Repository Structure
The project is organized into clear modules for infrastructure and application logic:

```text
.
├── api-spec/
│   └── openapi.yaml          # Documentation: API Endpoints & Authentication details
├── functions/
│   └── image_processor.py    # Logic: Python script for image handling & S3 interaction
├── terraform/
│   ├── main.tf               # IaC: AWS Resource definitions (S3, Lambda, API Gateway)
│   └── variables.tf          # Config: Environment variables and constants
├── README.md                 # Documentation: Project guide
└── submission.json           # Credentials: API Endpoint and Secure API Key

```

---

## 🛠️ Technology Stack

* **Cloud Platform**: Amazon Web Services (AWS)
* **Infrastructure as Code**: Terraform
* **Serverless Compute**: AWS Lambda
* **Object Storage**: Amazon S3 (Scalable & Secure)
* **API Management**: AWS API Gateway (Restful API)
* **Development Language**: Python 3.x

---

## 🚀 Deployment & Usage

To replicate this infrastructure, follow these steps:

### 1. Initialization

Navigate to the terraform directory and initialize the providers:

```bash
terraform init

```

### 2. Execution

Apply the configuration to create all AWS resources:

```bash
terraform apply -auto-approve

```

### 3. Verification

Use the following `curl` command to test the pipeline (replace values with those found in `submission.json`):

```bash
curl -X POST <API_ENDPOINT_URL> \
     -H "x-api-key: <YOUR_API_KEY>" \
     -H "Content-Type: image/jpeg" \
     --data-binary "@yourimage.jpg"

```

### 4. Resource Cleanup

To avoid unnecessary cloud costs, destroy the resources after testing:

```bash
terraform destroy -auto-approve

```

---

**Author: Sai Yasaswi**


```

