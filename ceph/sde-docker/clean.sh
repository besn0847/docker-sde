#!/bin/sh

# 1.SSH key-based authentication must be enabled
# 2.Docker must be listenning on tcp://
# 3. franck user must be sudoer on each docker host without password

DOCKER1_HOST=192.168.1.17
DOCKER1_SSH_PORT=2221
DOCKER1_DOK_PORT=4241

DOCKER2_HOST=192.168.1.17
DOCKER2_SSH_PORT=2222
DOCKER2_DOK_PORT=4242

# Step : Clean Docker hosts
ssh franck@$DOCKER1_HOST -p $DOCKER1_SSH_PORT './clean.sh' 
ssh franck@$DOCKER2_HOST -p $DOCKER2_SSH_PORT './clean.sh' 

