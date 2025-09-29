# 🚀 Simple React App with AWS CI/CD (Terraform + EC2 + CodePipeline + CodeBuild)

This project demonstrates how to deploy a React application to **AWS EC2** using **Terraform** for infrastructure and **AWS CodePipeline + CodeBuild** for automated CI/CD.

---

## 📂 Project Structure

Simple-react-app/
├── public/ # React public files
├── src/ # React source code
├── package.json # React dependencies & scripts
├── terraform/ # Terraform IaC files
│ ├── main.tf
│ ├── variables.tf
│ ├── outputs.tf
│ ├── cicd.tf
│ └── buildspec.yml

---

## 🔧 Prerequisites

- AWS Account
- Terraform v1.6+
- GitHub repository (with this project code)
- IAM user with permissions for EC2, S3, CodePipeline, CodeBuild, IAM, Secrets Manager
- SSH key pair for EC2 (`aws_key_pair`)

---

## ⚙️ Setup Instructions

### 1️⃣ Clone this repo
```bash
git clone https://github.com/<your-username>/Simple-react-app.git
cd Simple-react-app/terraform
2️⃣ Configure Terraform
Update variables.tf with:
aws_region
key_name (your EC2 SSH key pair name)
github_owner, github_repo_name, github_branch
github_token (store in AWS Secrets Manager, not hardcoded)
3️⃣ Deploy Infrastructure
terraform init
terraform plan
terraform apply -auto-approve
Terraform will create:
EC2 instance (Ubuntu, Nginx, Node.js)
S3 bucket (artifacts storage)
CodeBuild project
CodePipeline pipeline
IAM roles/policies
Outputs include:
EC2 public DNS
Pipeline name
CodeBuild project
▶️ How CI/CD Works
Developer commits & pushes code to GitHub
AWS CodePipeline (Source Stage) detects changes
CodeBuild builds the React app (npm install && npm run build)
Build artifacts are copied to EC2 via SSM
Nginx serves the new version of the React app
🔍 Testing the Pipeline
Open the EC2 Public DNS from Terraform output:
http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com
You should see the default React page.
Edit the code in src/App.js:
<h1>Welcome to My New Version 🚀</h1>
Commit & push to GitHub:
git add .
git commit -m "Updated homepage message"
git push origin main
Go to AWS Console → CodePipeline and watch the pipeline run.
Refresh the EC2 Public DNS page → it should now show "Welcome to My New Version 🚀"
🛠 Troubleshooting
Pipeline fails in Source stage → Check GitHub token permissions.
Pipeline fails in Build stage → Review CodeBuild logs.
EC2 not updating → Check /var/log/user-data.log on the instance.
Nginx issues → Run:
sudo nginx -t
sudo systemctl restart nginx
📜 License

---

👉 This README + testing workflow is **enough for any new team member** to clone the repo and deploy the entire project from scratch.  

Do you want me to also include a **diagram (architecture flow)** for the README (GitHub → CodePipeline → CodeBuild → S3 → EC2)? That would make it visually clear for new members.
