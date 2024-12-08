variable "datadog_api_key" {
  description = "Datadog API Key"
  default     = ""
}

variable "datadog_app_key" {
  description = "Datadog APP Key"
  default     = ""
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instances"
  default     = "ami-0c94855ba95c71c99"
}
