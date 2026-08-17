# =============================================================================
# Remote Backend — S3 + DynamoDB for state locking
# =============================================================================
# Before using this, create these two resources manually in AWS Console:
#
#   1. S3 bucket:
#      - Name: my-demo-tfstate-bucket  (must be globally unique — change this)
#      - Region: us-east-1
#      - Enable versioning
#
#   2. DynamoDB table:
#      - Name: terraform-locks
#      - Partition key: LockID (String)
#      - Use default settings for everything else
# =============================================================================

terraform {
  backend "s3" {
    bucket         = "my-demo-tfstate-bucket"  # replace with your bucket name
    key            = "vpc-module/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}