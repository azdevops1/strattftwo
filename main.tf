

data "aws_ami" "ubuntu_instance_ami" {
  most_recent = true
  owners      = [var.owner]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_key_pair" "shi_key" {
  key_name           = "shi_key"
  include_public_key = true
  filter {
    name   = "tag:Name"
    values = ["shi_key"]
  }
}


output "pub_ip" {
  value = [for pub in aws_instance.gitlabiac : pub.public_ip]
}
resource "aws_instance" "gitlabiac" {
  count           = var.creat_instance ? length(var.name) : 0
  ami             = data.aws_ami.ubuntu_instance_ami.id
  instance_type   = var.gitlabiac_type
  key_name        = data.aws_key_pair.shi_key.key_name
  security_groups = [aws_security_group.app_sg.id]
  subnet_id       = aws_subnet.public_subnet[0].id
  user_data = templatefile("${path.module}/template/bash.sh")
  root_block_device {
    volume_size = 50
    # GB
    volume_type = "gp2"
  }

  tags = {
    Name = "gitlabiac-${count.index + 1}" #${count.index + 1}
  }

  lifecycle {
    ignore_changes = [
      security_groups,
    ]
  }

}


//Creating a ALB for HA 
resource "aws_lb" "gitlabiac-alb" {
  count              = var.creat_instance ? 1 : 0
  name               = "gitlabiac-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets            = slice(aws_subnet.public_subnet[*].id, 0, 2)
}

//creating target group
resource "aws_lb_target_group" "tg" {
  count       = var.creat_instance ? length(var.name) : 0
  name        = "gitlabiac-tg-bn"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
}
//target group association
resource "aws_lb_target_group_attachment" "tgattachment" {
  count            = var.creat_instance ? length(var.name) : 0
  target_group_arn = aws_lb_target_group.tg[count.index].arn
  target_id        = var.creat_instance ? aws_instance.gitlabiac[count.index].id : 0
  port             = 80
  depends_on = [
    aws_instance.gitlabiac
  ]
}

//creating ALB listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.gitlabiac-alb[0].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
//Listener Rule 
resource "aws_lb_listener_rule" "rule" {
  count        = var.creat_instance ? 1 : 0
  listener_arn = aws_lb_listener.listener.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[count.index].arn
  }
  condition {
    path_pattern {
      values = ["/var/www/html/index.html"]
    }
  }
}
