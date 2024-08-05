provider "aws" {
  region = "us-west-2" # Adjust the region as needed
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere. Change as needed for security.
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere. Change as needed for security.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0aff18ec83b712f05" # Amazon Linux 2 AMI (update to the latest AMI for your region)
  instance_type = "t2.small"

  # User data to install Docker, Docker Compose, pull from GitHub, and run Docker Compose
 user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt update -y
              sudo apt install docker-ce docker-ce-cli containerd.io -y
              sudo systemctl start docker
              sudo systemctl enable docker
              git clone https://github.com/raviiai/docker-compose.git
              cd docker-compose
              sudo docker compose up
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
