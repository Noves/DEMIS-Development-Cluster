#############################
# DEMIS Database Credentials
#############################

variable "database_credentials" {
  type = list(object({
    username            = string
    password            = string
    secret-name         = string
    secret-key-user     = string
    secret-key-password = string
  }))
  sensitive   = true
  description = "List of Database Credentials for DEMIS services (a secret)"
  default     = []
}

variable "postgres_root_ca_certificate" {
  type        = string
  sensitive   = true
  description = "The Root CA Certificate for the Postgres Database in PEM format, encoded in base64"
}

variable "postgres_server_certificate" {
  type        = string
  sensitive   = true
  description = "The Server Certificate for the Postgres Database in PEM format, encoded in base64"
}

variable "postgres_server_key" {
  type        = string
  sensitive   = true
  description = "The Server Key for the Postgres Database in PEM format, encoded in base64"
}

variable "ars_bulk_upload_hmac_secret" {
  type        = string
  sensitive   = true
  description = "The secret to generate HMACs from the preferred usernames in the bulk upload service"
  default     = ""
}

variable "ars_bis_in_queue_encryption_current_secret" {
  type        = string
  sensitive   = true
  description = "The current encryption key for the bulk upload service. Must be 16 bytes"
  default     = ""
}

variable "ars_bis_in_queue_encryption_previous_secret" {
  type        = string
  sensitive   = true
  description = "The previous encryption key for the bulk upload service"
  default     = ""
}

variable "ars_secure_queue_encryption_current_secret" {
  type        = string
  sensitive   = true
  description = "The current encryption key for the secure queue. Must be 16 bytes"
  default     = ""
}

variable "rabbitmq_admin_username" {
  description = "The RabbitMQ admin username (user: rabbitmq-admin)"
  type        = string
}

variable "rabbitmq_admin_password" {
  description = "The RabbitMQ admin password"
  type        = string
  sensitive   = true
}

variable "rabbitmq_admin_password_hash" {
  description = "The RabbitMQ admin password hash for definitions.json"
  type        = string
  sensitive   = true
}

variable "rabbitmq_erlang_cookie" {
  description = "The RabbitMQ Erlang cookie for the application"
  type        = string
  sensitive   = true
}

####################################
# Per-Service RabbitMQ Credentials
####################################

variable "rabbitmq_bis_password" {
  description = "The RabbitMQ password for the Bulk Inbound Service (user: bulk-inbound-service)"
  type        = string
  sensitive   = true
}

variable "rabbitmq_bis_password_hash" {
  description = "The RabbitMQ password hash for the Bulk Inbound Service"
  type        = string
  sensitive   = true
}

variable "rabbitmq_smg_password" {
  description = "The RabbitMQ password for the Secure Message Gateway (user: svc-secure-message-gateway)"
  type        = string
  sensitive   = true
}

variable "rabbitmq_smg_password_hash" {
  description = "The RabbitMQ password hash for the Secure Message Gateway"
  type        = string
  sensitive   = true
}

variable "rabbitmq_ars_password_hash" {
  description = "The RabbitMQ password hash for the ARS Service"
  type        = string
  sensitive   = true
}
