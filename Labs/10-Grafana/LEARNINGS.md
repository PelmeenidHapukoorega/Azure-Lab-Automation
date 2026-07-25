# Learnings

This is where i document my learning per project in raw format for transparency and genuine showcasing of information retention when building projects.

## Decisions i made and errors i ran into

The goal with this project was to run grafana in 3 different ways:

1. In a container on a small VM.
2. Azure Managed Grafana, MS fully managed service which is native for AZ AD integration and has no infrastructure to manage.
3. Deploying grafana as a pod alongside Lab 6 cluster.

But then i decided to cancel option 1 because of extra costs when the goal is to simply just ran grafana in a docker container when i already had AKS lab that i could reuse for this purpose.

Reused code from previous 2 labs for main tf and variables and added data source to main tf to reuse log analytics workspace from lab 6.

Decided to use system assigned for grafana for lifecycle management and there was no need to share the identity across multiple resources ergo no reason for user assigned.

Although for flexibility the user assigned would be a better option because then i could pre configure specific role/roles for it for granularity whereas with system assigned it will be deployed alongside grafana but cant be pre assigned any roles since the identity wouldnt exist without grafana first.

And system assigned works best for cleanup as well.

## Commands used

## Sources

