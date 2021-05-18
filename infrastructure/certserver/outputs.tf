output "private_key_pem" {
  description = "SSH public to access the server. Document and save the value in a secure location"
  value       = tls_private_key.priv_key.private_key_pem
}