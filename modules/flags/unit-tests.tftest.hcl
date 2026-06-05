# Test Feature Flags
run "feature_flags_correct_test" {
  command = plan

  variables {
    all_services = ["service1", "service2"]
    feature_flags = [
      {
        services   = ["service1", "service2"],
        flag_name  = "FEATURE_FLAG_TEST",
        flag_value = true
      },
      {
        services   = ["all"],
        flag_name  = "FEATURE_FLAG_TEST_ALL",
        flag_value = true
      }
    ]
  }

  assert {
    condition     = contains(keys(output.service_feature_flags), "service1") && contains(keys(output.service_feature_flags), "service2")
    error_message = "The Feature Flags are not grouped by service."
  }

  assert {
    condition     = output.service_feature_flags["service1"] == { "FEATURE_FLAG_TEST" = true, "FEATURE_FLAG_TEST_ALL" = true } && output.service_feature_flags["service2"] == { "FEATURE_FLAG_TEST" = true, "FEATURE_FLAG_TEST_ALL" = true }
    error_message = "The Feature Flag 'FEATURE_FLAG_TEST' is not set to true for the services."
  }
}

# Test Feature Flags with wrong value
run "feature_flags_wrong_test" {
  command = plan

  variables {
    all_services = ["service1", "service2"]
    feature_flags = [
      {
        services   = ["service1", "service2"],
        flag_name  = "feature_my_feature",
        flag_value = true
      }
    ]
  }

  expect_failures = [var.feature_flags]
}

# Test Configuration Options
run "config_options_correct_test" {
  command = plan

  variables {
    all_services = ["service1", "service2"]
    config_options = [
      {
        services     = ["service1", "service2"],
        option_name  = "CONFIG_TEST",
        option_value = "my_value"
      },
      {
        services     = ["service2"],
        option_name  = "CONFIG_TEST_2",
        option_value = "my_value_2"
      },
      {
        services     = ["all"],
        option_name  = "CONFIG_TEST_ALL",
        option_value = "all"
      }
    ]
  }

  assert {
    condition     = contains(keys(output.service_config_options), "service1") && contains(keys(output.service_config_options), "service2")
    error_message = "The Feature Flags are not grouped by service."
  }

  assert {
    condition     = output.service_config_options["service1"] == { "CONFIG_TEST" = "my_value", "CONFIG_TEST_ALL" = "all" } && output.service_config_options["service2"] == { "CONFIG_TEST" = "my_value", "CONFIG_TEST_2" = "my_value_2", "CONFIG_TEST_ALL" = "all" }
    error_message = "The Operational Flags 'CONFIG_TEST' and 'CONFIG_TEST_2' were not correctly set."
  }
}

# ignore null Configuration Options
run "config_options_correct_test_ignore_null" {
  command = plan

  variables {
    all_services = ["service1"]
    config_options = [
      {
        services     = ["service1"],
        option_name  = "CONFIG_TEST",
        option_value = null
      }
    ]
  }

  assert {
    condition     = contains(keys(output.service_config_options), "service1")
    error_message = "The Feature Flags are not grouped by service."
  }

  assert {
    condition     = output.service_config_options["service1"] == {}
    error_message = "Config option with null value should be ignored."
  }
}

# Test Configuration options with wrong value
run "config_options_wrong_test" {
  command = plan

  variables {
    all_services = ["service1", "service2"]
    config_options = [
      {
        services     = ["service1", "service2"],
        option_name  = "CONFIG_TEST",
        option_value = "my_value"
      },
      {
        services     = ["service1", "service2"],
        option_name  = "",
        option_value = ""
      }
    ]
  }

  expect_failures = [var.config_options]
}

# all services from feature flags must be in all_services list
run "all_services_ff_validation_test" {
  command = plan

  variables {
    all_services = ["service1"]
    feature_flags = [
      {
        services   = ["service1", "service2"],
        flag_name  = "FEATURE_FLAG_TEST",
        flag_value = true
      }
    ]
  }

  expect_failures = [var.all_services]
}

# all services from config options must be in all_services list
run "all_services_config_validation_test" {
  command = plan

  variables {
    all_services = ["service1"]
    config_options = [
      {
        services     = ["service1", "service2"],
        option_name  = "CONFIG_TEST",
        option_value = "my_value"
      }
    ]
  }

  expect_failures = [var.all_services]
}

# ---------------------------------------------------------------------------
# Compound-key tests
# ---------------------------------------------------------------------------

# Compound key "service1:env1" creates its own output entry and does NOT
# require an entry in all_services.
run "feature_flags_compound_key_test" {
  command = plan

  variables {
    all_services = ["service1"]
    feature_flags = [
      {
        services   = ["service1:env1"],
        flag_name  = "FEATURE_FLAG_COMPOUND",
        flag_value = true
      },
      {
        services   = ["service1"],
        flag_name  = "FEATURE_FLAG_PLAIN",
        flag_value = false
      }
    ]
  }

  # compound key becomes its own top-level key
  assert {
    condition     = contains(keys(output.service_feature_flags), "service1:env1")
    error_message = "Expected compound key 'service1:env1' to be present in service_feature_flags, got: ${jsonencode(keys(output.service_feature_flags))}"
  }

  # plain service key still exists
  assert {
    condition     = contains(keys(output.service_feature_flags), "service1")
    error_message = "Expected plain key 'service1' to be present in service_feature_flags, got: ${jsonencode(keys(output.service_feature_flags))}"
  }

  # compound key only carries the flag targeted at it
  assert {
    condition     = output.service_feature_flags["service1:env1"] == { "FEATURE_FLAG_COMPOUND" = true }
    error_message = "Expected service1:env1 to only carry FEATURE_FLAG_COMPOUND, got: ${jsonencode(output.service_feature_flags["service1:env1"])}"
  }

  # plain key only carries the flag targeted at it (not the compound one)
  assert {
    condition     = output.service_feature_flags["service1"] == { "FEATURE_FLAG_PLAIN" = false }
    error_message = "Expected service1 to only carry FEATURE_FLAG_PLAIN, got: ${jsonencode(output.service_feature_flags["service1"])}"
  }
}

# "all" broadcasts to both plain and compound keys
run "feature_flags_all_broadcasts_to_compound_key_test" {
  command = plan

  variables {
    all_services = ["service1"]
    feature_flags = [
      {
        services   = ["service1:env1"],
        flag_name  = "FEATURE_FLAG_COMPOUND",
        flag_value = true
      },
      {
        services   = ["all"],
        flag_name  = "FEATURE_FLAG_GLOBAL",
        flag_value = true
      }
    ]
  }

  # FEATURE_FLAG_GLOBAL must appear under compound key
  assert {
    condition     = lookup(output.service_feature_flags["service1:env1"], "FEATURE_FLAG_GLOBAL", null) == true
    error_message = "Expected 'all' flag to broadcast to compound key 'service1:env1', got: ${jsonencode(output.service_feature_flags["service1:env1"])}"
  }

  # FEATURE_FLAG_GLOBAL must also appear under plain key
  assert {
    condition     = lookup(output.service_feature_flags["service1"], "FEATURE_FLAG_GLOBAL", null) == true
    error_message = "Expected 'all' flag to broadcast to plain key 'service1', got: ${jsonencode(output.service_feature_flags["service1"])}"
  }
}

# Compound key in config_options works the same way
run "config_options_compound_key_test" {
  command = plan

  variables {
    all_services = ["service1"]
    config_options = [
      {
        services     = ["service1:env1"],
        option_name  = "CONFIG_COMPOUND",
        option_value = "compound_value"
      },
      {
        services     = ["service1"],
        option_name  = "CONFIG_PLAIN",
        option_value = "plain_value"
      }
    ]
  }

  assert {
    condition     = contains(keys(output.service_config_options), "service1:env1")
    error_message = "Expected compound key 'service1:env1' in service_config_options, got: ${jsonencode(keys(output.service_config_options))}"
  }

  assert {
    condition     = output.service_config_options["service1:env1"] == { "CONFIG_COMPOUND" = "compound_value" }
    error_message = "Expected service1:env1 to only carry CONFIG_COMPOUND, got: ${jsonencode(output.service_config_options["service1:env1"])}"
  }

  assert {
    condition     = output.service_config_options["service1"] == { "CONFIG_PLAIN" = "plain_value" }
    error_message = "Expected service1 to only carry CONFIG_PLAIN, got: ${jsonencode(output.service_config_options["service1"])}"
  }
}

# Compound keys don't need to be in all_services — this must NOT fail
run "compound_key_not_required_in_all_services_ff_test" {
  command = plan

  variables {
    all_services = ["service1"]
    feature_flags = [
      {
        services   = ["service1", "service1:env1", "service1:env2"],
        flag_name  = "FEATURE_FLAG_MULTI",
        flag_value = true
      }
    ]
  }

  assert {
    condition     = length(keys(output.service_feature_flags)) == 3
    error_message = "Expected 3 keys (service1, service1:env1, service1:env2), got: ${jsonencode(keys(output.service_feature_flags))}"
  }
}

# Compound keys don't need to be in all_services — same for config_options
run "compound_key_not_required_in_all_services_config_test" {
  command = plan

  variables {
    all_services = ["service1"]
    config_options = [
      {
        services     = ["service1", "service1:env1"],
        option_name  = "CONFIG_MULTI",
        option_value = "value"
      }
    ]
  }

  assert {
    condition     = length(keys(output.service_config_options)) == 2
    error_message = "Expected 2 keys (service1, service1:env1), got: ${jsonencode(keys(output.service_config_options))}"
  }
}

# ---------------------------------------------------------------------------
# Validation edge-case tests for compound key rules
# ---------------------------------------------------------------------------

# "all:" prefix must be rejected in feature_flags
run "feature_flags_all_compound_key_rejected_test" {
  command = plan

  variables {
    all_services = ["service1"]
    feature_flags = [
      {
        services   = ["all:service1"],
        flag_name  = "FEATURE_FLAG_TEST",
        flag_value = true
      }
    ]
  }

  expect_failures = [var.feature_flags]
}

# "all:" prefix must be rejected in config_options
run "config_options_all_compound_key_rejected_test" {
  command = plan

  variables {
    all_services = ["service1"]
    config_options = [
      {
        services     = ["all:service1"],
        option_name  = "CONFIG_TEST",
        option_value = "value"
      }
    ]
  }

  expect_failures = [var.config_options]
}

# Trailing colon must be rejected in feature_flags
run "feature_flags_trailing_colon_rejected_test" {
  command = plan

  variables {
    all_services = ["service1"]
    feature_flags = [
      {
        services   = ["service1:"],
        flag_name  = "FEATURE_FLAG_TEST",
        flag_value = true
      }
    ]
  }

  expect_failures = [var.feature_flags]
}

# Trailing colon must be rejected in config_options
run "config_options_trailing_colon_rejected_test" {
  command = plan

  variables {
    all_services = ["service1"]
    config_options = [
      {
        services     = ["service1:"],
        option_name  = "CONFIG_TEST",
        option_value = "value"
      }
    ]
  }

  expect_failures = [var.config_options]
}
