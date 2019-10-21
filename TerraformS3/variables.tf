variable "aws_region" {
  default = "eu-west-1"
}

variable "enabled" {
  type        = bool
  description = "Set to `false` to prevent the module from creating any resources"
  default     = true
}

variable "lifecycle_rule_enabled" {
  type        = bool
  description = "Enable lifecycle events on this bucket"
  default     = false
}
variable "lifecycle_rule_enabled_2" {
  type        = bool
  description = "Enable lifecycle events on this bucket"
  default     = false
}

variable "versioning_enabled" {
  type        = bool
  description = "A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket"
  default     = false
}

variable "lifecycle_prefix" {
  type        = string
  description = "Prefix filter. Used to manage object lifecycle events"
  default     = ""
}