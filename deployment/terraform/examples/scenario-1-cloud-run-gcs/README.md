# Scenario 1: Cloud Run with Google Cloud Storage

This scenario demonstrates a basic Cloud Run service with Google Cloud Storage integration using the modular Terraform approach.

## Architecture

- **Cloud Run Service**: Serverless container deployment
- **Google Cloud Storage**: Object storage bucket for application data
- **Service Account**: Dedicated service account with minimal permissions
- **IAM**: Proper access controls between services

## Modules Used

- `apis`: Enable required Google Cloud APIs
- `service-account`: Create service account with appropriate roles
- `storage`: Create GCS bucket with IAM permissions
- `cloud-run`: Deploy Cloud Run service with environment variables

## Prerequisites

- Google Cloud Project with billing enabled
- Terraform >= 1.0
- `gcloud` CLI authenticated

## Deployment

1. Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your values (defaults exist for optional settings):
```bash
project_id = "your-gcp-project-id"
region     = "us-central1"
user_email = "your-email@example.com"

# Optional overrides
# service_account_id           = "test-sc-1-sa"
# service_account_display_name = "Test Scenario 1 Service Account"
# bucket_name                  = "<custom-bucket-name>" # default: "<project_id>-test-sc-1-bucket"
# cloud_run_service_name       = "test-sc-1-service"
# image                        = "gcr.io/cloudrun/hello"
# enable_gcs_volume            = false
# gcs_mount_path               = "/mnt/bucket"
```

3. Initialize and apply:
```bash
terraform init
terraform plan
terraform apply
```

## Usage

After deployment, the Cloud Run service will be accessible via the URL provided in the output. The service has access to the created GCS bucket through the service account.

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

Or use the provided cleanup script:
```bash
./cleanup.sh
```

## Key Features

- **Modular Design**: Uses reusable Terraform modules
- **Security**: Least-privilege service account permissions
- **Environment Variables**: GCS bucket name passed to Cloud Run
- **IAM Integration**: Proper access controls between services
