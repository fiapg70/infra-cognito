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

  deletion_protection = "INACTIVE"
  mfa_configuration   = "OFF"

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true 
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  schema {
    name                = "preferred_username"
    attribute_data_type = "String"
    required            = false
  }

  schema {
    name                = "custom:crm"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }

  schema {
    name                = "custom:cpf"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }

  username_configuration {
    case_sensitive = false
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
  explicit_auth_flows           = ["ALLOW_USER_PASSWORD_AUTH","ALLOW_REFRESH_TOKEN_AUTH"]
  generate_secret               = false
}

# Criando múltiplos user groups
resource "aws_cognito_user_group" "user_group" {
  for_each = var.user_pools

  name        = each.value.client_name
  user_pool_id = aws_cognito_user_pool.user_pool[each.key].id
  description = "User group for ${each.value.client_name}"
}

################################################################################
# Grupos
################################################################################

resource "aws_cognito_user_group" "doctors" {
  name         = "doctors"
  user_pool_id = aws_cognito_user_pool.user_pool["healthmed"].id
  description  = "Médicos da HealthMed"
}

resource "aws_cognito_user_group" "patients" {
  name         = "patients"
  user_pool_id = aws_cognito_user_pool.user_pool["healthmed"].id
  description  = "Pacientes da HealthMed"
}

################################################################################
# Users
################################################################################

# Medics
# ------------------------------

resource "aws_cognito_user" "doctor_1" {
  user_pool_id = aws_cognito_user_pool.user_pool["healthmed"].id
  username     = "597670-MG" # CRM 
  password     = "Admin@123"

  attributes = {
    "custom:id" = "87299678-a39f-46ff-a849-79c35f561945"
    name        = "Anna Galindo Rodrigues"
    email       = "anna.galindo.rodrigues@healthmed.com.br"
  }
}

resource "aws_cognito_user_in_group" "doctor_1" {
  user_pool_id = aws_cognito_user_pool.user_pool["healthmed"].id
  group_name   = aws_cognito_user_group.doctors.name
  username     = aws_cognito_user.doctor_1.username
}

# ----------

resource "aws_cognito_user" "doctor_2" {
  user_pool_id = aws_cognito_user_pool.user_pool["healthmed"].id
  username     = "236467-MG" # CRM 
  password     = "Admin@123"

  attributes = {
    "custom:id" = "3fb50be0-b77b-4f9f-8288-adcccb79a234"
    name        = "Heitor Bittencourt de Azevedo"
    email       = "heitor.bittencourt.azevedo@healthmed.com.br"
  }
}

resource "aws_cognito_user_in_group" "doctor_2" {
  user_pool_id = aws_cognito_user_pool.user_pool["healthmed"].id
  group_name   = aws_cognito_user_group.doctors.name
  username     = aws_cognito_user.doctor_2.username
}

# Pacientes
# ------------------------------

resource "aws_cognito_user" "patient_1" {
  user_pool_id = aws_cognito_user_pool.user_pool["healthmed"].id
  username     = "26550603269" # CPF
  password     = "Mudar@123"

  attributes = {
    name  = "Ketlin Silvana Aragão de Torres"
    email = "ketlin.silvana.aragao.torres@gmail.com"
  }
}

resource "aws_cognito_user_in_group" "patient_1" {
  user_pool_id = aws_cognito_user_pool.user_pool["healthmed"].id
  group_name   = aws_cognito_user_group.patients.name
  username     = aws_cognito_user.patient_1.username
}