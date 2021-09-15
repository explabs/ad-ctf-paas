# Attack-Defence Infrastructure
Project automating the process of deploying infrastructure for Information Security competitions
## Dependencies
### Terraform
Official documentation: [Terraform](https://www.terraform.io/downloads.html)

_Note: For use autocomplete use `terraform -install-autocomplete` and restart your shell._
### libvirt
TODO: add links to install instructions for VM and Host 
### Terraform Libvirt Provider
You can install from source: [Github](https://github.com/dmacvicar/terraform-provider-libvirt)
### Ubuntu image
Download ubuntu cloud image:
```
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
```
You need to download image in project root dir, or change path in `main.tf`.
## Deploy
Deploy infrastructure on your local machine
```
terraform init
terraform plan
terraform apply
```
For destroy infrastructure use `terraform destroy`
