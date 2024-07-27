output "user_pool_ids" {
  value = { for k, v in aws_cognito_user_pool.user_pool : k => v.id }
}

output "user_pool_client_ids" {
  value = { for k, v in aws_cognito_user_pool_client.user_pool_client : k => v.id }
}

output "user_pool_names" {
  value = { for k, v in aws_cognito_user_pool.user_pool : k => v.name }
}

output "client_callback_urls" {
  value = { for k, v in aws_cognito_user_pool_client.user_pool_client : k => v.callback_urls }
}

output "user_group_ids" {
  value = { for k, v in aws_cognito_user_group.user_group : k => v.id }
}

output "client_secrets" {
  value = { for k, v in aws_cognito_user_pool_client.user_pool_client : k => v.client_secret }
}