
---

```markdown
# Serverless Image Processing Pipeline

An enterprise-grade, event-driven image processing architecture built on AWS using Terraform (Infrastructure as Code). This project automates the workflow of receiving, processing, and storing media files securely in the cloud.

## 📺 Project Demonstration
Watch the full end-to-end walkthrough and live demo here:
**[View Demo on YouTube](https://youtu.be/GitDLSMGX5s)**

---

## 🏗️ System Architecture & Workflow
The pipeline follows a decoupled, serverless architecture to ensure high availability and cost-efficiency.


### Workflow Steps:
1.  **API Entry**: A user sends an image via a POST request to the **AWS API Gateway**.
2.  **Security**: The request is validated using a unique **X-API-Key** in the header.
3.  **Compute**: API Gateway triggers an **AWS Lambda** function, passing the Base64 encoded image.
4.  **Storage (Raw)**: The Lambda function saves the original image to the **Uploads S3 Bucket**.
5.  **Processing**: The function performs image processing (e.g., renaming or conversion) and saves the result to the **Processed S3 Bucket**.
6.  **Separation**: Using two distinct buckets prevents recursive triggers and maintains a clean data lifecycle.

---

## 📂 Repository Structure
The project is organized into clear modules for infrastructure and application logic:

```text
.
├── api-spec/
│   └── openapi.yaml          # API Endpoints & Authentication details
├── functions/
│   └── image_processor.py    # Python script for image handling & S3 interaction
├── terraform/
│   ├── main.tf               # AWS Resource definitions (S3, Lambda, API Gateway)
│   └── variables.tf          # Environment variables and constants
├── README.md                 # Project guide
└── submission.json           # API Endpoint and Secure API Key

```

---

## 🛠️ Technology Stack

* **Cloud Platform**: Amazon Web Services (AWS)
* **Infrastructure as Code**: Terraform
* **Serverless Compute**: AWS Lambda
* **Object Storage**: Amazon S3
* **API Management**: AWS API Gateway
* **Development Language**: Python 3.x

---

## 🚀 Deployment & Usage

### 1. Initialization

```bash
terraform init

```

### 2. Execution

```bash
terraform apply -auto-approve

```

### 3. Verification

Use `curl` to test the pipeline (replace values from `submission.json`):

```bash
curl -X POST <API_ENDPOINT_URL> \
     -H "x-api-key: <YOUR_API_KEY>" \
     -H "Content-Type: image/jpeg" \
     --data-binary "@yourimage.jpg"

```

### 4. Resource Cleanup

```bash
terraform destroy -auto-approve

```

---

**Author: Sai Yasaswi**
*Submitted for the Cloud Infrastructure Engineering Assessment.*

```

---



```
