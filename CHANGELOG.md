# 1.1.1

* Add retry to `execute[verify ntp pool connectivity]` resource to prevent it from stopping an initial convergence

# 1.1.0

* Add verification that NTP pool is reachable
* Make server discovery optional
* Drop testing on Ubuntu 12.04

# 1.0.8

* Bring back `fail` state for Cronitor check
    - The fail endpoint is a premium feature, so now it works

# 1.0.7

* Remove erroneous fail state from ntpcheck cronjob

# 1.0.6

* Wrap cron monitor commands in quotes.

# 1.0.5

* Pipe stdout from the monitor script to logger to prevent root cron emails

# 1.0.4

* Documentation Updates

# 1.0.3

* Always run the monitor recipe so that cron job gets removed if monitor is disabled
* Removed redundant iburst
* Set ntp server pool to the default pool.ntp.org

# 1.0.2

* `set` `['ntp']['servers']` and `['ntp']['peers']` in `ntp_cluster::master` recipe
* Stores the public ntp servers in a different attribute to avoid overrides
* `set` the ['ntp']['servers'] attribute instead of `default`

# 1.0.1

* Update Attribute precidence for ntp master, slave, and ntp cookbook settings

# 1.0.0

Initial release of ntp_cluster

Supports

* Master/Slave cluster configuration
* Chef elected master/slaves
* Monitoring scripts
* Overrides to the amazon ntp pool
* Lots of other NTP goodies
