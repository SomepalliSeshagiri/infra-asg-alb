output "alb_dns_name" {
  description = "Public DNS name to access the app"
  value = aws_lb.alb.dns_name
}