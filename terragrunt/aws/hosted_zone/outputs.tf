output "hosted_zone_id" {
  description = "Route53 hosted zone ID that will hold our DNS records"
  value       = aws_route53_zone.github_secret_scanning.zone_id
}
