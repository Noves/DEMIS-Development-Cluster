# Feature Flags are boolean values that are used to enable or disable features in the application
variable "feature_flags" {
  type = list(object({
    services   = list(string)
    flag_name  = string
    flag_value = bool
  }))
  description = "Defines a list of feature flags that belong to services"
  default     = []

  validation {
    condition     = alltrue([for ff in var.feature_flags : alltrue([for s in ff.services : !startswith(trimspace(s), "all:")])])
    error_message = "Feature flags cannot be defined for all services using a compound key for 'all' (e.g. 'all:*'), but must use the reserved keyword 'all' without a compound key to define flags for all services"
  }

  validation {
    condition     = length(var.feature_flags) > 0 ? alltrue([for ff in var.feature_flags : startswith(ff.flag_name, "FEATURE_FLAG_")]) : true
    error_message = "Feature flags must start with the prefix 'FEATURE_FLAG_'"
  }

  validation {
    condition     = alltrue([for ff in var.feature_flags : alltrue([for s in ff.services : !endswith(trimspace(s), ":")])])
    error_message = "all_services must contain only service names or 'all', but not colon. without a compound key (e.g. 'my-service:'): ${jsonencode(flatten([for ff in var.feature_flags : [for s in ff.services : s if endswith(trimspace(s), ":")]]))}"
  }
}

# Configuration Options contain String values that are used to configure the application
variable "config_options" {
  type = list(object({
    services     = list(string)
    option_name  = string
    option_value = string
  }))
  description = "Defines a list of configuration options that belong to services"
  default     = []

  validation {
    condition     = length(var.config_options) > 0 ? alltrue([for co in var.config_options : length(co.option_name) > 0 && (co.option_value == null || length(co.option_value) >= 0)]) : true
    error_message = "Configuration options must not be empty"
  }
  validation {
    condition     = alltrue([for co in var.config_options : alltrue([for s in co.services : !startswith(trimspace(s), "all:")])])
    error_message = "Configuration options cannot be defined for all services using a compound key for 'all' (e.g. 'all:*'), but must use the reserved keyword 'all' without a compound key to define options for all services"
  }

  validation {
    condition     = alltrue([for co in var.config_options : alltrue([for s in co.services : !endswith(trimspace(s), ":")])])
    error_message = "all_services must contain only service names or 'all', but not colon. without a compound key (e.g. 'my-service:'): ${jsonencode(flatten([for co in var.config_options : [for s in co.services : s if endswith(trimspace(s), ":")]]))}"
  }
}

variable "all_services" {
  type        = list(string)
  description = "List of all services in the deployment"
  default     = []

  validation {
    condition     = length(setsubtract(distinct(flatten([for ff in var.feature_flags : [for s in ff.services : s if !strcontains(trimspace(s), ":")]])), concat(var.all_services, ["all"]))) == 0
    error_message = "there are feature flags defined for services that are not in the all_services list: ${jsonencode(setsubtract(distinct(flatten([for ff in var.feature_flags : [for s in ff.services : s if !strcontains(s, ":")]])), concat(var.all_services, ["all"])))}"
  }
  validation {
    condition     = length(setsubtract(distinct(flatten([for co in var.config_options : [for s in co.services : s if !strcontains(trimspace(s), ":")]])), concat(var.all_services, ["all"]))) == 0
    error_message = "there are config options defined for services that are not in the all_services list: ${jsonencode(setsubtract(distinct(flatten([for co in var.config_options : [for s in co.services : s if !strcontains(s, ":")]])), concat(var.all_services, ["all"])))}"
  }
}
