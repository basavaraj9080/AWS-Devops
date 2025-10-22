**Day to Day activities**

<img width="700" height="400" alt="image" src="https://github.com/user-attachments/assets/756fbdec-da82-4461-930f-e6fb20c8b400" />

<img width="700" height="400" alt="image" src="https://github.com/user-attachments/assets/0a00e622-6e88-47b1-b482-94e08e748039" />

---------------------------------------------------------------------------------------------------------------------------------------

**Demo:**

- Create EC2 with ubuntu, 10GB
- ```sudo su –```
- ```hostname Dockerhost```
- ```bash```
- install Docker ```vi docker.sh```
  ```
  #!/bin/bash
  sudo apt-get update -y
  sudo apt-get install docker.io -y
  sudo usermod -aG docker ubuntu
  newgrp docker
  sudo chmod 660 /var/run/docker.sock
  sudo chown root:docker /var/run/docker.sock
  sudo systemctl restart docker
  ```


