

resource "aws_security_group" "web" {
  name        = "${var.component-name}_web"
  description = "Allow ssh inbound traffic"
  vpc_id      = local.vpc_id


  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {

    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    "Name" = "${var.component-name}_web"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "app_sg" {
  name        = "${var.component-name}_lb_sg"
  description = "Allow inbound traffic from everywhere"
  vpc_id      = local.vpc_id


  ingress {
    description = " web sg"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups = [aws_security_group.web.id]
  }
  ingress {
    description = " web sg"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups = [aws_security_group.web.id]
  }

  ingress {
    description = " web sg"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.component-name}_sg"
  }
  lifecycle {
    create_before_destroy = true
  }
}


