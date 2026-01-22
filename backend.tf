terraform {
  backend "s3" {
    bucket = "fintech-terraform-state-voncleph"
    key    = "fintech/terraform.tfstate"
    region = "eu-north-1"

    # 🔒 LOCKING CONFIGURATION
    # We use DynamoDB to lock the state file during 'apply'.
    # This prevents race conditions where two developers might
    # corrupt the state by writing to it simultaneously.
    dynamodb_table = "fintech-terraform-locks"
    encrypt        = true
  }
}
