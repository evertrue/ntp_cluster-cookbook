# ntp_cluster-cookbook

[![Build Status](https://travis-ci.org/evertrue/ntp_cluster-cookbook.svg)](https://travis-ci.org/evertrue/ntp_cluster-cookbook)

Provides automated discovery and configuration of a private NTP cluster via Chef.

## Usage

This cookbook will automagically assign master and standby nodes in the cluster. The first provisioned server will set itself as a master. Additional servers will find this server (using Chef Search) and configure themselves as standby peers.

If two masters are created at the same time (e.g. because nodes are provisioned in parallel), the node with the first name in alphabetical order will take precedence.

## Decommissioning Master Servers

1. Delete the node and client from the chef-server.
2. Converge 1 of your standby servers so that it will promote itself to master
3. Verify that the new master has been selected by performing `knife search 'tags:ntp_master'`
4. Converge the rest of your standbys
5. Converge all of your servers so that they stop looking to the old master
6. Burn down the old master

## Supported Platforms

* Ubuntu 14.04

## Attributes

All attributes fall under the `node['ntp_cluster']` key.

<table>
  <tr>
    <th>Key</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['discovery']</tt></td>
    <td>String: The Chef Search query to find ntp servers</td>
    <td><tt>role:#{node['ntp_cluster']['server_role']}</tt></td>
  </tr>
  <tr>
    <td><tt>['public_servers']</tt></td>
    <td>Array: The List of external servers to sync with</td>
    <td><tt>%w(
  0.pool.ntp.org
  1.pool.ntp.org
  2.pool.ntp.org
  3.pool.ntp.org
)</tt></td>
  </tr>
  <tr>
    <td><tt>['verify']['retries']</tt></td>
    <td>Integer: NTP Pool connectivity checker number of retries</td>
    <td><tt>12</tt></td>
  </tr>
  <tr>
    <td><tt>['verify']['retry_delay']</tt></td>
    <td>Integer: NTP Pool connectivity checker number of seconds between retries</td>
    <td><tt>5</tt></td>
  </tr>
</table>

## Usage

### ntp_cluster::default

Include this recipe in a wrapper cookbook:

```ruby
depends 'ntp_cluster'
```

And then in your wrapper cookbook

```ruby
include_recipe 'ntp_cluster::default'
```

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

## License and Authors

Author:: Evertrue, Inc. (<devops@evertrue.com>)
