output "profile_metadata" {
  description = "The metadata of the FHIR profiles used for the Validation Service, including their versions and the destination subsets for Istio routing."
  value       = module.validation_service_metadata
}
