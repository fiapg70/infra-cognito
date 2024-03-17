provider "aws" {
  region = "us-east-1"  # Replace with your preferred AWS region
}

# Variáveis
variable "user_pool_name" {
  default = "sevenfood-user-pool"
}

variable "client_name" {
  default = "sevenfood-app-client"
}

resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name
  auto_verified_attributes = ["email"]
  username_attributes = ["email"]
  admin_create_user_config {
    allow_admin_create_user_only = false
    invite_message_template {
      email_message = "Your username is {username} and temporary password is {####}."
      email_subject = "Your temporary password"
      sms_message = "Your username is {username} and temporary password is {####}."
    }
  }
  schema {
    attribute_data_type = "String"
    developer_only_attribute = false
    mutable = true
    name = "email"
    required = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name = "sevenfood-app-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes    = ["email", "openid", "profile"]
  callback_urls           = ["https://sevenfood.com.br/callback"]
  allowed_oauth_flows_user_pool_client = true
  explicit_auth_flows = ["ALLOW_REFRESH_TOKEN_AUTH"]
  generate_secret = false
}

resource "aws_cognito_user_group" "user_group" {
  name        = var.client_name
  user_pool_id = aws_cognito_user_pool.user_pool.id
  description = "My user group description"
}

