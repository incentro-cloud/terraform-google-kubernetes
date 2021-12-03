# Kubernetes module

![Cloud Build status](https://badger-tcppdqobjq-ew.a.run.app/build/status?project=examples-331911&id=55a9baae-ec58-4762-afce-b2274da03f5f "Cloud Build status")

Module for creating a Kubernetes cluster and the node pools.

This module supports creating:

- Kubernetes cluster
- Node pools

## Example usage

```hcl
module "kubernetes" {
  source  = "incentro-cloud/kubernetes/google"
  version = "~> 0.1"

  project_id = var.project_id
}
```
