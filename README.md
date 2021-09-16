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
Download centos cloud image:
```
wget https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-ec2-8.1.1911-20200113.3.x86_64.qcow2
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

## Connection
Connection to the VMs via ssh: 
```
ssh -i user_rsa user@ip
```
## Troubleshooting
If you encounter with `Could not open <path_to_file>: Permission denied` double check that `security_driver = "none"` is uncommented in `/etc/libvirt/qemu.conf` and issue `sudo systemctl restart libvirtd` to restart the daemon.
