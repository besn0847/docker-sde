#!/bin/sh

# Step : Stop the 3 nodes 
docker stop ceph-node1
docker stop ceph-node3
docker stop ceph-node5

# Step : Stop the ceph-deploy
docker stop ceph-deploy

