variable "api_name" {
    type = string
}

variable "create" {
    type = bool
    default = true
}

variable "create_custom_domain" {
    type = bool
    default = true
}

variable "custom_domain_name" {
    type = string
}

variable "custom_domain_path" {
    type = string
}

variable "custom_domain_acm_certificate_arn" {
    type = string
}

variable "routes" {
    type = map(any)
    default = {}
}

variable "stage_name" {
    type = string
}