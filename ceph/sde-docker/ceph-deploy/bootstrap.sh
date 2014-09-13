#!/bin/sh

########################################
# Step : Bootstrap Ceph MON
########################################
# Mon 0 on ceph-node1
scp init-mon.sh ceph@ceph-node1:/home/ceph
scp ceph.conf ceph@ceph-node1:/home/ceph

ssh ceph@ceph-node1 'sudo /home/ceph/init-mon.sh 0 10.10.0.11'

scp ceph@ceph-node1:/home/ceph/ceph.client.admin.keyring .

# Mon 1 on ceph-node2
scp add-mon.sh ceph@ceph-node2:/home/ceph
scp ceph.conf ceph@ceph-node2:/home/ceph
scp ceph.client.admin.keyring ceph@ceph-node2:/home/ceph/

ssh ceph@ceph-node2 'sudo /home/ceph/add-mon.sh 1 10.10.0.12'

# Mon 2 on ceph-node8
scp add-mon.sh ceph@ceph-node8:/home/ceph
scp ceph.conf ceph@ceph-node8:/home/ceph
scp ceph.client.admin.keyring ceph@ceph-node8:/home/ceph/

ssh ceph@ceph-node8 'sudo /home/ceph/add-mon.sh 2 10.10.0.18'

########################################
# Step : Bootstrap Ceph OSDs
########################################
# Osd 0 on ceph-node3
scp ceph.conf ceph@ceph-node3:/home/ceph
scp init-osd.sh ceph@ceph-node3:/home/ceph
scp ceph.client.admin.keyring ceph@ceph-node3:/home/ceph/

ssh ceph@ceph-node3 'sudo /home/ceph/init-osd.sh 0 ceph-node3'

# Osd 1 on ceph-node4
scp ceph.conf ceph@ceph-node4:/home/ceph
scp init-osd.sh ceph@ceph-node4:/home/ceph
scp ceph.client.admin.keyring ceph@ceph-node4:/home/ceph/

ssh ceph@ceph-node4 'sudo /home/ceph/init-osd.sh 1 ceph-node4'

########################################
# Step : Bootstrap Ceph MDS
########################################
# Mds 0 on ceph-node5
scp ceph.conf ceph@ceph-node5:/home/ceph
scp init-mds.sh ceph@ceph-node5:/home/ceph
scp ceph.client.admin.keyring ceph@ceph-node5:/home/ceph/

ssh ceph@ceph-node5 'sudo /home/ceph/init-mds.sh 0 ceph-node5'

# Mds 1 on ceph-node6
scp ceph.conf ceph@ceph-node6:/home/ceph
scp init-mds.sh ceph@ceph-node6:/home/ceph
scp ceph.client.admin.keyring ceph@ceph-node6:/home/ceph/

ssh ceph@ceph-node6 'sudo /home/ceph/init-mds.sh 1 ceph-node6'

# Step : Return secret key 
KEY=`grep "key = " ceph.client.admin.keyring | awk -F "key = " '{ print $2}' -`
echo "Filesystem secret key : $KEY"

echo "Docker host 1 :"
echo "	sudo mount -t ceph 10.10.0.11:6789:/ Volumes/ceph/mnt/ceph-dfs/ -o name=admin,secret="$KEY
echo "	sudo sudo chgrp -R docker Volumes/ceph/mnt/ceph-dfs/"
echo "	sudo chmod -R g+w Volumes/ceph/mnt/ceph-dfs/"

echo "Docker host 2 :"
echo "	sudo mount -t ceph 10.10.0.12:6789:/ Volumes/ceph/mnt/ceph-dfs/ -o name=admin,secret="$KEY

