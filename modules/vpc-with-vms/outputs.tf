output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "public_vm_id" {
  value = aws_instance.public_vm.id
}

output "public_vm_public_ip" {
  description = "Public IP of the bastion VM"
  value       = aws_instance.public_vm.public_ip
}

output "private_vm_id" {
  value = aws_instance.private_vm.id
}

output "private_vm_private_ip" {
  description = "Private IP of the application VM"
  value       = aws_instance.private_vm.private_ip
}