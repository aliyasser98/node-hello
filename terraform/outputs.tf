output "alb_dns_name" {
  value = aws_lb.nodejs_app_alb.dns_name
  description = "The DNS name of the ALB"
}