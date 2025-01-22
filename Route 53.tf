resource "aws_route53_zone" "syslog" {
  name = "wally.com"

  vpc {
    vpc_id     = module.vpc_japan.vpc_id
    vpc_region = "ap-northeast-1"
  }
  vpc {
    vpc_id     = module.vpc_NewYork.vpc_id
    vpc_region = "us-east-1"
  }
  vpc {
    vpc_id     = module.vpc_London.vpc_id
    vpc_region = "eu-west-2"
  }
  vpc {
    vpc_id     = module.vpc_Brazil.vpc_id
    vpc_region = "sa-east-1"
  }
  vpc {
    vpc_id     = module.vpc_Sydney.vpc_id
    vpc_region = "ap-southeast-2"
  }
  vpc {
    vpc_id     = module.vpc_HongKong.vpc_id
    vpc_region = "ap-east-1"
  }
  vpc {
    vpc_id     = module.vpc_Cali.vpc_id
    vpc_region = "us-west-1"
  }
  depends_on = [
    aws_instance.syslog-server,
    aws_cloudwatch_metric_alarm.syslog,
    aws_route53_health_check.syslog,
  ]
}
resource "aws_route53_record" "syslog" {
  zone_id        = aws_route53_zone.syslog.zone_id
  name           = "wally.com"
  type           = "A"
  ttl            = 30
  records        = [aws_instance.syslog-server.private_ip]
  set_identifier = "primary-syslog-server"
  failover_routing_policy {
    type = "PRIMARY"
  }
  health_check_id = aws_route53_health_check.syslog.id
  depends_on = [
    aws_route53_zone.syslog,
    aws_instance.syslog-server,
    aws_cloudwatch_metric_alarm.syslog,
    aws_route53_health_check.syslog
  ]
}


resource "aws_route53_record" "syslog2" {
  zone_id        = aws_route53_zone.syslog.zone_id
  name           = "wally.com"
  type           = "A"
  ttl            = 30
  records        = [aws_instance.syslog-server2.private_ip]
  set_identifier = "secondary-syslog-server"
  failover_routing_policy {
    type = "SECONDARY"
  }
  depends_on = [
    aws_route53_zone.syslog,
    aws_instance.syslog-server2
  ]
}

