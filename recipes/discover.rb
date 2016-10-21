#
# Cookbook Name:: ntp_cluster
# Recipe:: default
#
# Copyright 2015 EverTrue, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

search_string = "#{node['ntp_cluster']['discovery']} AND chef_environment:#{node.chef_environment}"

pool = search(
  :node,
  search_string,
  filter_result: {
    'name' => %w(name),
    'ipaddress' => %w(ipaddress),
    'tags' => %w(tags)
  }
).select { |n| n['ipaddress'] } # Don't count partially provisioned nodes

if pool.any?
  Chef::Log.debug "NTP server pool: #{pool.inspect}"
else
  Chef::Log.warn "Could not find any private NTP servers using search string: #{search_string}"
end

# Go through the pool and put the sandbys in the standbys list and masters in the masters list
master_nodes = pool.select { |n| n['tags'].include? 'ntp_master' }
standby_ips  = (pool - master_nodes).map { |n| n['ipaddress'] }

if master_nodes.length > 1
  Chef::Log.warn 'NTP: Multiple masters were found. Selecting a single one.'

  # by default in a multimaster env, the master is the node with the highest name
  node.override['ntp_cluster']['master'] = master_nodes.sort_by { |n| n['name'] }.max['ipaddress']

  # If the highest name doesn't turn out to be us, and we have a master tag, remove it and
  # set us as a standby
  if node['tags'].include?('ntp_master') && node['ntp_cluster']['master'] != node['ipaddress']
    node.normal['tags'] = node['tags'] - %w(ntp_master)
    standby_ips << node['ipaddress']
  end
elsif master_nodes.length == 1
  node.override['ntp_cluster']['master'] = master_nodes.first['ipaddress']
else
  # Note that in order to actually test this mode, you must remove the master_tag attribute from
  # the _default-ntp-1b test node. Otherwise it's skipped over in all serverspec tests.

  Chef::Log.debug 'Server pool contains no masters. Appointing myself.'
  node.normal['tags'] = (node['tags'] | %w(ntp_master))
  node.override['ntp_cluster']['master'] = node['ipaddress']
end

node.override['ntp_cluster']['standbys'] = standby_ips

Chef::Log.info " > Tags: #{node['tags'].inspect}"
Chef::Log.info " > Master Server: #{node['ntp_cluster']['master'].inspect}"
Chef::Log.info " > Standby Servers: #{node['ntp_cluster']['standbys'].inspect}"
