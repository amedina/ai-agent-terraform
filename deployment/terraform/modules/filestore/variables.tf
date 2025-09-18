variable "project_id" { type = string }
variable "location" { type = string }
variable "name" { type = string }
variable "tier" { type = string, default = "BASIC_SSD" }
variable "capacity_gb" { type = number, default = 1024 }
variable "share_name" { type = string, default = "share" }
variable "network" { type = string }
variable "reserved_ip_range" { type = string }
