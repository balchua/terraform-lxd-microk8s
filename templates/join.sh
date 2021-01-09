#!/bin/sh

until microk8s.status --wait-ready; 
  do sleep 3; echo "waiting for worker status.."; 
done

sleep 10            
microk8s.join ${controller_name}:25000/${cluster_token}