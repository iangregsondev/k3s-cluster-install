# k3s Cluster Installation

This repository provides a script to set up a k3s Kubernetes cluster using `k3sup`. The script will install a k3s server on a primary node and join two additional nodes to the cluster.

## Prerequisites

1. **SSH Key**: Ensure you have an SSH key generated.
2. **Servers**: You need three linux servers with IP addresses.
3. **User**: A common user across all servers with SSH access.
4. **k3sup**: Install `k3sup` on your local machine. You can find installation instructions [here](https://github.com/alexellis/k3sup).

## Script Overview

The provided script does the following:

1. Sets up environment variables for SSH key, server IPs, user, context name, kubeconfig path, and k3s version.
2. Installs k3s on the primary server in clustering mode.
3. Installs k3s on the additonal servers and joins these to the k3s cluster.

Having a minimum of three servers ensures quorum, which is crucial for high availability and fault tolerance in the cluster. Quorum prevents split-brain scenarios and ensures that the cluster can continue to operate correctly even if one of the servers fails.

## Usage

1. **Clone the repository**:

   ```bash
   git clone git@github.com:iangregsondev/k3s-cluster-install.git
   cd k3s-cluster-install
   ```

2. **Update Variables**: Open the `install.sh` script and you will probably need to update the following variables with your values:

   - `SSH_KEY`: The full path to your SSH key.
   - `SERVER1_IP`: The IP that should be assigned to Server 1.
   - `SERVER2_IP`: The IP that should be assigned to Server 2.
   - `SERVER3_IP`: The IP that should be assigned to Server 3.
   - `USER`: The username used for the SSH connection.
   - `CONTEXT_NAME`: The name of the Kubernetes context that will be used to refer to your cluster.

   Additionally, you can optionally change the following variables:

   - `KUBECONFIG`: The path to your kubeconfig file.
   - `K3S_VERSION`: The version of k3s to install.

3. **Run the Script**:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## Script Details

```bash
#!/bin/bash

set -x

export SSH_KEY=$HOME/.ssh/id_ed25519

export SERVER1_IP=192.168.1.30
export SERVER2_IP=192.168.1.31
export SERVER3_IP=192.168.1.32

export USER=ubuntu
export CONTEXT_NAME=acmehomelab
export KUBECONFIG=$HOME/.kube/config

export K3S_VERSION=v1.30.1+k3s1

k3sup install \
  --ip $SERVER1_IP \
  --user $USER \
  --ssh-key "$SSH_KEY" \
  --cluster \
  --no-extras \
  --k3s-version $K3S_VERSION \
  --merge \
  --local-path "$KUBECONFIG" \
  --context $CONTEXT_NAME

k3sup join \
  --ip $SERVER2_IP \
  --user $USER \
  --ssh-key "$SSH_KEY" \
  --server-user $USER \
  --server-ip $SERVER1_IP \
  --server \
  --no-extras \
  --k3s-version $K3S_VERSION

k3sup join \
  --ip $SERVER3_IP \
  --user $USER \
  --ssh-key "$SSH_KEY" \
  --server-user $USER \
  --server-ip $SERVER1_IP \
  --server \
  --no-extras \
  --k3s-version $K3S_VERSION
```

## Explanation

- No extras are being installed (servicelb and traefik), these tend to be older versions and opting not to install these will allow the installation of a specific load balancer and reverse proxy.
- set -x: Enables debug mode to print each command before executing it.
- Environment Variables: Define necessary variables such as SSH key path, server IPs, k3s version, user, kubeconfig path, and Kubernetes context name.
- k3sup install: Installs k3s on the primary server (SERVER1_IP) in clustering mode.
- k3sup join: Installs and joins additional servers (SERVER2_IP and SERVER3_IP) to the cluster.

## Recommendations

After the initial setup, it is recommended to install the following inside your cluster:

- **Load balancer**: [metallb](https://metallb.universe.tf) - Provides network load balancing for bare metal Kubernetes clusters.
- **Reverse Proxy**: [traefik](https://traefik.io/traefik) - Serves as an ingress controller to manage and route incoming traffic to your services.
- **Persistent Storage**: [longhorn](https://longhorn.io) - Provides highly available persistent storage for your Kubernetes cluster.
- **Certificate Management**: [cert-manager](https://cert-manager.io) - Automates the management and issuance of TLS certificates in your cluster.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE.md) file for details.

## References

- [k3s](https://k3s.io)
- [k3sup](https://github.com/alexellis/k3sup)

## Acknowledgements

- Thanks to [Alex Ellis](https://github.com/alexellis) for creating k3sup.

Feel free to open an issue or submit a pull request if you have any questions or improvements.
