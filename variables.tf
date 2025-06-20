variable "organization" {
  description = "The Google Cloud organization configuration."
  type = object({
    id                    = string
    name                  = string
    directory_customer_id = string
    domain                = string
    billing_account       = optional(string, null)
  })
  validation {
    condition     = can(regex("[0-9]+", var.organization.id))
    error_message = "ERROR: organization.id must be a number"
  }
  validation {
    condition     = startswith(var.organization.name, "organizations/")
    error_message = "ERROR: organization.name must be in the format organizations/*"
  }
}

