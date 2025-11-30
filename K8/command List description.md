Here is the **clean tabular format** of all Kubernetes commands with explanations — perfect for interview prep and quick revision.

---

# ✅ **Kubernetes Commands – Complete Table Format**

| Category                    | Command                                                              | Explanation                                              |
| --------------------------- | -------------------------------------------------------------------- | -------------------------------------------------------- |
| **Cluster Info**            | `kubectl cluster-info`                                               | Shows Kubernetes master & service endpoints.             |
|                             | `kubectl get nodes`                                                  | Lists all nodes in the cluster.                          |
|                             | `kubectl describe node <node>`                                       | Detailed info about node: CPU, memory, conditions, pods. |
| **API Resources**           | `kubectl api-resources`                                              | Lists all resource types supported by the API.           |
|                             | `kubectl api-versions`                                               | Shows available API versions.                            |
| **Get Commands**            | `kubectl get pods`                                                   | Lists all pods in current namespace.                     |
|                             | `kubectl get pods -o wide`                                           | Shows pods with node, IP, image details.                 |
|                             | `kubectl get deployments`                                            | Lists deployments.                                       |
|                             | `kubectl get svc`                                                    | Shows services (ClusterIP, NodePort, LB).                |
|                             | `kubectl get ns`                                                     | Lists namespaces.                                        |
|                             | `kubectl get configmap`                                              | Lists ConfigMaps.                                        |
|                             | `kubectl get secret`                                                 | Lists Secrets.                                           |
|                             | `kubectl get pv`                                                     | Shows PersistentVolumes.                                 |
|                             | `kubectl get pvc`                                                    | Shows PersistentVolumeClaims.                            |
|                             | `kubectl get ingress`                                                | Displays ingress rules.                                  |
| **Describe Commands**       | `kubectl describe pod <pod>`                                         | Shows events, conditions, containers.                    |
|                             | `kubectl describe deployment <deploy>`                               | Details about deployment.                                |
|                             | `kubectl describe svc <service>`                                     | Shows service type, ports, endpoints.                    |
|                             | `kubectl describe ingress <ing>`                                     | Shows ingress rules and backend services.                |
|                             | `kubectl describe pvc <pvc>`                                         | PVC details and bound PV.                                |
| **Create / Apply / Delete** | `kubectl apply -f file.yaml`                                         | Creates/updates resources from YAML.                     |
|                             | `kubectl apply --dry-run=client -f file.yaml`                        | Validates YAML without creating anything.                |
|                             | `kubectl delete -f file.yaml`                                        | Deletes resources defined in file.                       |
|                             | `kubectl delete pod <name>`                                          | Deletes a specific pod.                                  |
|                             | `kubectl delete deployment <name>`                                   | Deletes a deployment.                                    |
| **Pod Commands**            | `kubectl run mypod --image=nginx`                                    | Creates a pod using nginx image.                         |
|                             | `kubectl exec -it <pod> -- /bin/bash`                                | Opens shell inside container.                            |
|                             | `kubectl logs <pod>`                                                 | Shows pod logs.                                          |
|                             | `kubectl logs -f <pod>`                                              | Follows logs in real-time.                               |
|                             | `kubectl port-forward pod/<pod> 8080:80`                             | Maps local port to pod port.                             |
| **Deployment**              | `kubectl create deployment myapp --image=nginx`                      | Creates deployment.                                      |
|                             | `kubectl scale deployment myapp --replicas=5`                        | Scales deployment to given replicas.                     |
|                             | `kubectl edit deployment myapp`                                      | Opens deployment in editor.                              |
|                             | `kubectl rollout status deployment/myapp`                            | Shows rollout status.                                    |
|                             | `kubectl rollout history deployment/myapp`                           | Shows previous versions.                                 |
|                             | `kubectl rollout undo deployment/myapp`                              | Rolls back deployment version.                           |
| **Services**                | `kubectl expose deployment myapp --type=ClusterIP --port=80`         | Exposes deployment internally.                           |
|                             | `kubectl expose deployment myapp --type=NodePort --port=80`          | Exposes deployment outside nodes.                        |
|                             | `kubectl expose deployment myapp --type=LoadBalancer --port=80`      | Creates external LoadBalancer.                           |
| **ConfigMaps & Secrets**    | `kubectl create configmap myconfig --from-literal=env=prod`          | Creates ConfigMap from literal.                          |
|                             | `kubectl create configmap myconfig --from-file=config.json`          | Creates ConfigMap from file.                             |
|                             | `kubectl create secret generic mysecret --from-literal=password=123` | Creates Secret.                                          |
|                             | `kubectl get configmap -o yaml`                                      | View ConfigMap YAML.                                     |
|                             | `kubectl get secret -o yaml`                                         | View Secret YAML (base64 encoded).                       |
| **Namespaces**              | `kubectl get ns`                                                     | Lists namespaces.                                        |
|                             | `kubectl create ns dev`                                              | Creates a namespace.                                     |
|                             | `kubectl delete ns dev`                                              | Deletes a namespace.                                     |
|                             | `kubectl config set-context --current --namespace dev`               | Switches default namespace.                              |
| **Storage (PV/PVC)**        | `kubectl get pv`                                                     | Lists PersistentVolumes.                                 |
|                             | `kubectl get pvc`                                                    | Lists PersistentVolumeClaims.                            |
|                             | `kubectl describe pvc <name>`                                        | Shows PVC details.                                       |
| **Ingress**                 | `kubectl get ingress`                                                | Lists ingress rules.                                     |
|                             | `kubectl describe ingress mying`                                     | Shows detailed ingress routing.                          |
| **Debugging**               | `kubectl get events --sort-by=.metadata.creationTimestamp`           | Shows cluster events.                                    |
|                             | `kubectl debug -it <pod> --image=busybox`                            | Attach debug container.                                  |
|                             | `kubectl get pod <pod> -o yaml`                                      | Shows full YAML of resource.                             |
| **Node Maintenance**        | `kubectl cordon <node>`                                              | Marks node unschedulable.                                |
|                             | `kubectl drain <node> --ignore-daemonsets`                           | Moves pods off node.                                     |
|                             | `kubectl uncordon <node>`                                            | Makes node schedulable again.                            |
| **Shortcuts**               | `kubectl delete pod <name> --force --grace-period=0`                 | Force delete pod.                                        |
|                             | `kubectl get all`                                                    | Lists all resources in namespace.                        |
|                             | `kubectl config get-contexts`                                        | Shows kubeconfig contexts.                               |
|                             | `kubectl config use-context <context>`                               | Switches Kubernetes cluster.                             |

---

If you want, I can turn this into a **PDF cheat sheet** you can download.
