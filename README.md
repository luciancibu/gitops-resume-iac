# GitOps Resume Infrastructure as Code

A GitOps-based infrastructure project that provisions an Amazon EKS cluster on AWS using Terraform, designed for hosting resume applications with automated CI/CD workflows.

## Architecture Overview

This project creates a complete AWS infrastructure stack including:

- **Amazon EKS Cluster** (v1.28) with managed node groups
- **VPC** with public and private subnets across 3 availability zones
- **NAT Gateway** for outbound internet access from private subnets
- **Security Groups** for EKS cluster access
- **NGINX Ingress Controller** for traffic routing

## Project Structure

```
gitops-resume-iac/
├── .github/
│   └── workflows/
│       └── terraform.yml          # GitHub Actions CI/CD pipeline
├── terraform/
│   ├── main.tf                    # Provider configurations
│   ├── terraform.tf               # Terraform and backend configuration
│   ├── variables.tf               # Input variables
│   ├── outputs.tf                 # Output values
│   ├── vpc.tf                     # VPC module configuration
│   ├── eks-cluster.tf             # EKS cluster configuration
│   └── .terraform/                # Terraform state and modules
└── .gitignore                     # Git ignore rules
```

## Infrastructure Components

### VPC Configuration
- **CIDR Block**: `172.20.0.0/16`
- **Private Subnets**: `172.20.1.0/24`, `172.20.2.0/24`, `172.20.3.0/24`
- **Public Subnets**: `172.20.4.0/24`, `172.20.5.0/24`, `172.20.6.0/24`
- **NAT Gateway**: Single NAT gateway for cost optimization
- **DNS**: Hostnames enabled

### EKS Cluster
- **Cluster Name**: `resume-eks`
- **Kubernetes Version**: `1.28`
- **Node Groups**: 2 managed node groups
  - **Node Group 1**: 1-3 nodes (desired: 2) using `t3.small` instances
  - **Node Group 2**: 1-2 nodes (desired: 1) using `t3.small` instances
- **AMI Type**: Amazon Linux 2 (AL2_x86_64)

## 🔧 Prerequisites

- **AWS CLI** configured with appropriate credentials
- **Terraform** v1.6.x
- **kubectl** for Kubernetes cluster management
- **GitHub repository** with required secrets configured

## Required GitHub Secrets

Configure the following secrets in your GitHub repository:

```
AWS_ACCESS_KEY_ID       # AWS access key for Terraform
AWS_SECRET_ACCESS_KEY   # AWS secret key for Terraform
BUCKET_TF_STATE         # S3 bucket name for Terraform state
```

## Deployment

### Automated Deployment (Recommended)

The project uses GitHub Actions for automated deployment:

1. **Triggers**: 
   - Push to `main` or `stage` branches
   - Pull requests to `main` branch
   - Changes in `terraform/` directory

2. **Workflow Steps**:
   - Terraform initialization with S3 backend
   - Code formatting validation
   - Configuration validation
   - Plan generation
   - Apply (only on main branch pushes)
   - EKS kubeconfig update
   - NGINX Ingress Controller installation

### Manual Deployment

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd gitops-resume-iac/terraform
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init -backend-config="bucket=<your-s3-bucket>"
   ```

3. **Plan the deployment**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

5. **Configure kubectl**:
   ```bash
   aws eks update-kubeconfig --region us-east-2 --name resume-eks
   ```

6. **Install NGINX Ingress Controller**:
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.3/deploy/static/provider/aws/deploy.yaml
   ```

## Terraform Configuration

### Backend Configuration
- **Type**: S3
- **Bucket**: `gitops-resume-actions-073191`
- **Key**: `terraform.tfstate`
- **Region**: `us-east-2`
- **Encryption**: Enabled

### Provider Versions
- **AWS**: `~> 5.40`
- **Kubernetes**: `~> 2.29`
- **Helm**: `~> 2.13`
- **Random**: `~> 3.6`
- **TLS**: `~> 4.0`
- **CloudInit**: `~> 2.3`

## Outputs

After successful deployment, the following outputs are available:

- `cluster_name`: EKS cluster name
- `cluster_endpoint`: EKS cluster API endpoint
- `region`: AWS region where resources are deployed
- `cluster_security_group_id`: Security group ID for the EKS cluster

## Customization

### Variables

You can customize the deployment by modifying variables in `terraform/variables.tf`:

- `region`: AWS region (default: `us-east-2`)
- `clusterName`: EKS cluster name (default: `resume-eks`)

### Scaling

To modify node group configurations, edit `terraform/eks-cluster.tf`:
- Adjust `min_size`, `max_size`, and `desired_size`
- Change `instance_types` for different EC2 instance sizes
- Add or remove node groups as needed

## Security Considerations

- EKS cluster endpoint is publicly accessible (consider restricting for production)
- Node groups run in private subnets
- Security groups follow least privilege principles
- Terraform state is encrypted in S3

## Cleanup

To destroy the infrastructure:

```bash
cd terraform
terraform destroy
```
