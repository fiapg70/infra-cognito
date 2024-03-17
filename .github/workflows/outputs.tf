output "user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.user_pool_client.id
}

output "user_pool_name" {
  value = aws_cognito_user_pool.user_pool.name
}

output "client_callback_url" {
  value = aws_cognito_user_pool_client.user_pool_client.callback_urls[0]
}

output "user_group_id" {
  value = aws_cognito_user_group.user_group.id
}
