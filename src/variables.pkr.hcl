variable "vault" {
  type        = string
  default     = "vault"
  description = "The version of HashiCorp Vault in the format `vault` or 'vault-{version}'."

  validation {
    condition = var.vault == "vault" || can(regex("^vault-\\d+\\.\\d+\\.\\d+$", var.vault))
    error_message = "Must be either 'vault' or 'vault-{version}', where version follows semantic versioning of MAJOR.MINOR.PATCH. (e.g, vault-1.15.0)."
  }
}
