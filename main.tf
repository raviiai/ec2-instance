provider "aws" {
  region = "us-west-2" # Adjust the region as needed
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere. Change as needed for security.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0440fa9465661a496" # Amazon Linux 2 AMI (update to the latest AMI for your region)
  instance_type = "t2.small"

  # User data to install Docker and Docker Compose
  user_data = <<-EOF
              #!/bin/bash
                yum update -y
                yum install -y docker
                service docker start
                usermod -a -G docker ec2-user
                curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                chmod +x /usr/local/bin/docker-compose
                echo "version: '3' \nservices: \n  web: \n    image: nginx" > /home/ec2-user/docker-compose.yml
                cd /home/ec2-user
                docker-compose up -d
              EOF
  security_groups = [aws_security_group.allow_ssh.name]

  tags = {
    Name = "example-instance"
  }
}

output "instance_id" {
  value = aws_instance.example.id
}

output "instance_public_ip" {
  value = aws_instance.example.public_ip
}
