# Learnings
This is where i document my learning per project in raw format for transparency and genuine showcasing of information retention when building projects.


## Decisions i made and errors i ran into

Wanted to understand how k8s cluster actually works, deployed the cluster and pushed my frontend and backend of the app with the end goal of it displaying a simple html that says cluster is working and having it live trying to fetch backend which it failed miserably since clusters DNS resolves internally only. So a simple lab just to gain better understanding about cluster or clusters itself.



## Errors and fixes

* Custom NSG from networking module blocked AKS health probes and kubectl exec, had to remove the module entirely and let AKS manage its own networking. Custom NSGs on AKS subnets need explicit rules for AKS internal traffic.

* Kubelet identity mismatch after destroy/recreate every time cluster is destroyed AKS creates new managed identity with new object ID. Role assignment for ACR pull needs to be updated each time. Terraform apply fixes it but timing can be off.

* Frontend image contained backend Flask app — wrong image pushed to ACR. Always verify with `kubectl logs deployment/<name>` after deploy.

* Frontend JS fetch to `backend-service:5000` fails from browser  Kubernetes internal DNS only resolves inside the cluster. Browser is outside the cluster so it cant resolve service names.

## What actually worked

* `kubectl exec` into frontend pod calling `http://backend-service:5000/health` returned correct JSON response, proves internal DNS and service routing working correctly.

## Sources

* https://learn.microsoft.com/en-us/azure/aks/concepts-network
* https://learn.microsoft.com/en-us/azure/aks/cluster-container-registry-integration
* https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
* https://kubernetes.io/docs/reference/kubectl/cheatsheet/
