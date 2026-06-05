# Section for generating the profile version labels and subset names for main deployments.
locals {
  non_canary_extra_profiles = can(length(var.deployment_information.canary.profiles)) && !can(length(var.deployment_information.canary.version)) ? var.deployment_information.canary.profiles : []
  raw_main_profiles         = var.deployment_information.main.profiles
  main_profiles             = distinct(compact(concat(local.raw_main_profiles, local.non_canary_extra_profiles)))

  subsets_main = yamldecode(templatefile("${path.module}/.scripts/subset.tftpl.yaml", {
    provisioning_mode = var.provisioning_mode
    versions          = local.main_profiles
    extra_versions    = local.non_canary_extra_profiles
    profile_type      = var.profile_type
    version           = var.deployment_information.main.version
    weight            = var.deployment_information.main.weight
  }))

  # Section for generating the profile version labels and subset names for canary deployments.
  canary_profiles = distinct(compact(can(length(var.deployment_information.canary.profiles)) ? var.deployment_information.canary.profiles : local.raw_main_profiles))

  subsets_canary = yamldecode(templatefile("${path.module}/.scripts/subset.tftpl.yaml", {
    provisioning_mode = var.provisioning_mode
    versions          = length(local.canary_profiles) > 0 ? local.canary_profiles : local.raw_main_profiles
    extra_versions    = []
    profile_type      = var.profile_type
    version           = can(length(var.deployment_information.canary.version)) ? var.deployment_information.canary.version : null
    weight            = can(length(var.deployment_information.canary.weight)) ? var.deployment_information.canary.weight : null
  }))

  # Section for generating the profile version labels and destination subset names for both main and canary deployments.
  destination_subsets = { main : local.subsets_main, canary : local.subsets_canary }
}
