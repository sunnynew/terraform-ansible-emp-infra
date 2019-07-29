
resource "aws_launch_configuration" "autoscale_launch" {
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.sec_web.id}"]
  key_name = "${var.key_name}"
  user_data = <<-EOF
              #!/bin/bash -x
              sudo apt-get -y update
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscale_group" {
  launch_configuration = "${aws_launch_configuration.autoscale_launch.id}"
  vpc_zone_identifier = ["${aws_subnet.PrivateSubnetA.id}","${aws_subnet.PrivateSubnetB.id}","${aws_subnet.PrivateSubnetC.id}"]
  #load_balancers = ["${aws_alb.alb.name}"]
  min_size = 1
  max_size = 3
  tag {
    key = "Name"
    value = "webServerASG"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "sec_web" {
  name        = "sec_web"
  description = "Used for autoscale group"
  vpc_id      = "${aws_vpc.default.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "sec_lb" {
  name = "sec_alb"
  vpc_id      = "${aws_vpc.default.id}"
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {  
  name            = "alb"  
  subnets         = ["${aws_subnet.PublicSubnetA.id}","${aws_subnet.PublicSubnetB.id}","${aws_subnet.PublicSubnetC.id}"]
  security_groups = ["${aws_security_group.sec_lb.id}"]
  internal        = false 
  idle_timeout    = 60   
  tags {    
    Name    = "alb"    
  }   
}

resource "aws_lb_target_group" "alb_target_group" {  
  name     = "alb-target-group"  
  port     = "80"  
  protocol = "HTTP"  
  vpc_id   = "${aws_vpc.default.id}"   
  tags {    
    name = "alb_target_group"    
  }   
  stickiness {    
    type            = "lb_cookie"    
    cookie_duration = 1800    
    enabled         = true 
  }   
  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/"    
    port                = 80
    matcher		= "200-499"
  }
}

resource "aws_autoscaling_attachment" "alb_autoscale" {
  alb_target_group_arn   = "${aws_lb_target_group.alb_target_group.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.autoscale_group.id}"
}

resource "aws_lb_listener" "alb_listener" {  
  load_balancer_arn = "${aws_lb.alb.arn}"  
  port              = 80  
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = "${aws_lb_target_group.alb_target_group.arn}"
    type             = "forward"  
  }
}

#Policy Scale Up
resource "aws_autoscaling_policy" "auto-scaling-policy-scale-up" {
  autoscaling_group_name = "${aws_autoscaling_group.autoscale_group.id}"
  name = "${var.auto-scaling-policy-name-scale-up}"
  adjustment_type = "${var.adjustment-type-scale-up}"
  scaling_adjustment = "${var.scaling-adjustment-scale-up}"
  cooldown = "${var.cooldown-scale-up}"
  policy_type = "${var.policy-type-scale-up}"
}

resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scale-up" {
  alarm_name = "${var.alarm-name-scale-up}"
  comparison_operator = "${var.comparison-operator-scale-up}"
  evaluation_periods = "${var.evaluation-periods-scale-up}"
  metric_name = "${var.metric-name-scale-up}"
  namespace = "${var.namespace-scale-up}"
  period = "${var.period-scale-up}"
  statistic = "${var.statistic-scale-up}"
  threshold = "${var.threshold-scale-up}"
  dimensions {
    "AutoScalingGroupName" = "${aws_autoscaling_group.autoscale_group.id}"
  }
    actions_enabled = true
    alarm_actions = ["${aws_autoscaling_policy.auto-scaling-policy-scale-up.arn}"]
}

#Policy Scale down
resource "aws_autoscaling_policy" "auto-scaling-policy-scale-down" {
  autoscaling_group_name = "${aws_autoscaling_group.autoscale_group.id}"
  name = "${var.auto-scaling-policy-name-scale-down}"
  adjustment_type = "${var.adjustment-type-scale-down}"
  scaling_adjustment = "${var.scaling-adjustment-scale-down}"
  cooldown = "${var.cooldown-scale-down}"
  policy_type = "${var.policy-type-scale-down}"
}

resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scale-down" {
  alarm_name = "${var.alarm-name-scale-down}"
  comparison_operator = "${var.comparison-operator-scale-down}"
  evaluation_periods = "${var.evaluation-periods-scale-down}"
  metric_name = "${var.metric-name-scale-down}"
  namespace = "${var.namespace-scale-down}"
  period = "${var.period-scale-down}"
  statistic = "${var.statistic-scale-down}"
  threshold = "${var.threshold-scale-down}"
  dimensions {
    "AutoScalingGroupName" = "${aws_autoscaling_group.autoscale_group.id}"
  }
  actions_enabled = true
  alarm_actions = ["${aws_autoscaling_policy.auto-scaling-policy-scale-down.arn}"]

}

#########################
# Bastion/Ansible Host  #
#########################

resource "aws_security_group" "bastion" {
  name        = "sec_bastion"
  description = "Used for bastion host"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = ["OFFICE_IP_ONLY"]
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
 }
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name        = "ansibleBastion"
  }
}

resource "aws_instance" "bastion" {
  ami                         = "${var.bastion_ami}"
  instance_type               = "${var.bastion_instance_type}"
  key_name                    = "${var.key_name}"
  monitoring                  = false
  security_groups             = ["${aws_security_group.bastion.id}"]
  subnet_id                   = "${aws_subnet.PublicSubnetA.id}"
  associate_public_ip_address = true
  iam_instance_profile        = "terraform-admin"

  tags {
        "Name" = "ansibleBastion"
    }

  provisioner "file" {
    source      = "scripts/ansible.sh"
    destination = "/tmp/ansible.sh"
  }
  #Used .pem for ansible_ssh_private_key_file option  
  provisioner "file" {
    source      = "scripts/ubuntu.pem"
    destination = "/tmp/ubuntu.pem"
  }
#Configure Ansible on bastion host.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ansible.sh",
      "/tmp/ansible.sh > /tmp/ansible.log",
    ]
#    inline = [
#      "sudo apt-get -y update",
#      "export DEBIAN_FRONTEND=noninteractive",
#      "sudo apt-get install python3-pip -y",
#      "sudo apt-add-repository ppa:ansible/ansible -y",
#      "sudo apt-get update -y",
#      "sudo apt-get install ansible -y",
#    ]
  }
  provisioner "remote-exec" {
    inline = [
      "chmod 600 /tmp/ubuntu.pem",
    ]
  }
  connection {
    type     = "ssh"
    user     = "ubuntu"
    password = ""
    private_key = "${file("scripts/ubuntu.pem")}"
  }
}

#########################
#       MySQL Host      #
#########################

resource "aws_security_group" "mysql" {
  name        = "sec_mysql"
  description = "Used for mysql host"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #MySQL Port
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
 }
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name        = "mysql"
  }
}

resource "aws_instance" "mysql" {
  ami                         = "${var.bastion_ami}"
  #availability_zone          = "${element(var.availability_zones, 0)}"
  security_groups             = ["${aws_security_group.mysql.id}"]
  instance_type               = "${var.bastion_instance_type}"
  key_name                    = "${var.key_name}"
  monitoring                  = false
  subnet_id		      = "${aws_subnet.PrivateSubnetA.id}"
  user_data = <<-EOF
              #!/bin/bash -x
              sudo apt-get -y update
              EOF
  tags {
    Name        = "mysqlServer"
  }
}
############

