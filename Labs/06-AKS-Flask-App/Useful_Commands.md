## Useful commands

```bash
# Get ingress IP
kubectl get ingress

# Watch pods
kubectl get pods --watch

# Watch HPA scaling in real time
kubectl get hpa --watch

# Check pod logs
kubectl logs <pod-name> --tail=50

# Describe ingress (debug routing issues)
kubectl describe ingress simplemetrics

# Run load test from terminal
while true; do curl -s http://<INGRESS_IP>/load > /dev/null; done

# Refresh local kubectl credentials after infrastructure deploy
az aks get-credentials --name simplemetrics-aks --resource-group simplemetrics-rg --overwrite-existing

# Check Application Gateway status
az network application-gateway show \
  --name simplemetrics-agw \
  --resource-group MC_simplemetrics-rg_simplemetrics-aks_westeurope \
  --query "{Name:name,State:operationalState}" \
  --output table

# Start Application Gateway if stopped
az network application-gateway start \
  --name simplemetrics-agw \
  --resource-group MC_simplemetrics-rg_simplemetrics-aks_westeurope
```
