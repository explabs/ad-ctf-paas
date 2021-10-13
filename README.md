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

## Monitoring
### Ansible
Install Ansible: `sudo apt install ansible`
Install community.libvirt collection from ansible-galaxy: `ansible-galaxy collection install community.libvirt`
### OpenDistro
#### Run service
```
sudo sysctl -w vm.max_map_count=262144
docker-compose up -d
```
### Packetbeat
Network monitoring for elasticsearch

[Documentation](https://www.elastic.co/guide/en/beats/packetbeat/current/index.html)
#### Download
```
curl -L -O https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-7.14.1-amd64.deb
sudo dpkg -i packetbeat-7.14.1-amd64.deb
```
#### Run
Copy packetbeat config
```
cp monitoring/network/packetbeat.yml /etc/packetbeat/packetbeat.yml
```
Install Dashboards
```
sudo packetbeat setup --dashboards
```
Run packetbeat
```
sudo packetbeat  -e
```


### Auditd

To show USER_CMD `cmd` field use follow command on VM:
```
sudo ausearch -ua soc -m USER_CMD | grep cmd | awk '{print $8}' | cut -c 5- |  while read line; do echo $line | xxd -r -p; echo; done
```


### Virtual networks
#### Create bridge network
example of config
```
<network connections='1'>
  <name>virtbr-team1</name>
  <forward mode='nat'/>
  <bridge name='team-br1'/>
  <domain name='virtbr-team1'/>
  <ip address='10.0.1.254' netmask='255.255.255.0'>
  <dhcp>
    <range start='10.0.1.11' end='10.0.1.253'/>
  </dhcp>
  </ip>
</network>
```
Create network from config
```
virsh net-create team1.xml
```
Enter blank line at the end of file (I don't understand why this is needed)
```
virsh net-edit --network virtbr-team1
```
Enable autostart (if server will be restarted)
```
virsh net-autostart virtbr-team1
```
