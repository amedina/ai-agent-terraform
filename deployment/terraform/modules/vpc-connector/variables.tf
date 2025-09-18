variable "project_id" { type = string }
variable "region" { type = string }
variable "name" { type = string }
variable "network" { type = string }
variable "subnetwork" { type = string }
variable "ip_cidr_range" { type = string, default = null }
variable "min_instances" { type = number, default = 2 }
variable "max_instances" { type = number, default = 10 }
