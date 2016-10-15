# ntp_cluster-cookbook

[![Build Status](https://travis-ci.org/evertrue/ntp_cluster-cookbook.svg)](https://travis-ci.org/evertrue/ntp_cluster-cookbook)

Provides automated discovery and configuration of a private ntp pool via chef.

## Usage

This cookbook will automagically assign master and standby nodes in the cluster.
The only thing you have to have is a role named `ntp_server` and assign that role
to the node that you want to be part of the ntp cluster

This role should be the same role used in the `['ntp_cluster']['discovery']` search string.

You should NOT use any of the extra recipes in this cookbook, just use the default
recipe and the `ntp_server` role as it will take care of all the chef magic.

## Concepts

The concept behind this type of NTP Cluster is to have a cluster that is consistent enough to
run time sensitive distributed applications like Cassandra where nodes in the application cluster
needs to be completely in sync with each other (read microseconds) and reasonably close to wall clock time.
To accomplish this a single *true* time server (master) is synced with the outside world. All application servers
sync with this server (or its standbys in the event of failure). This ensures that all the
application servers are obtaining their time from the exact same external source and are connected to a very
low-latency low-demand internal server.

Standby servers are used for when a failure in the master occurs.  If the master fails, clients will
sync with the standby servers which will maintain their understanding of time with each other using
peered timekeeping.

If the master node is completely removed from the cluster (delete node from chef-server) then a standby server is
promoted to master and given the external server list to sync with, all remaining standby servers will pull their
times directly from the newly promoted standby.

It is highly recommended that you set the `['ntp_cluster']['public_servers']` to a pool better than the
[ntp](https://github.com/gmiranda23/ntp) cookbook's default pool.

## Commissioning a new cluster

To commission a new cluster you **must be patient**. This is time, it moves slowly. Understand that first.  Second, NTP is a very redundant
and methodical protocol. The worst thing you can do is rush this process because there are a lot of slow moving parts (NTP, DNS, Chef).

1. Provision a box with the `ntp_cluster` recipe.  This box will immediately become a master and start syncing its time
2. Wait an hour and then verify that the master's clock is correct.  Waiting allows both NTP to sync its time, DNS to propagate,
and chef to runs some extra convergences
3. Provision all your standby servers. This can happen in bulk.
4. Wait another hour for the standby layer to sync up.
5. Verify that the cluster is configured properly by checking the `server` and `peer` directives in `/etc/ntp.conf`
5. Enable `ntp_server` for all of your application servers. They will immediately start looking to the new cluster for time. If
the time it vastly off by 100ms or more then they WILL jump.  Be aware of the dangers of time jumps.


### Debugging

If there are problems commissioning a server check `/etc/ntp.conf` and use the `ntpq -p` command to show the connected servers and there statuses

### Ports

Lastly, NTP communicates on UDP port 123. Make sure that all of your server nodes are accepting UDP packets on port 123

## Commissioning Servers

## Master Server

Master servers should not be commissioned directly.  They should be promoted from existing slaves as the clock is already in sync

## Standby Server

1. Create the server and apply the `ntp_cluster` cookbook to it.
2. Converge the server.
3. Verify that `/etc/ntp.conf` is configured to peer with the standbys and have the master as its only server

## Decommissioning Servers

### Master Server

1. Delete the node and client from the chef-server.
2. Converge 1 of your standby servers so that it will promote itself to master
3. Verify that the new master has been selected by performing `knife search 'tags:ntp_master'`
4. Converge the rest of your standbys
5. Converge all of your servers so that they stop looking to the old master
6. Burn down the old master

### Standby Server

1. Delete the node and client from the chef-server.
2. Converge all of your other standbys so that they stop looking to that standby server
2. Converge all of your application servers so that they stop looking to that standby server
3. Burn down the box

### Client

1. Just burn it down

## Replacing Servers

### Master Server

You should follow the decommissioning of a master server process above and then provision a new **standby**

### Standby Server

Follow the decommissioning of a standby server then commission a new standby

## Supported Platforms

* Ubuntu 12.04
* Ubuntu 14.04

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['ntp_cluster']['discovery']</tt></td>
    <td>String</td>
    <td>The Chef Search query to find ntp servers</td>
    <td><tt>role:ntp_server</tt></td>
  </tr>
  <tr>
    <td><tt>['ntp_cluster']['public_servers']</tt></td>
    <td>Array</td>
    <td>The List of external servers to sync with</td>
    <td><tt>#.pool.ntp.org servers</tt></td>
  </tr>
</table>

## Usage

### ntp_cluster::default

Include this recipe in a wrapper cookbook:

```ruby
depends 'ntp_cluster', '~> 1.0'
```

And then in your wrapper cookbook

```ruby
include_recipe 'ntp_cluster::default'
```

## License and Authors

Author:: EverTrue, Inc. (<devops@evertrue.com>)

## Diagrams

The following diagrams should hopefully clarify the expected behavior of a properly configured cluster

### Normal Operation
<img width="943" alt="screen shot 2016-09-15 at 5 01 17 pm" src="https://cloud.githubusercontent.com/assets/1410448/18567468/46e5c440-7b66-11e6-849d-129a271a2e73.png">

### Failed Master
<img width="936" alt="screen shot 2016-09-15 at 5 01 35 pm" src="https://cloud.githubusercontent.com/assets/1410448/18567467/46e54d26-7b66-11e6-87bd-5f70f54281ce.png">

<img width="952" alt="screen shot 2016-09-15 at 5 01 27 pm" src="https://cloud.githubusercontent.com/assets/1410448/18567466/46e521f2-7b66-11e6-9cae-070bb4b9a56f.png">

### Failed Master and 1 Failed Slave
<img width="951" alt="screen shot 2016-09-15 at 5 01 42 pm" src="https://cloud.githubusercontent.com/assets/1410448/18567464/46dfd1de-7b66-11e6-9b7f-0335258abd6a.png">

### Network Segmentation
<img width="954" alt="screen shot 2016-09-15 at 5 00 59 pm" src="https://cloud.githubusercontent.com/assets/1410448/18567465/46e460fa-7b66-11e6-9a44-7d85abcd4fb4.png">
