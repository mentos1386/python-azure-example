variable "name" {
  description = "The name of the application"
  type        = string
}

variable "image" {
  description = "The image to run"
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}
