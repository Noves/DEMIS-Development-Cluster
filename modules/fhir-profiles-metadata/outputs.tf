output "destination_subsets" {
  value       = local.destination_subsets
  description = "values for the destination subsets"
}

output "current_profile_versions" {
  value       = try(var.deployment_information.canary.version, null) == null ? (length(local.non_canary_extra_profiles) == 0 ? local.main_profiles : local.non_canary_extra_profiles) : local.canary_profiles
  description = "values for the current profile versions depending on the is_canary flag"
}

output "canary_profile_versions" {
  value       = local.canary_profiles
  description = "values for the canary profile versions"
}

output "main_profile_versions" {
  value       = local.main_profiles
  description = "values for the main profile versions"
}
