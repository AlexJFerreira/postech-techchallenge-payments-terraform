provider "aws" {
    region = var.region
  
}

resource "aws_iam_role" "role-elb" {
  name = "role-elb-role-payments"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "tf-ellb" {
  name = "aws-elasticbeanstalk-ec2-role-payments" # use the same name as the default instance profile

  role = aws_iam_role.role-elb.name
}
resource "aws_elastic_beanstalk_application" "tf-techchallenge-payments" {
  name                = "techchallenge-payments-app"
  description = "techchallenge-payments tf-elb"
  
}

resource "aws_elastic_beanstalk_environment" "tf-techchallenge-payments-env" {
  name                = "techchallenge-payments-env"
  application = aws_elastic_beanstalk_application.tf-techchallenge-payments.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.2.4 running ${var.language}"
  tier = "WebServer"
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.tf-ellb.name
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCID"
    value = var.vpc_id

  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.subnet)
  }
  setting {
    namespace = "aws:ec2:instances"
    name = "InstanceTypes"
    value = var.instance_type
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }
}

output "url" {
  value = aws_elastic_beanstalk_environment.tf-techchallenge-payments-env.endpoint_url
}