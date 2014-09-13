#!/bin/sh

# Add a local interface to communicate with VLAN 10
sudo /sbin/ifconfig tep0 192.168.200.2 netmask 255.255.255.0
sudo /sbin/ip addr add 10.10.0.2 broadcast 10.10.0.255 dev veth1

sudo /sbin/ifconfig veth1 mtu 750

sudo /sbin/ip link set veth0 up
sudo /sbin/ip link set veth1 up

sudo /usr/bin/ovs-vsctl add-port br2 gre0 -- set interface gre0 type=gre options:remote_ip=192.168.100.1

sudo /sbin/route add -net 10.10.0.0/24 dev veth1

# Step : Start the 3 nodes and plumb them
#       node 2 -> Ceph MON
#       node 4 -> Ceph OSD
#       node 6 -> Ceph MDS
#       node 8 -> Ceph MON (needed for Quorum in case of Failover)

docker run -d -i -p 22 --hostname="ceph-node2" --name="ceph-node2" ceph/node
sudo ./plumb.sh br2 ceph-node2 10.10.0.12/24 10.10.0.255 10

docker run -d -i -p 22 --hostname="ceph-node4" --name="ceph-node4" -v "$PWD"/Volumes/ceph/mnt/ceph-storage:/var/lib/ceph/osd/ceph-storage ceph/node
sudo ./plumb.sh br2 ceph-node4 10.10.0.14/24 10.10.0.255 10

docker run -d -i -p 22 --hostname="ceph-node6" --name="ceph-node6" ceph/node
sudo ./plumb.sh br2 ceph-node6 10.10.0.16/24 10.10.0.255 10

docker run -d -i -p 22 --hostname="ceph-node8" --name="ceph-node8" ceph/node
sudo ./plumb.sh br2 ceph-node8 10.10.0.18/24 10.10.0.255 10

