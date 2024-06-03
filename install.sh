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
