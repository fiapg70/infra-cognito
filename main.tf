provider "aws" {
  region = "us-east-1"  # Replace with your preferred AWS region
}

# Variáveis
variable "user_pools" {
  type = map(object({
    name         = string
    client_name  = string
    callback_urls = list(string)
  }))
  default = {
    "sevenfood" = {
      name         = "sevenfood-user-pool"
      client_name  = "sevenfood-app-client"
      callback_urls = ["https://sevenfood.com.br/callback"]
    },
    "healthmed" = {
      name         = "healthmed-user-pool"
      client_name  = "healthmed-app-client"
      callback_urls = ["https://healthmed.com/callback"]
    }
  }
}

# Criando múltiplos user pools
resource "aws_cognito_user_pool" "user_pool" {
  for_each = var.user_pools

  name                   = each.value.name
  auto_verified_attributes = ["email"]
  username_attributes    = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = false
    invite_message_template {
      email_message = "Your username is {username} and temporary password is {####}."
      email_subject = "Your temporary password"
      sms_message   = "Your username is {username} and temporary password is {####}."
    }
  }

  schema {
    attribute_data_type = "String"
    developer_only_attribute = false
    mutable                 = true
    name                    = "email"
    required                = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
}

# Criando múltiplos user pool clients
resource "aws_cognito_user_pool_client" "user_pool_client" {
  for_each = var.user_pools

  name                          = each.value.client_name
  user_pool_id                  = aws_cognito_user_pool.user_pool[each.key].id
  allowed_oauth_flows           = ["code"]
  allowed_oauth_scopes          = ["email", "openid", "profile"]
  callback_urls                 = each.value.callback_urls
  allowed_oauth_flows_user_pool_client = true
  explicit_auth_flows           = ["ALLOW_REFRESH_TOKEN_AUTH"]
  generate_secret               = false
}

# Criando múltiplos user groups
resource "aws_cognito_user_group" "user_group" {
  for_each = var.user_pools

  name        = each.value.client_name
  user_pool_id = aws_cognito_user_pool.user_pool[each.key].id
  description = "User group for ${each.value.client_name}"
}
