provider "aws" {
  region = "us-west-2"  # Adjust the region as needed
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere. Change as needed for security.
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere. Change as needed for security.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0aff18ec83b712f05"  # Replace with Ubuntu AMI ID or appropriate AMI for your use case
  instance_type = "t2.small"
  
  # User data to install Docker, Docker Compose, pull from GitHub, and run Docker Compose
  user_data = <<-EOF
    #!/bin/bash
    # Update package list and install Docker and Git
    sudo apt-get update
    sudo apt-get install -y docker.io git curl

    # Start Docker and enable it to run on boot
    sudo systemctl start docker
    sudo systemctl enable docker

    # Add the EC2 user to the Docker group
    sudo usermod -aG docker ubuntu

    # Clone the repository
    git clone https://github.com/raviiai/docker-compose.git /home/ubuntu/docker-compose

    # Change to the directory and run docker-compose up
    cd /home/ubuntu/docker-compose
    sudo docker-compose up -d
  EOF

  security_groups = [aws_security_group.allow_ssh_http.name]

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
