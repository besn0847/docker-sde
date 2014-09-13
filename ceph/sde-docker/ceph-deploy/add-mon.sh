#!/bin/sh

cp /home/ceph/ceph.conf /etc/ceph/ceph.conf

cp /home/ceph/ceph.client.admin.keyring /etc/ceph/ceph.client.admin.keyring

sed -i -e "s/mon_initial_members = 0, 1, 2/mon_initial_members = 0/g" /etc/ceph/ceph.conf

sed -i -e "s/mon_host = 10.10.0.11, 10.10.0.12, 10.10.0.18/mon_host = 10.10.0.11/g" /etc/ceph/ceph.conf

mkdir /var/lib/ceph/mon/ceph-$1

ceph auth get mon. -o /tmp/keyring

ceph mon getmap -o /tmp/monmap

ceph-mon -i $1 --mkfs --monmap /tmp/monmap --keyring /tmp/keyring

echo "[program:ceph-mon]" > /etc/supervisor/conf.d/ceph-mon.conf

echo "command=ceph-mon -i $1" >> /etc/supervisor/conf.d/ceph-mon.conf

supervisorctl reread

supervisorctl update

ceph mon add $1 $2 

