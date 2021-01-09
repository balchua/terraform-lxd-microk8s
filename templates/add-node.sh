#!/bin/sh

until microk8s.status --wait-ready; 
  do sleep 3; echo "waiting for worker status.."; 
done

sleep 10  
microk8s.add-node --token ${cluster_token} --token-ttl ${cluster_token_ttl_seconds}
microk8s.config > /client.config
