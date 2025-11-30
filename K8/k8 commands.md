Below is the **most complete and interview-friendly Kubernetes command cheat sheet** you can use for daily work and preparation.
I’ve organized everything **simple → intermediate → advanced**, so you can learn fast.

---

# ✅ **Kubernetes Complete Command Cheat Sheet**

---

# 🔹 **1. Basic Commands**

### **Check cluster info**

```bash
kubectl cluster-info
kubectl get nodes
kubectl describe node <node-name>
```

### **Check API resources**

```bash
kubectl api-resources
kubectl api-versions
```

---

# 🔹 **2. Get Commands (Most Frequently Used)**

```bash
kubectl get pods
kubectl get pods -o wide
kubectl get deployments
kubectl get svc
kubectl get ns
kubectl get configmap
kubectl get secret
kubectl get pv
kubectl get pvc
kubectl get ingress
```

---

# 🔹 **3. Describe Commands**

```bash
kubectl describe pod <pod-name>
kubectl describe deployment <deployment-name>
kubectl describe svc <service-name>
kubectl describe ingress <ingress-name>
kubectl describe pvc <pvc-name>
```

---

# 🔹 **4. Create / Apply / Delete**

### **Apply manifest**

```bash
kubectl apply -f <file.yaml>
```

### **Delete resources**

```bash
kubectl delete -f <file.yaml>
kubectl delete pod <name>
kubectl delete deployment <name>
kubectl delete svc <name>
```

### **Dry run (Important for interviews!)**

```bash
kubectl apply -f app.yaml --dry-run=client
```

---

# 🔹 **5. Pod Commands**

### **Create pod**

```bash
kubectl run mypod --image=nginx
```

### **Access pod shell**

```bash
kubectl exec -it <pod-name> -- /bin/bash
```

### **Check logs**

```bash
kubectl logs <pod-name>
kubectl logs <pod-name> -f   # follow logs
```

### **Port Forward Pod**

```bash
kubectl port-forward pod/<name> 8080:80
```

---

# 🔹 **6. Deployment Commands**

### **Create deployment**

```bash
kubectl create deployment myapp --image=nginx
```

### **Scale deployment**

```bash
kubectl scale deployment myapp --replicas=5
```

### **Edit deployment**

```bash
kubectl edit deployment myapp
```

### **Check rollout status**

```bash
kubectl rollout status deployment/myapp
kubectl rollout history deployment/myapp
kubectl rollout undo deployment/myapp
```

---

# 🔹 **7. Service Commands**

### **Expose deployment**

```bash
kubectl expose deployment myapp --type=ClusterIP --port=80
kubectl expose deployment myapp --type=NodePort --port=80 --target-port=8080
kubectl expose deployment myapp --type=LoadBalancer --port=80
```

---

# 🔹 **8. ConfigMaps & Secrets**

### **Create ConfigMap**

```bash
kubectl create configmap myconfig --from-literal=env=prod
kubectl create configmap myconfig --from-file=config.json
```

### **Create Secret**

```bash
kubectl create secret generic mysecret --from-literal=password=admin123
```

### **View**

```bash
kubectl get configmap myconfig -o yaml
kubectl get secret mysecret -o yaml   # base64 encoded
```

---

# 🔹 **9. Namespace Commands**

```bash
kubectl get ns
kubectl create ns dev
kubectl delete ns dev
kubectl config set-context --current --namespace dev
```

---

# 🔹 **10. Persistent Volumes**

```bash
kubectl get pv
kubectl get pvc
kubectl describe pvc <name>
```

---

# 🔹 **11. Ingress Commands**

```bash
kubectl get ingress
kubectl describe ingress mying
```

---

# 🔹 **12. Debugging Commands**

### **See pod events**

```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```

### **Debug container without a shell**

```bash
kubectl debug -it <pod-name> --image=busybox
```

### **Show pod YAML**

```bash
kubectl get pod <pod-name> -o yaml
```

---

# 🔹 **13. Node Commands**

```bash
kubectl get nodes
kubectl cordon <node>
kubectl drain <node> --ignore-daemonsets
kubectl uncordon <node>
```

---

# 🔹 **14. Useful Shortcuts**

### **Delete pod forcefully**

```bash
kubectl delete pod <name> --force --grace-period=0
```

### **Get all resources**

```bash
kubectl get all
```

### **Switch context**

```bash
kubectl config get-contexts
kubectl config use-context <context-name>
```

---

# 🔹 **15. K9s (Bonus for Interviews)**

If asked about Kubernetes troubleshooting:

> “I also use **k9s**, a terminal UI, to quickly debug pods, logs, events, and namespaces.”

Command:

```bash
k9s
```

---

# ⭐ If You Want, I Can Also Provide:

✅ Kubernetes 50 Interview Questions
✅ Real-world EKS architecture diagram
✅ YAML templates (Deployment, Service, HPA, Ingress, ConfigMap, Secret)
✅ Day-by-day learning roadmap

Just tell me **“yes”**.
