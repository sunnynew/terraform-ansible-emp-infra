# Automate infra for python flask app using Terraform and Ansible

- Cloud: AWS
- AMI : ubuntu 18.04
- Region: us-east-2

 - Infra created by Terraform 
	- VPC:  Multi AZ public and private subnet, NAT, different security group etc..
	- ALB: target group, launch config, autoscaling policies
	- EC2: As per current setting, we will have 1 EC2 in ASG [Private Subnet]
	- Bastion: used as ansible, Ansible is auto configure using a bash script executed using provisioner [Public Subnet]
	- MySQL: database server, configured using Ansible playbook. [Private Subnet]

Prerequisites:
  - terraform
  - AWS account
  - IAM user with admin rights
  - key pair

Steps to install terraform on linux
-----------------------------------
1). mkdir terraform

2). cd terraform

3). wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip

4). unzip terraform_0.11.13_linux_amd64.zip 

5). mv terraform /usr/local/bin/

Steps to create infrastructure on AWS:
-------------------------------------
1). Git clone https://github.com/sunnynew/terraform-ansible-emp-infra.git

2). cd terraform

3). Change values in variables.tf file : access_key, secret_key, key-pair-name

4). Copy .pem file under scripts/ folder

5). `terraform init`

6). `terraform apply`

7). Save ALB endpoint, will use this to access our flask application.


Web Application: Python Flask and MySQL
--------------------------------------
Sample RESTful API which provides a service for storing, updating, retrieving and deleting employee entities represented in JSON. Basic authentication is implemented which prompt user to enter `username` and `password`. MySQL database is used to store employee data.

- Ansible is used to setup required software in servers [Application and Database] 
- Used Gunicorn to serve application through WSGI, which is the traditional way that Python webapps are served. Gunicorn create a Unix socket.
- Nginx as webserver
- Request flow :  User <-> ALB <-> Nginx <-> The socket <-> Gunicorn

Steps to setup application and database using Ansible
-----------------------------------------------------
- MySQL

1). Git clone https://github.com/sunnynew/terraform-ansible-emp-infra.git [skip if you already cloned]

2). cd ansible-playbooks/emp-mysql/

3). edit hosts file and update IP of mysql server. [EC2 with mysqlServer name tag]

4). `ansible-playbook mysql-playbook.yml`

- Employee Python Flask Application

1). Git clone https://github.com/sunnynew/terraform-ansible-emp-infra.git [skip if you already cloned]

2). cd ansible-playbooks/emp-app-flask/

3). Edit hosts file and update `webservers` IP and `mysql_server` IP

4). `ansible-playbook app-playbook.yml`

Now you can access the application using ALB endpoint. Open browser and check. Authorization details :  `username: username, password: password`

Application EndPoints:
----------------------

- /add - method=POST : Add new employee details.
- /emps - method=GET : List all employees details.
- /emp/<id> - method=GET : Get employee record based on employeeCode.
- /update - method=PUT : Update employee records.
- /delete/<id> - method=DELETE : Delete employee record based on employeeCode.
- /health - method=GET : Check app health.
 
Use `curl` or `postman` to Insert, update, delete records.

Curl commands for reference:
---------------------------
Insert new record

`curl -X POST http://<ALB>/add -H 'Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ='  -H 'Content-Type: application/json' -d '{
	"userId":"Raj",
	"jobTitleName":"Developer",
	"firstName":"Raj",
	"lastName":"Kumar",
	"preferredFullName":"Raj Kumar",
	"employeeCode":"E3",
	"region":"IN",
	"phoneNumber":"123-456744",
	"emailAddress":"raj@gmail.com"
}'`

Update record

`curl -X PUT http://<ALB>/add -H 'Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ='  -H 'Content-Type: application/json' -d '{
	"userId":"Raj",
	"jobTitleName":"Developer",
	"firstName":"Raj",
	"lastName":"Kumar",
	"preferredFullName":"Raj Kumar",
	"employeeCode":"E3",
	"region":"IN",
	"phoneNumber":"123-4568989”,
	"emailAddress":"raj@gmail.com"
}'`

Delete Record

`curl -X DELETE http://<ALB>/delete/E3 -H 'Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ='`


