resource "aws_security_group" "ec2_sg" {

  name = "minikube-sg"

  # SSH
  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  # HTTP cho ALB
  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  # NodePort của ứng dụng
  ingress {

    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  # Kubernetes API Server
  ingress {

    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}