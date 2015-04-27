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
