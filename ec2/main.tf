resource "aws_launch_template" "launch_template" {
  name = "ghost_template"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
    }
 }
    image_id = "ami-09c23707327dce31d"
    instance_type = "t2.micro"
    monitoring {
    enabled = true
  }
  vpc_security_group_ids = ["sg-00f91427556f8f4fc", "sg-0379d26f8a39d00d3","sg-0a2e80c94a642857f"]
  disable_api_termination = false  
}

resource "aws_lb_target_group" "test" {
  name     = "ghost-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}


resource "aws_elb" "elb" {
  name               = "app-lb"
  subnets            = var.public_subnet_ids
  internal           = false
  security_groups    = [var.private_sg_ASG]
    listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:ap-south-1:763999771063:certificate/b1b3dc4d-f99b-45d8-b19a-bc6317b7181c"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }
}

/* required field for ALB for flow logs 
resource "aws_s3_bucket" "b" {
  bucket = "Flow Logs for ghost"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
*/


/* Doubt
resource "aws_autoscaling_policy" "example" {
  # ... other configuration ...
    autoscaling_group_name = aws_autoscaling_group.asg.name


  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}
 */

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  elb                    = aws_elb.elb.id
}

resource "aws_autoscaling_group" "asg" {
  name                      = "ghost-auto-scaling-test"
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  /* vpc_zone_identifier       = var.private_subnet_ids */
  availability_zones        =  var.availability_zones_ASG

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}


