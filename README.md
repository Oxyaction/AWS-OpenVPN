## AWS Ansible OpenVPN

Terraform and Ansible scripts to setup OpenVPN.

### Setup

#### Requirements
```
terraform ~0.11.7
ansible ~2.6.1
```

#### Configure terraform
1. run `terraform init`
2. create `terraform.tfvars` file
3. Add your AWS credentials variables to it:
```
access_key = "AWS_ACCESS_KEY"
secret_key = "AWS_SECRET_KEY"
public_key_path = "~/.ssh/id_rsa.pub" # path to your public ssh key
ssh_ips = ["193.91.1.1/32"] # your ip to access AWS instance by ssh
```
#### Set up your brand new AWS instance
`terraform apply`

When you have your ec2 instance up and running  
you can start provisioning with ansible:

`ansible-playbook -i ec2.py vpn.ym`

Now your OpenVPN is up and running 🚀

#### Issuing new certificate

`ansible-playbook -i ec2.py issue_client_cert.yml`  

you will be prompted to enter `client_name`.  
Than your OpenVPN configuration will be at `tmp/${client_name}`.  

To add it, simply drag `.ovpn` file to Tunnelblick.  
And now you can connect and use your own VPN.

#### Revoking certificate

`ansible-playbook -i ec2.py revoke_client_cert.yml`  

you will be prompted to enter `client_name`.

### Clear all

Simply run `terraform destroy`