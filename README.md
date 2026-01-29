```markdown
# Serverless Image Processing Pipeline

An enterprise-grade, event-driven image processing architecture built on AWS using Terraform.

## 📺 Project Demonstration
Watch the full end-to-end walkthrough and live demo here:  
**[View Demo on YouTube](https://youtu.be/GitDLSMGX5s)**

---

## 🏗️ System Architecture & Workflow

![Architecture Flowchart](./work_flow.png)

1. **API Entry**: User sends an image via POST request to **AWS API Gateway**.
2. **Security**: Request is validated using a unique **X-API-Key**.
3. **Compute**: API Gateway triggers an **AWS Lambda** function.
4. **Storage (Raw)**: Lambda saves the original image to the **Uploads S3 Bucket**.
5. **Processing**: Lambda processes the image and saves the result to the **Processed S3 Bucket**.
6. **Separation**: Two-bucket design prevents recursive triggers and ensures data integrity.

---

## 📂 Repository Structure
```text
.
├── api-spec/
│   └── openapi.yaml          # API documentation & endpoints
├── functions/
│   └── image_processor.py    # Python logic for image handling
├── terraform/
│   ├── main.tf               # Infrastructure resource definitions
│   └── variables.tf          # Environment variables
├── work_flow.png             # Hand-drawn Architecture Diagram
├── README.md                 # Project documentation
└── submission.json           # API credentials and endpoint

```

---

## 🛠️ Technology Stack

* **Cloud Platform**: AWS
* **IaC**: Terraform
* **Compute**: AWS Lambda
* **Storage**: Amazon S3
* **API Management**: AWS API Gateway
* **Language**: Python 3.x

---

## 🚀 Deployment & Usage

### 1. Initialization & Apply

```bash
terraform init
terraform apply -auto-approve

```

### 2. Verification (CURL)

```bash
curl -X POST <API_ENDPOINT_URL> \
     -H "x-api-key: <YOUR_API_KEY>" \
     -H "Content-Type: image/jpeg" \
     --data-binary "@yourimage.jpg"

```

---

**Author: Sai Yasaswi**

```

Would you like me to double-check your GitHub link one last time before you submit?

```
