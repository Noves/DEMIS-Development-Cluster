locals {
  origin_feature_service_keys = flatten([for entry in var.feature_flags : lookup(entry, "services", [])])
  origin_config_service_keys  = flatten([for entry in var.config_options : lookup(entry, "services", [])])
  feature_keys                = compact(distinct(concat(local.origin_feature_service_keys, var.all_services)))
  option_keys                 = compact(distinct(concat(local.origin_config_service_keys, var.all_services)))
  # extract all the feature flags, grouped by service
  service_feature_flags = {
    for s in local.feature_keys :
    s => {
      for ff in var.feature_flags :
      ff.flag_name => ff.flag_value
      if contains(ff.services, s) || contains(ff.services, "all")
    }
  }
  # extract all the configuration options, grouped by service
  service_config_options = {
    for s in local.option_keys :
    s => {
      for co in var.config_options :
      co.option_name => co.option_value
      if(contains(co.services, s) || contains(co.services, "all")) && co.option_value != null
    }
  }
}
