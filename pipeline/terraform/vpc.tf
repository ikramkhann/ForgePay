# AI Attribution Block: AI-assisted Terraform VPC and network topology definition.
# Defines multi-AZ VPC, public subnets, private subnets for EKS worker nodes,
# isolated database subnets, NAT Gateways, Internet Gateway, and Route Tables.

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                        = "${var.project_name}-${var.environment}-vpc"
    "kubernetes.io/cluster/${var.project_name}" = "shared"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# --- Public Subnets (Ingress / ALBs / NAT Gateways) ---

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.project_name}-${var.environment}-public-${var.availability_zones[count.index]}"
    "kubernetes.io/cluster/${var.project_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

# --- Private Subnets (EKS Worker Nodes & Workloads) ---

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                        = "${var.project_name}-${var.environment}-private-${var.availability_zones[count.index]}"
    "kubernetes.io/cluster/${var.project_name}" = "owned"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

# --- Database Subnets (PostgreSQL 16 Multi-AZ, Isolated) ---

resource "aws_subnet" "database" {
  count             = length(var.database_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-database-${var.availability_zones[count.index]}"
  }
}

resource "aws_db_subnet_group" "rds" {
  name        = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids  = aws_subnet.database[*].id
  description = "Isolated database subnet group for ForgePay PostgreSQL 16"

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

# --- Elastic IPs & Multi-AZ NAT Gateways ---

resource "aws_eip" "nat" {
  count  = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-eip-${var.availability_zones[count.index]}"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-${var.availability_zones[count.index]}"
  }

  depends_on = [aws_internet_gateway.igw]
}

# --- Route Tables & Associations ---

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  # Isolated - no route to internet/NAT gateway per RBI security standards

  tags = {
    Name = "${var.project_name}-${var.environment}-database-rt"
  }
}

resource "aws_route_table_association" "database" {
  count          = length(aws_subnet.database)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
