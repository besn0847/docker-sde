#!/bin/sh

# 1.SSH key-based authentication must be enabled
# 2.Docker must be listenning on tcp://
# 3.'franck' user must be sudoer on each docker host without password
# 4.The 2 docker hosts clock must be sync'ed using NTP

DOCKER1_HOST=192.168.1.17
DOCKER1_SSH_PORT=2221
DOCKER1_DOK_PORT=4241

DOCKER2_HOST=192.168.1.17
DOCKER2_SSH_PORT=2222
DOCKER2_DOK_PORT=4242

# Step : Restore permissions
chmod 600 ceph-deploy/id_rsa && chmod 644 ceph-deploy/id_rsa.pub

# Step : Sync docker hosts clocks
ssh franck@$DOCKER1_HOST -p $DOCKER1_SSH_PORT 'sudo ntpdate 0.fr.pool.ntp.org'
ssh franck@$DOCKER2_HOST -p $DOCKER2_SSH_PORT 'sudo ntpdate 0.fr.pool.ntp.org'

# Step : Copy files to remote hosts
scp -P $DOCKER1_SSH_PORT conf/hosts franck@$DOCKER1_HOST:
scp -P $DOCKER2_SSH_PORT conf/hosts franck@$DOCKER2_HOST:

scp -P $DOCKER1_SSH_PORT scripts/init.sh franck@$DOCKER1_HOST:
scp -P $DOCKER2_SSH_PORT scripts/init.sh franck@$DOCKER2_HOST:

scp -P $DOCKER1_SSH_PORT scripts/plumb.sh franck@$DOCKER1_HOST:
scp -P $DOCKER2_SSH_PORT scripts/plumb.sh franck@$DOCKER2_HOST:

scp -P $DOCKER1_SSH_PORT scripts/clean.sh franck@$DOCKER1_HOST:
scp -P $DOCKER2_SSH_PORT scripts/clean.sh franck@$DOCKER2_HOST:

scp -P $DOCKER1_SSH_PORT scripts/start1.sh franck@$DOCKER1_HOST:
scp -P $DOCKER2_SSH_PORT scripts/start2.sh franck@$DOCKER2_HOST:

scp -P $DOCKER1_SSH_PORT scripts/stop1.sh franck@$DOCKER1_HOST:
scp -P $DOCKER2_SSH_PORT scripts/stop2.sh franck@$DOCKER2_HOST:

# Create images if they don't already exist
# 1. Base image
docker -H tcp://$DOCKER1_HOST:$DOCKER1_DOK_PORT images | grep -v REPOSITORY | awk '{print $1}' - | grep "ceph/base" > /dev/null 2>&1
if [ $? -eq 1 ]
then
   cd ceph-base
   docker -H tcp://$DOCKER1_HOST:$DOCKER1_DOK_PORT build -t ceph/base .
   cd ..
fi

docker -H tcp://$DOCKER2_HOST:$DOCKER2_DOK_PORT images | grep -v REPOSITORY | awk '{print $1}' - | grep "ceph/base" > /dev/null 2>&1
if [ $? -eq 1 ]
then
   cd ceph-base
   docker -H tcp://$DOCKER2_HOST:$DOCKER2_DOK_PORT build -t ceph/base .
   cd ..
fi

# 2. Deploy image
docker -H tcp://$DOCKER1_HOST:$DOCKER1_DOK_PORT images | grep -v REPOSITORY | awk '{print $1}' - | grep "ceph/deploy" > /dev/null 2>&1
if [ $? -eq 1 ]
then
   cd ceph-deploy
   docker -H tcp://$DOCKER1_HOST:$DOCKER1_DOK_PORT build -t ceph/deploy .
   cd ..
fi

docker -H tcp://$DOCKER2_HOST:$DOCKER2_DOK_PORT images | grep -v REPOSITORY | awk '{print $1}' - | grep "ceph/deploy" > /dev/null 2>&1
if [ $? -eq 1 ]
then
   cd ceph-deploy
   docker -H tcp://$DOCKER2_HOST:$DOCKER2_DOK_PORT build -t ceph/deploy .
   cd ..
fi

# 3. Node image
docker -H tcp://$DOCKER1_HOST:$DOCKER1_DOK_PORT images | grep -v REPOSITORY | awk '{print $1}' - | grep "ceph/node" > /dev/null 2>&1
if [ $? -eq 1 ]
then
   cd ceph-node
   docker -H tcp://$DOCKER1_HOST:$DOCKER1_DOK_PORT build -t ceph/node .
   cd ..
fi

docker -H tcp://$DOCKER2_HOST:$DOCKER2_DOK_PORT images | grep -v REPOSITORY | awk '{print $1}' - | grep "ceph/node" > /dev/null 2>&1
if [ $? -eq 1 ]
then
   cd ceph-node
   docker -H tcp://$DOCKER2_HOST:$DOCKER2_DOK_PORT build -t ceph/node .
   cd ..
fi

# Step : Initialize Docker hosts
ssh franck@$DOCKER1_HOST -p $DOCKER1_SSH_PORT './init.sh' 
ssh franck@$DOCKER2_HOST -p $DOCKER2_SSH_PORT './init.sh' 

# Step : Finalize docker plumbing, start all containers & plumb each of them
ssh franck@$DOCKER1_HOST -p $DOCKER1_SSH_PORT './start1.sh' 
ssh franck@$DOCKER2_HOST -p $DOCKER2_SSH_PORT './start2.sh' 
