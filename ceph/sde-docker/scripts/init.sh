#!/bin/sh

# Step : Add the br10 bridge
sudo /usr/bin/ovs-vsctl add-br br0
sudo /usr/bin/ovs-vsctl add-br br2

sudo /usr/bin/ovs-vsctl add-port br0 tep0 -- set interface tep0 type=internal

sudo /sbin/ip link add name veth0 type veth peer name veth1
sudo /usr/bin/ovs-vsctl add-port br2 veth0 tag=10

# Step : Setting up storage
mkdir -p Volumes/ceph/mnt/ceph-storage

[ -f Volumes/ceph/ceph-storage ] || dd if=/dev/zero of=Volumes/ceph/ceph-storage bs=1k count=2000000

/sbin/mkfs.ext4 -F Volumes/ceph/ceph-storage

sudo mount -o loop Volumes/ceph/ceph-storage   Volumes/ceph/mnt/ceph-storage

# Step : set up mount point for Ceph FS drive
mkdir -p Volumes/ceph/mnt/ceph-dfs/

