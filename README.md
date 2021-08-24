# personal-infra

My personal infrastructure.
Currently I use a self-hosted K3s instance on a single aarch64 VM.

All resources are stored in this repository.
Since YAML is a nightmare, I use [Jsonnet](https://jsonnet.org/), which is a JSON superset with variables, functions etc.
To update cluster resources, I use [`kubecfg`](https://github.com/bitnami/kubecfg).

## Cheat sheet

* `nix-shell` - start an interactive shell with needed tools (it also creates a `k` alias for `kubectl`);
* `kubecfg update *.jsonnet` - update Kubernetes resources.

## Bootstrapping

Before above workflow became possible, I had to:

- point `example.com` to the cluster IP;
- get a VM;
- install vanilla K3s;
- setup firewall;
- copy `/etc/rancher/k3s/k3s.conf` from the VM to `~/.kube/config` on my workstation;
- open or tunnel the Kubernetes API port (in my case `ssh -L 6443:localhost:6443 vm` is good enough);
- allow cross-node traffic.

## Heterogeneous architecture

I experiment with having nodes with different CPU architectures (currently `x86_64` and `aarch64`).

Since not every service is available on every architecture, I have [tainted](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) my nodes with `necior/arch=x86_64:NoExecute` xor `necior/arch=aarch64:NoExecute` and I have added appropriate tolerations to Deployments objects.

