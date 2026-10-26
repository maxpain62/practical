variable "instance_count" {
  type    = number
  default = 2
}

variable "ami" {
  type    = string
  default = "ami-02d26659fd82cf299"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "key_name" {
  type    = string
  default = "dpp-key"
}