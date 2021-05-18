output "client_vpn_endpoint_id" {
  value = aws_ec2_client_vpn_endpoint.client-vpn-endpoint.id
}

output "client_vpn_sg_id" {
  value = aws_security_group.client-vpn-sg.*.id
}