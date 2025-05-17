variable "container_port" {
    description = "Port on which the container listens"
    type        = number
}


variable "region" {
    description = "AWS region to deploy the resources"
    type        = string
}

variable "desired_count" {
    description = "Desired number of ECS tasks"
    type        = number
}


variable "github_repo" {
  description = "GitHub repository in format owner/repo"
  type        = string
}
variable "profile" {
  description = "AWS CLI profile to use"
  type        = string

}