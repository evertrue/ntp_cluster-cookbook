# ntp_cluster-cookbook

[![Build Status](https://travis-ci.com/evertrue/ntp_cluster-cookbook.svg)](https://travis-ci.com/evertrue/ntp_cluster-cookbook)

Provides automated discovery and configuration of a private ntp pool via chef.

## Usage

This cookbook will automagically assign master and standby nodes in the cluster.
The only thing you have to have is a role named `ntp_server` and assign that role
to the node that you want to be part of the ntp cluster

This role should be the same role used in the `['ntp_cluster']['discovery']` search string.
And should not need to add to the run list or attributes.

You should NOT use any of the extra recipes in this cookbook, just use the default
recipe as it will take care of all the chef magic.

## Concepts

The concept behind this type of NTP Cluster is to have a cluster that is consistent enough to
run time sensitive distributed applications like cassandra where nodes in the application cluster
need to be completely in sync with each other (read microseconds) and wall clock time. To acomplish
this a Single *true* time server (master) is synced with the outside world. All application servers
sync with this server or it's standby slaves in the event of failure. This ensures that all the
application servers are obtaining their time from the exact same source, whereas with a public pool
you are getting time from different servers all the time.

Standby servers are used for when a failure in the master occurs.  If the master fails, clients will
sync with the standby servers which will maintain their understanding of time with each other using
peered timekeeping.

If the master node is completely removed from the cluster then a standby server is promoted to master
and given the external server list to sync with, all remaining standby servers will pull their times
directly from the promoted standby.

It is highly recommended that you set the `['ntp']['servers']` to a pool better than the
[ntp](https://github.com/gmiranda23/ntp) cookbook's default pool.

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
</table>

## Usage

### ntp_cluster::default

Include `ntp_cluster` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[ntp_cluster::default]"
  ]
}
```

## License and Authors

Author:: EverTrue, Inc. (<devops@evertrue.com>)
