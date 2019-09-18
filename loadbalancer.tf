resource "aws_elb" "gogo" {
  name = "gogolb"
  subnets = ["${aws_subnet.gogo_pub1.id}", "${aws_subnet.gogo_pub2.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "gogo-elb"
  }
}

output "lb_address" {
  value = "${aws_elb.gogo.dns_name}"
}

resource "aws_launch_configuration" "gogo_lconf" {
  name          = "gogo_config"
  image_id      = "ami-045306a373f083e8c"
  instance_type = "t2.micro"
  key_name = "GoGo_key"
  security_groups = ["${aws_security_group.gogo_SG.id}"]
}

resource "aws_autoscaling_group" "gogo_scalinggroup" {
  name = "gogo-autoscaling"
  vpc_zone_identifier = ["${aws_subnet.gogo_pub1.id}", "${aws_subnet.gogo_pub2.id}"]
  launch_configuration = "${aws_launch_configuration.gogo_lconf.name}"
  min_size = 2
  max_size = 5
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  load_balancers = ["${aws_elb.gogo.name}"]
  tag {
    key = "gogo"
    value = "ec2"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "gogo_policyup" {
  name                   = "gogo_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.gogo_scalinggroup.name}"
  policy_type = "SimpleScaling"
}

resource "aws_autoscaling_policy" "gogo_policydown" {
  name                   = "gogo_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.gogo_scalinggroup.name}"
  policy_type = "SimpleScaling"
}
