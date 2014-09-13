#!/bin/sh

# Add a local interface to communicate with VLAN 10
sudo /sbin/ifconfig tep0 192.168.200.1 netmask 255.255.255.0
sudo /sbin/ip addr add 10.10.0.1 broadcast 10.10.0.255 dev veth1

sudo /sbin/ifconfig veth1 mtu 750

sudo /sbin/ip link set veth0 up
sudo /sbin/ip link set veth1 up

sudo /usr/bin/ovs-vsctl add-port br2 gre0 -- set interface gre0 type=gre options:remote_ip=192.168.100.2

sudo /sbin/route add -net 10.10.0.0/24 dev veth1

# Step : Start the 3 nodes and plumb them
#	node 1 -> Ceph MON
#	node 3 -> Ceph OSD
#	node 5 -> Ceph MDS

docker run -d -i -p 22 --hostname="ceph-node1" --name="ceph-node1" ceph/node
sudo ./plumb.sh br2 ceph-node1 10.10.0.11/24 10.10.0.255 10

docker run -d -i -p 22 --hostname="ceph-node3" --name="ceph-node3" -v "$PWD"/Volumes/ceph/mnt/ceph-storage:/var/lib/ceph/osd/ceph-storage ceph/node
sudo ./plumb.sh br2 ceph-node3 10.10.0.13/24 10.10.0.255 10

docker run -d -i -p 22 --hostname="ceph-node5" --name="ceph-node5" ceph/node
sudo ./plumb.sh br2 ceph-node5 10.10.0.15/24 10.10.0.255 10

# Step : Start the ceph-deploy and plumb it
docker run -d -t -i --hostname="ceph-deploy" --name="ceph-deploy" ceph/deploy 
sudo ./plumb.sh br2 ceph-deploy 10.10.0.10/24 10.10.0.255 10

