# Modify cloud image 
## Download image
Download Ubuntu 20.04 cloud image 
```
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
```
## Customization of the image
### Upload local directory
Copy folder with tasks to `/`
```
sudo virt-customize -a focal-server-cloudimg-amd64.img --copy-in ../tasks:/
```
### Run shell script
Run example script to install docker, docker-compose...
```
sudo virt-customize -a focal-server-cloudimg-amd64.img --run scripts/install.sh 
```
### Final command
```
sudo virt-customize -a focal-server-cloudimg-amd64.img --copy-in ../tasks:/ --run scripts/install.sh 
```
## Upload custom image
```
openstack image create --private --container-format bare --disk-format qcow2 --property store=s3 --file focal-server-cloudimg-amd64.img ubuntu-custom
```
Now you can use `ubuntu-custom` image in your cloud
