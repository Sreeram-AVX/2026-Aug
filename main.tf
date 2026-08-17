# =============================================================================
# Root configuration — calls the vpc-with-vms module
# =============================================================================

module "vpc" {
  source = "./modules/vpc-with-vms"

  project_name        = "my-demo"
  environment         = "dev"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  availability_zone   = "us-east-1a"
  ami_id              = "ami-0c02fb55956c7d316"   # Amazon Linux 2 (us-east-1)
  instance_type       = "t3.micro"
  key_name            = "my-ssh-key"               # replace with your key pair
  allowed_ssh_cidrs   = ["0.0.0.0/0"]             # replace with your IP
}

output "public_vm_ip" {
  value = module.vpc.public_vm_public_ip
}

output "private_vm_ip" {
  value = module.vpc.private_vm_private_ip
}