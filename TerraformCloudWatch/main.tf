
provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_cloudwatch_metric_alarm" "myAlarm" {  
 alarm_name          = "alba-alarmCloud9Instance" 
 comparison_operator = "GreaterThanThreshold" 
 evaluation_periods  = "2"  
 namespace           = "AWS/EC2"  
 metric_name         = "CPUUtilization" 
 period              = "60"  
 statistic           = "Average"  
 threshold           = "1" 
 alarm_description   = "This is a test"  
 alarm_actions       = ["arn:aws:sns:eu-west-1:615958133247:Alba-test"] #SNS topic

 dimensions          ={  
  InstanceId = "i-0d3599c7f5b27a268" #Alba - cloud9Instance
 }   
} 


