resource "aws_route53_health_check" "syslog" {
  type                            = "CLOUDWATCH_METRIC"
  cloudwatch_alarm_name           = aws_cloudwatch_metric_alarm.syslog.alarm_name
  cloudwatch_alarm_region         = "ap-northeast-1"
  insufficient_data_health_status = "Unhealthy" #if the last known data point is set to "healthy", then it will assume it's healthly so this must be set to "Unhealthy"
  provisioner "local-exec" {                    #waits 60 seconds after the health check initializes; this is for the CloudWatch Alarm + Health Check + Route 53 Failover routing dependency chain.
    command = "sleep 60"
  }
  tags = {
    Name = "syslog"
  }
  depends_on = [
    aws_instance.syslog-server,
    aws_cloudwatch_metric_alarm.syslog
  ]
}