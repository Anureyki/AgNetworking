# Kubernetes Study (CKA / CKAD)

## Why Kubernetes for AgTech?
Kubernetes orchestrates containers. In an AI‑powered grow system, containers run:
- Sensor data ingestion
- Model inference
- Automation triggers
- Dashboard frontends

K8s lets you scale from one Raspberry Pi to a cluster of cloud instances without rewriting your app.

## Certifications
- **CKA (Certified Kubernetes Administrator)** — Cluster operations
- **CKAD (Certified Kubernetes Application Developer)** — Deploying apps on K8s

## Study Resources
- [Official CKA curriculum](https://www.cncf.io/certification/cka/)
- [Killer.sh](https://killer.sh) (practice exams)
- [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)

## Lab Projects
- [ ] Deploy a local cluster with `kind` or `minikube`
- [ ] Run a simple sensor simulator as a pod
- [ ] Scale the simulator to 3 replicas
- [ ] Store sensor readings in a persistent volume
- [ ] Deploy the DLI model as a service

## Progress
- [ ] CKA certified
- [ ] CKAD certified

## Commands to Remember
```bash
kubectl get nodes
kubectl get pods
kubectl logs <pod-name>
kubectl apply -f manifest.yaml
kubectl scale deployment sensor --replicas=3
```

---
*Last updated: May 2026*
