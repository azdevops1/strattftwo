
locals {
  region = "us-east-1"
  mandatory_tag = {
    Project        = "gitlabiac"
    Builder        = "SHI"
    Ower           = "CONILIUS"
    Group          = "DCS-IAC"
    Component_name = "gitlabiac"
  }
  vpc_id     = aws_vpc.gitlabiac_vpc[0].id
  creat_vpc  = var.custom_vpc
  azs        = data.aws_availability_zones.available.names
  subnet_ids = [aws_subnet.db_subnet[0].id, aws_subnet.db_subnet[1].id]
}