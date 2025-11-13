
Perfect 👌 — since you’re preparing for **AWS EC2 interviews** at around **5 years of experience**, you’ll be expected to answer **conceptual, practical, and scenario-based** questions.

Below is a **complete, tiered list** (Basic → Intermediate → Advanced → Real-time Scenarios), **with explanations** and **examples** where applicable.

---

# ☁️ **Amazon EC2 Interview Questions (for 5 years experience)**

---

## 🟢 **Basic-Level Questions**

### 1. What is Amazon EC2?

**Answer:**
Amazon **EC2 (Elastic Compute Cloud)** is a **virtual server (compute service)** in AWS that lets you run applications in the cloud. It provides resizable compute capacity — you can increase or decrease instances as needed.
**Category:** *IaaS (Infrastructure as a Service)*

**Example use:** Hosting web apps, backend APIs, databases, or processing workloads.

---

### 2. What are EC2 instance types?

**Answer:**
EC2 instances are grouped by **use case**:

| Family        | Use Case                                             |
| ------------- | ---------------------------------------------------- |
| **t, a**      | General purpose (e.g., t3.micro for small workloads) |
| **c**         | Compute optimized (e.g., c7g)                        |
| **m**         | Balanced compute & memory                            |
| **r, x**      | Memory optimized (databases, caching)                |
| **p, g, inf** | GPU & ML workloads                                   |
| **i, d, h**   | Storage optimized                                    |
| **f**         | FPGA workloads                                       |

---

### 3. What is an AMI (Amazon Machine Image)?

**Answer:**
An **AMI** is a template that defines:

* OS (e.g., Amazon Linux, Ubuntu)
* Pre-installed software
* Launch permissions
* EBS snapshot(s)

**Example:** You create your own AMI from a configured instance to launch identical copies.

---

### 4. What are EC2 instance states?

**Answer:**

* **Pending** → Instance is starting
* **Running** → Active
* **Stopping / Stopped** → Shut down but still billed for storage
* **Shutting-down / Terminated** → Permanently deleted

---

### 5. What is a key pair and why is it used in EC2?

**Answer:**
A **key pair (public + private key)** is used for **secure SSH authentication**.

* AWS stores the **public key** in EC2.
* You download the **private key (.pem)** and use it to connect via SSH.

**Example:**

```bash
ssh -i my-key.pem ec2-user@<public-ip>
```

---

### 6. What is the difference between On-Demand, Reserved, and Spot Instances?

| Type             | Description                           | Cost Benefit                                    |
| ---------------- | ------------------------------------- | ----------------------------------------------- |
| **On-Demand**    | Pay per second/hour                   | Flexible but most expensive                     |
| **Reserved**     | Commit 1–3 years                      | Up to 75% cheaper                               |
| **Spot**         | Use unused capacity                   | Up to 90% cheaper but can be terminated anytime |
| **Savings Plan** | Flexible commitment for compute usage | Cheaper and flexible                            |

---

### 7. What is Elastic IP?

**Answer:**
A **static public IPv4 address** that you can remap to another instance.
Useful when you need a **fixed public IP** (like for DNS or production services).

---

### 8. What is the difference between EC2 and Lambda?

| Feature    | EC2                       | Lambda                   |
| ---------- | ------------------------- | ------------------------ |
| Management | You manage OS and scaling | Fully managed            |
| Billing    | Pay for running time      | Pay per execution        |
| Use case   | Long-running servers      | Event-driven micro tasks |

---

### 9. What is EBS (Elastic Block Store)?

**Answer:**
EBS provides **persistent block storage** volumes for EC2.

* Survive instance stop/start.
* You can attach/detach to any EC2 instance in the same AZ.
* Types: gp3 (SSD general), io2 (high IOPS), st1/sc1 (HDD).

---

### 10. Difference between EBS and Instance Store?

| Feature     | EBS                      | Instance Store         |
| ----------- | ------------------------ | ---------------------- |
| Persistence | Data persists after stop | Lost on stop/terminate |
| Backup      | Can take snapshots       | No backups             |
| Use case    | Databases, apps          | Temporary cache/swap   |

---

## 🟡 **Intermediate-Level Questions**

### 11. What is user data in EC2?

**Answer:**
A script or configuration that runs **at instance launch** (first boot).
Commonly used for auto-installing software or configurations.

**Example:**

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
echo "Hello from EC2" > /var/www/html/index.html
```

---

### 12. What is EC2 Auto Scaling?

**Answer:**
Automatically adjusts the number of instances based on load (CPU, requests, etc.).
**Components:**

* Launch Template
* Auto Scaling Group (ASG)
* Scaling Policies (Target, Step, Scheduled)

**Example use:** Keep CPU utilization between 40–60%.

---

### 13. What are Security Groups and NACLs?

| Feature      | Security Group          | NACL                  |
| ------------ | ----------------------- | --------------------- |
| Type         | Instance-level firewall | Subnet-level firewall |
| Stateful     | ✅ Yes                   | ❌ No                  |
| Direction    | Inbound/Outbound        | Both                  |
| Rule control | Allow only              | Allow/Deny            |

---

### 14. Difference between Public, Private, and Elastic IP?

| Type           | Usage                                |
| -------------- | ------------------------------------ |
| **Public IP**  | Auto-assigned, changes on stop/start |
| **Private IP** | Internal communication               |
| **Elastic IP** | Static, can be reassigned            |

---

### 15. What is Placement Group?

**Answer:**
Controls how EC2 instances are placed on hardware:

* **Cluster:** Low-latency within a single AZ.
* **Spread:** Spread across hardware to reduce failure impact.
* **Partition:** Logical partitions (e.g., Hadoop clusters).

---

### 16. What is Elastic Load Balancer (ELB)?

**Answer:**
Distributes incoming traffic across multiple EC2 instances.
Types:

* **ALB (Application)** – HTTP/HTTPS (Layer 7)
* **NLB (Network)** – TCP/UDP (Layer 4)
* **GLB (Gateway)** – IP-based routing

**Example use:** Load balance web traffic between multiple EC2 instances.

---

### 17. What is CloudWatch in relation to EC2?

**Answer:**
Monitors instance metrics (CPU, disk, network).
Can trigger alarms or auto-scaling policies.

**Example:**
If CPU > 80% for 5 minutes → add a new instance.

---

### 18. What are EC2 Instance Metadata and IAM Roles?

**Answer:**

* **Instance Metadata:** Access instance info from inside EC2 at
  `http://169.254.169.254/latest/meta-data/`
* **IAM Role:** Provides **temporary credentials** for EC2 without storing AWS keys locally.

**Example:** Attach a role that allows EC2 to upload to S3.

---

### 19. What is an EBS snapshot?

**Answer:**
A **point-in-time backup** of an EBS volume stored in S3.
You can restore snapshots to create new volumes or AMIs.

---

### 20. What is EC2 Instance Store-backed AMI vs EBS-backed AMI?

| Type                      | Root Volume    | Persistence               |
| ------------------------- | -------------- | ------------------------- |
| **EBS-backed**            | EBS volume     | Persists after stop/start |
| **Instance-store-backed** | Temporary disk | Lost on stop              |

---

## 🔵 **Advanced / Expert-Level Questions**

### 21. What happens when you stop and start an EC2 instance?

* The instance ID stays the same.
* The public IP changes (unless Elastic IP).
* The private IP remains the same.
* Data on EBS persists.
* Data on instance store is lost.

---

### 22. How do you troubleshoot EC2 performance issues?

Steps:

1. Check **CloudWatch metrics** (CPU, Network, Disk IO).
2. Verify **security groups and NACLs** for connectivity.
3. Check **system logs** and **EC2 status checks** (system reachability, instance reachability).
4. Resize instance (vertical scaling).
5. Use **Enhanced Networking (ENA)** and **EBS-optimized instances** for performance.

---

### 23. How do you ensure EC2 high availability?

* Launch instances in **multiple AZs**.
* Use **Load Balancer** for failover.
* Use **Auto Scaling Group** for scaling and replacement.
* Store data on **EBS** or external services (RDS, S3).

---

### 24. What is the difference between horizontal and vertical scaling?

| Scaling Type   | Description                            | Example   |
| -------------- | -------------------------------------- | --------- |
| **Vertical**   | Increase instance size (e.g., t3 → m5) | Scale up  |
| **Horizontal** | Add more instances via ASG             | Scale out |

---

### 25. What is EC2 Hibernate?

**Answer:**
Saves instance RAM state to the EBS root volume when you stop the instance, so it resumes faster. Useful for applications with long initialization times.

---

### 26. What is EC2 Fleet?

**Answer:**
A single API to launch instances across **different types, purchase options (on-demand, spot, reserved)**, and regions for cost optimization.

---

### 27. How does EC2 pricing work?

**Answer:**
You are billed for:

* Instance uptime (per second/hour)
* EBS volumes (per GB-month)
* Data transfer (in/out)
* Elastic IP (if unused)
* Snapshots (per GB stored)

---

### 28. What are Dedicated Hosts and Dedicated Instances?

| Type                   | Description                                                             |
| ---------------------- | ----------------------------------------------------------------------- |
| **Dedicated Instance** | Runs on dedicated hardware for your account                             |
| **Dedicated Host**     | Physical server reserved for you; required for certain licensing (BYOL) |

---

### 29. What are EC2 Launch Templates and Launch Configurations?

**Answer:**
Templates used by Auto Scaling Groups to launch instances.
**Launch Templates** are newer, supporting multiple versions and advanced options like mixed instance policies and Spot.

---

### 30. What is Elastic Network Interface (ENI)?

**Answer:**
A **virtual network card** attached to EC2 instances.

* Supports multiple ENIs per instance
* Can attach/detach dynamically
* Useful for high-availability or multi-network setups

---

## ⚙️ **Real-Time Scenario Questions (Common in Interviews)**

### 1️⃣ Scenario: Your EC2 instance is not accessible via SSH. What do you do?

**Troubleshooting steps:**

1. Check **Security Group** inbound rule allows port 22.
2. Verify **NACL** allows inbound/outbound traffic.
3. Check **key pair** permissions (`chmod 400 my-key.pem`).
4. Use **EC2 serial console** or **Session Manager** to debug internal issues.
5. Verify instance’s **public IP / Elastic IP**.
6. Check **route table** of the subnet (proper internet gateway).

---

### 2️⃣ Scenario: EC2 instance is running slow — what steps do you take?

1. Check **CPU/Memory** via CloudWatch.
2. Check **disk I/O** or **network traffic**.
3. Ensure instance type fits workload (resize if needed).
4. Enable **EBS-optimized** performance.
5. Use **CloudWatch alarms** to automate scaling.

---

### 3️⃣ Scenario: Your EC2 was terminated unexpectedly — what could be the causes?

* Spot instance reclaimed.
* ASG terminated it (due to health check failure).
* Billing issue / AWS policy.
* Root EBS volume deleted with instance.
* Manual termination via user or script.
  **Solution:** Use **termination protection** and enable **CloudTrail** to track actions.

---

### 4️⃣ Scenario: How would you set up a highly available web application on EC2?

**Architecture:**

1. Launch EC2 instances in multiple **AZs**.
2. Put them behind an **Application Load Balancer (ALB)**.
3. Use **Auto Scaling Group** for scaling.
4. Store static content in **S3 / CloudFront**.
5. Store DB in **RDS (Multi-AZ)**.
6. Use **Route 53** for DNS with health checks.

---

### 5️⃣ Scenario: How to migrate an on-premises server to EC2?

**Options:**

* **AWS Server Migration Service (SMS)**
* **VM Import/Export** (convert VMs into AMIs)
* **AWS Application Migration Service (MGN)** (recommended modern tool)

---

### 6️⃣ Scenario: Your EC2 instance storage is full — how do you fix it?

* Check disk usage (`df -h`).
* Clean logs/temp files.
* Increase EBS volume size → modify via console → `growpart` + `resize2fs` inside instance.
* Detach volume and attach to another instance for repair.

---

### 7️⃣ Scenario: How to reduce EC2 costs?

* Use **Auto Scaling Groups** and **Spot instances**.
* Use **Reserved Instances** or **Savings Plans** for predictable workloads.
* Turn off dev/test instances outside business hours.
* Use **AWS Cost Explorer** and **Compute Optimizer**.
* Migrate static content to **S3**.

---

### 8️⃣ Scenario: How do you move EC2 to another region?

* Create an **AMI** → copy AMI to target region → launch instance.
  or
* Create **EBS snapshot** → copy snapshot → create volume in target region → launch instance.

---

### 9️⃣ Scenario: How to secure EC2 in production?

* Apply **least privilege IAM roles**.
* Disable password login → use SSH key only.
* Enable **OS patching** regularly.
* Restrict **ports** using SGs and NACLs.
* Encrypt **EBS volumes** and **snapshots**.
* Enable **AWS Inspector / GuardDuty**.

---

### 🔟 Scenario: How do you automate EC2 provisioning?

* Use **CloudFormation**, **Terraform**, or **Ansible** for IaC (Infrastructure as Code).
* Define VPC, SG, EC2, IAM roles in code for reproducibility.

---

## 🧠 Bonus: Commands and Tips

### SSH into EC2

```bash
ssh -i my-key.pem ec2-user@<public-ip>
```

### Stop/Start EC2

```bash
aws ec2 stop-instances --instance-ids i-123456789
aws ec2 start-instances --instance-ids i-123456789
```

### Create AMI

```bash
aws ec2 create-image --instance-id i-123456789 --name "myAMI"
```

### Describe instances

```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"
```

---

Would you like me to now give you a **detailed Q&A version** (like we did for S3 — 40+ EC2 interview questions **with answers and examples**) that you can **download as a study PDF** or practice flashcards?
