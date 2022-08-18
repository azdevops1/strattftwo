

variable "name" {
  type    = list(any)
  default = ["gitlabiac"]
}

variable "creat_instance" {
  type    = bool
  default = true

}
variable "owner" {
  type    = string
  default = "099720109477"
}

variable "component-name" {
  default = "gitlabiac"
}

variable "custom_vpc" {
  description = "VPC for gitlabiac Deployment"
  type        = bool
  default     = true
}
variable "gitlabiac_type" {
  description = "EC2 Instance type example:t2.xlarge"
  default     = "t2.xlarge"
}
variable "pub_subnetcidr" {
  type        = list(any)
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
  description = "list of public cidr"
}
variable "private_subnetcidr" {
  type        = list(any)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
  description = "list of private cidr"
}
variable "db_subnetcidr" {
  type        = list(any)
  default     = ["10.0.5.0/24", "10.0.7.0/24"]
  description = "list of database cidr"
}


variable "application_owner" {
  description = "Email Group for the Application owner."
  type        = string
  default     = "shi"
}
variable "access_key" {
  default = ""
}
variable "secret_key" {
  default = ""

}

variable "builder" {
  description = "Email for the builder of this infrastructure"
  type        = string
  default     = "airizarry@cloudbolt.io"
}

variable "line_of_business" {
  description = "Line of Business"
  type        = string
  default     = "Sales"
}
variable "ado" {
  description = "Compainy name for this project"
  type        = string
  default     = "shi"
}
variable "component_name" {
  description = "Name of the component."
  type        = string
  default     = "gitlabiac"
}


variable "myip" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}
