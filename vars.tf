variable "myaccesskey" {
description = "Your AWS IAM Access Key"
type=string
sensitive=true
}

variable "mysecretkey" {
description = "Your AWS IAM Secret Access Key"
type=string
sensitive=true
}

variable "myregion" {
description = "Your required AWS Region"
type=string
}

variable "mycidr" {
description="CIDR for VPC you are planning"
}

variable "mycidrsub1" {
description="CIDR for Subnet of VPC you are planning"
}
