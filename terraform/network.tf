#create vpc
resource "aws_vpc" "dagster_vpc" {
  cidr_block = "10.0.0.0/16"  # Change CIDR block if needed
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "dagster-vpc"
  }
}

resource "aws_internet_gateway" "dagster_igw" {
  vpc_id = aws_vpc.dagster_vpc.id

  tags = {
    Name = "dagster-igw"
  }
}

# Create a subnet
resource "aws_subnet" "dagster_subnet" {
  vpc_id                  = aws_vpc.dagster_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dagster-subnet"
  }
}

resource "aws_subnet" "dagster_subnet_2" {
  vpc_id                  = aws_vpc.dagster_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "dagster-subnet"
  }
}

# Create a Route Table
resource "aws_route_table" "dagster_rt" {
  vpc_id = aws_vpc.dagster_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dagster_igw.id
  }

  tags = {
    Name = "dagster-rt"
  }
}

# Associate Route Table with the Subnet
resource "aws_route_table_association" "dagster_rta" {
  subnet_id      = aws_subnet.dagster_subnet.id
  route_table_id = aws_route_table.dagster_rt.id
}

resource "aws_route_table_association" "dagster_rta_2" {
  subnet_id      = aws_subnet.dagster_subnet_2.id
  route_table_id = aws_route_table.dagster_rt.id
}

# Create a Security Group
resource "aws_security_group" "dagster_sg" {
  vpc_id = aws_vpc.dagster_vpc.id

  # Allow ingress traffic on port 5432 for Dagster Webserver
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ingress traffic on port 5432 for PostgreSQL
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dagster-sg"
  }
}