Below is a **clean, corrected, and logically ordered step-by-step procedure** to establish **High Availability (HA)** and **Fault Tolerance (FT)** on AWS using **Route 53, ALB, Auto Scaling, CloudWatch, and ACM**, based on your provided steps.

I’ve removed duplication, fixed the order, and clarified *why* each step is required.

---

## Phase 1: Networking & DNS Foundation

### 1. Create Route 53 Hosted Zone

1. Go to **Route 53 → Hosted Zones**
2. Create a **Public Hosted Zone** for your domain (e.g., `example.com`)
3. Note the **Name Servers (NS)** provided by Route 53
4. Log in to your **domain registrar**
5. Replace existing name servers with the Route 53 NS records
6. Verify using:

```bash
nslookup example.com
```

✅ Enables DNS-level HA by routing traffic to AWS infrastructure

---

### 2. Create VPC (Highly Available)

1. Create a **VPC** with:

   * At least **2 Availability Zones**
   * **Public Subnets** (for ALB & NAT Gateway)
   * **Private Subnets** (for EC2 instances)
2. Create **NAT Gateway** in each AZ (recommended)
3. Update **private route tables** to route internet traffic via NAT
4. Ensure **S3 VPC Endpoint is removed** (as requested)

✅ Enables HA across AZs and private EC2 internet access

---

## Phase 2: Security Configuration

### 3. Create Security Groups

Create **two security groups**:

#### SG-1: Load Balancer SG

* Inbound:

  * HTTP 80 (from 0.0.0.0/0)
  * HTTPS 443 (from 0.0.0.0/0)
* Outbound: Allow all

#### SG-2: EC2 SG

* Inbound:

  * HTTP 80 (from Load Balancer SG only)
  * HTTPS 443 (from Load Balancer SG only)
  * SSH (optional, restricted to your IP)
* Outbound: Allow all

✅ Restricts traffic flow and improves security posture

---

## Phase 3: Compute & Image Preparation

### 4. Launch Initial EC2 Instance

1. Launch EC2 in **private subnet**
2. Attach **EC2 Security Group**
3. Install application/web server
4. Verify application locally

---

### 5. Take AMI Backup

1. Stop the EC2 instance
2. Create **AMI** from this instance
3. Wait until AMI status is **Available**

---

### 6. Create Launch Template (LT)

1. Go to **EC2 → Launch Templates**
2. Create LT using:

   * AMI created above
   * Instance type
   * EC2 security group
   * IAM role (for SSM access)
3. Save the Launch Template

✅ Launch Template is the base for fault-tolerant instance creation

---

## Phase 4: Load Balancer & Target Group

### 7. Create Target Group

1. Create **Target Group**

   * Type: Instance
   * Protocol: HTTP
   * Port: 80
2. Do **not register instances manually**

---

### 8. Create Application Load Balancer (ALB)

1. Create ALB:

   * Internet-facing
   * Select **public subnets in 2 AZs**
2. Attach **Load Balancer SG**
3. Create listener:

   * HTTP :80 → Forward to Target Group

---

### 9. Stop Initial EC2 Instance

* The manually created EC2 is no longer needed
* Auto Scaling will create instances dynamically

---

### 10. Map Route 53 to Load Balancer

1. Go to Route 53 Hosted Zone
2. Create **A Record**
3. Enable **Alias**
4. Select your **Load Balancer**
5. Save

Test:

```bash
nslookup example.com
```

---

## Phase 5: Auto Scaling (HA + FT Core)

### 11. Create Auto Scaling Group (ASG)

1. Use **Launch Template**
2. Select **private subnets in multiple AZs**
3. Attach **Target Group**
4. Set:

   * Min: 1
   * Desired: 1
   * Max: 3

✅ Provides automatic instance replacement (Fault Tolerance)

---

### 12. Validate Auto Scaling

* New EC2 instance launches automatically
* Instance appears in Target Group
* Check:

  * **SSM connectivity**
  * **Security group inbound rules**

Test ALB:

```text
http://<ALB-DNS-Name>
```

---

### 13. Fault Tolerance Test

1. Manually terminate EC2 instance
2. Auto Scaling launches a new instance
3. Verify in:

   * EC2
   * Target Group
   * Auto Scaling Activity History

---

## Phase 6: Auto Scaling Policies (Elasticity)

### 14. Create CloudWatch Scale-Out Alarm

1. Metric: **CPUUtilization**
2. Threshold: **≥ 70%**
3. Period: 5 minutes
4. Action:

   * Attach to ASG
   * Add **1 instance**

*(Alarm does not need notifications)*

---

### 15. Create CloudWatch Scale-In Alarm

1. Metric: **CPUUtilization**
2. Threshold: **≤ 50%**
3. Period: 5 minutes
4. Action:

   * Remove **1 instance**

---

### 16. Stress Test

1. Connect to EC2 via SSM
2. Run CPU stress command
3. Observe:

   * CPU > 70% → new instance launches
   * Instances added to Target Group
4. Remove stress
5. CPU < 50% → instance terminated
6. Verify ASG Activity History

---

## Phase 7: HTTPS & Security

### 17. Create ACM Certificate

1. Go to **AWS Certificate Manager**
2. Request public certificate
3. Use **DNS validation**
4. Wait for status → **Issued**

---

### 18. Enable HTTPS on Load Balancer

1. Go to ALB → Listeners
2. Add listener:

   * HTTPS :443
3. Attach ACM certificate
4. Forward traffic to Target Group
5. (Optional) Redirect HTTP → HTTPS

---

### 19. Final Validation

* Test:

```text
https://example.com
```

* Remove CPU stress
* Scale-in alarm triggers
* ASG reduces instance count

---

## Final Outcome

✅ **High Availability**

* Multi-AZ ALB
* Multi-AZ Auto Scaling

✅ **Fault Tolerance**

* Automatic instance replacement
* Health-based recovery

✅ **Scalability**

* CPU-based scale-out / scale-in

✅ **Security**

* Private EC2
* HTTPS via ACM
* Restricted security groups

---

If you want, I can:

* Convert this into **diagram architecture**
* Create **Terraform / CloudFormation**
* Simplify it for **interview explanation**
* Convert to **step-by-step SOP document**



Below are **two deliverables** based on your request:

1. **Architecture Diagram (visual + logical)**
2. **Infrastructure as Code**

   * **Terraform (recommended & cleaner)**
   * **CloudFormation (YAML skeleton)**

---

# 1️⃣ Architecture Diagram (HA + FT)

## Logical Architecture Diagram (Text-Based)

```
                     ┌──────────────────────────┐
                     │        Route 53           │
                     │   (Public Hosted Zone)    │
                     └───────────┬──────────────┘
                                 │  DNS (A Alias)
                                 ▼
                     ┌──────────────────────────┐
                     │   Application Load        │
                     │       Balancer (ALB)      │
                     │  - HTTP :80               │
                     │  - HTTPS :443 (ACM)       │
                     └───────────┬──────────────┘
                         │                   │
            AZ-1          │                   │        AZ-2
      ┌──────────────────▼───┐         ┌─────▼──────────────────┐
      │   Target Group        │         │    Target Group         │
      │   (EC2 Instances)     │         │    (EC2 Instances)      │
      └──────────┬───────────┘         └──────────┬─────────────┘
                 │                                  │
        ┌────────▼─────────┐               ┌──────▼──────────┐
        │  EC2 Instance     │               │  EC2 Instance   │
        │  (Private Subnet) │               │  (Private Subnet│
        │  Auto Scaling     │               │  Auto Scaling   │
        └────────┬─────────┘               └────────┬────────┘
                 │                                  │
                 └───────────┬──────────────────────┘
                             ▼
                    ┌────────────────────┐
                    │ Auto Scaling Group │
                    │  Min:1 Max:3       │
                    │  CPU Policies      │
                    └────────────────────┘

        ┌──────────────────────────┐
        │     NAT Gateway (AZ-1)   │
        └────────────┬────────────┘
                     │
        ┌────────────▼────────────┐
        │     NAT Gateway (AZ-2)   │
        └─────────────────────────┘
```

---

## HA & FT Coverage

| Layer      | Feature                      |
| ---------- | ---------------------------- |
| DNS        | Route53 health-based routing |
| Network    | Multi-AZ VPC                 |
| Compute    | Auto Scaling Group           |
| Traffic    | ALB across AZs               |
| Security   | Private EC2 + HTTPS          |
| Resilience | Auto recovery & scaling      |

---

# 2️⃣ Terraform Implementation (Recommended)

Below is a **production-aligned Terraform skeleton**.
You can modularize later if needed.

---

## 📁 Folder Structure

```
terraform/
│── main.tf
│── vpc.tf
│── alb.tf
│── asg.tf
│── route53.tf
│── variables.tf
│── outputs.tf
```

---

## main.tf

```hcl
provider "aws" {
  region = "us-east-1"
}
```

---

## vpc.tf

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "ha-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
}
```

---

## alb.tf

```hcl
resource "aws_security_group" "alb_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name               = "ha-alb"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}
```

---

## asg.tf

```hcl
resource "aws_launch_template" "lt" {
  name_prefix   = "ha-lt"
  image_id      = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
}

resource "aws_autoscaling_group" "asg" {
  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  vpc_zone_identifier = module.vpc.private_subnets
  target_group_arns  = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
}
```

---

## route53.tf

```hcl
resource "aws_route53_record" "alb_record" {
  zone_id = "ZXXXXXXXX"
  name    = "example.com"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
```

---

# 3️⃣ CloudFormation (YAML Skeleton)

```yaml
Resources:
  LoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Type: application
      Scheme: internet-facing
      Subnets:
        - subnet-1
        - subnet-2

  TargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Port: 80
      Protocol: HTTP
      VpcId: vpc-id

  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      MinSize: 1
      MaxSize: 3
      DesiredCapacity: 1
      TargetGroupARNs:
        - !Ref TargetGroup
```

---

# 4️⃣ What I Can Do Next for You

✅ Draw **AWS official icon diagram (PNG / Draw.io)**
✅ Convert Terraform into **modules**
✅ Add **CloudWatch alarms in Terraform**
✅ Provide **interview explanation (HA vs FT)**
✅ Convert into **SOP / Runbook**

Just tell me 👍
