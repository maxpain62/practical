variable "ec2-count" {
    type = number
    default = 1
}

variable "ec2-name" {
    type = string
    default = "instance"
}

variable "ami" {
    type = string
    default = "ami-02d26659fd82cf299" 
}

variable "instance_type" {
    type = string
    default = "t3a.medium"  
}

variable "security_groups" {
    type = list(string)
    default = [ "launch-wizard-1" ]
}

variable "key_name" {
  type = string
  default = "dpp-key"
}

variable "user_data" {
  type = string
}