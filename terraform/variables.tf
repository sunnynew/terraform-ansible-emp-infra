variable "access_key" {
  description = "AWS ACCEE_KEY"
  default     = "XXXXXX"
}

variable "secret_key" {
  description = "AWS SECRETE_KEY"
  default     = "XXXXXX"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "key-pair-name"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-2"
}
variable "aws_amis" {
  default = {
    us-east-2 = "ami-0c55b159cbfafe1f0"
  }
}
variable "default_ami" {
  default = "ami-0c55b159cbfafe1f0"
}
variable "bastion_instance_type" {
  default = "t2.small"
}
variable "bastion_ami" {
  default = "ami-0c55b159cbfafe1f0"
}
variable "vpc_cidr" {
    default = "10.2.0.0/20"
  description = "the vpc cdir range"
}
variable "public_subnet_a" {
  default = "10.2.0.0/24"
  description = "Public subnet AZ A"
}
variable "public_subnet_b" {
  default = "10.2.4.0/24"
  description = "Public subnet AZ B"
}
variable "public_subnet_c" {
  default = "10.2.8.0/24"
  description = "Public subnet AZ C"
}
variable "private_subnet_a" {
  default = "10.2.1.0/24"
  description = "Private subnet AZ A"
}
variable "private_subnet_b" {
  default = "10.2.5.0/24"
  description = "Private subnet AZ B"
}
variable "private_subnet_c" {
  default = "10.2.9.0/24"
  description = "Private subnet AZ C"
}

### Autoscalling Variables ###
variable "auto-scaling-policy-name-scale-up" {
  default  = "cpu-policy-scale-up"
}
variable "adjustment-type-scale-up" {
  default = "ChangeInCapacity"
}
variable "scaling-adjustment-scale-up" {
  default = "1"
}
variable "cooldown-scale-up" {
  default = "300"
}
variable "policy-type-scale-up" {
  default = "SimpleScaling"
}
#Auto-Scaling Policy Cloud-Watch Alarm-Scale-Up
variable "alarm-name-scale-up" {
  default = "cpu-alarm-scale-up"
}
variable "comparison-operator-scale-up" {
  default = "GreaterThanOrEqualToThreshold"
}
variable "evaluation-periods-scale-up" {
  default = "2"
}
variable "metric-name-scale-up" {
  default = "CPUUtilization"
}
variable "namespace-scale-up" {
  default = "AWS/EC2"
}
variable "period-scale-up" {
  default = "120"
}
variable "statistic-scale-up" {
  default = "Average"
}
variable "threshold-scale-up" {
  default = "70"
}
#Auto-Scaling Policy-Scale-down
variable "auto-scaling-policy-name-scale-down" {
  default = "cpu-policy-scale-down"
}
variable "adjustment-type-scale-down" {
  default = "ChangeInCapacity"
}
variable "scaling-adjustment-scale-down" {
  default = "-1"
}
variable "cooldown-scale-down" { 
  default = "300"
}
variable "policy-type-scale-down" {
  default = "SimpleScaling"
}

#Auto-Scaling Policy Cloud-Watch Alarm-Scale-down
variable "alarm-name-scale-down" {
  default = "cpu-alarm-scale-down"
}
variable "comparison-operator-scale-down" {
  default = "LessThanOrEqualToThreshold"
}
variable "evaluation-periods-scale-down" {
  default = "2"
}
variable "metric-name-scale-down" {
  default = "CPUUtilization"
}
variable "namespace-scale-down" {
  default = "AWS/EC2"
}
variable "period-scale-down" { 
  default = "120"
}
variable "statistic-scale-down" {
  default = "Average"
}
variable "threshold-scale-down" {
  default = "50"
}

