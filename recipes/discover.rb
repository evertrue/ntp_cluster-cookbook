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

pool = search(
  :node,
  "#{node['ntp_cluster']['discovery']} AND chef_environment:#{node.chef_environment}"
).select { |n| n['fqdn'] && n['ipaddress'] } # Don't count partially provisioned nodes

if pool.any?
  node.default['ntp_cluster']['pool'] = pool.map { |n| n['ipaddress'] }
else
  log "Could not find any private ntp servers using the search string: '#{discover}'"
end

# Go through the pool and put the sandbys in the standbys list and masters in the masters list
master_nodes = pool.select do |n|
  n['tags'] && n['tags'].include?(node['ntp_cluster']['master_tag'])
end

standbys = (pool.map { |n| n['ipaddress'] } - master_nodes.map { |n| n['ipaddress'] })

if master_nodes.length > 1
  Chef::Log.warn(
    "Chef found more than 1 ntp master in this cluster, this is not correct!\n" \
    "Only 1 node should be an ntp master for the cluster, otherwise there\n" \
    "will be multiple true times.\n" \
    "Masters are:\n" \
    "#{master_nodes.map { |n| " * #{n['fqdn']}" }.join "\n"}"
  )

  if master_nodes.find { |n| n.name == node.name }
    standbys << node['ipaddress']

    # remove the master tage from this node
    node.normal['tags'] = node['tags'].reject { |t| t == node['ntp_cluster']['master_tag'] }.uniq

    if node['tags'].include? 'ntp_master'
      raise 'You are overriding me! Please check your overrides for tags attribute'
    end
  end

  # by default in a multimaster env, the master is the node with the highest fqdn
  node.override['ntp_cluster']['master'] = master_nodes.reject { |n| n.name == node.name }.max

elsif master_nodes.length == 1
  Chef::Log.debug "Master is #{master_nodes.first['fqdn']} [#{master_nodes.first['ipaddress']}]"
  node.override['ntp_cluster']['master'] = master_nodes.first['ipaddress']
elsif node.role?(node['ntp_cluster']['server_role'])
  # Note that in order to actually test this mode, you must remove the master_tag attribute from
  # the _default-ntp-1b test node. Otherwise it's skipped over in all serverspec tests.

  Chef::Log.debug 'Server pool contains no masters. Appointing myself.'
  node.normal['tags'] = ((node['tags'] || []) | [node['ntp_cluster']['master_tag']])
else
  raise 'No servers detected.'
end

node.override['ntp_cluster']['standbys'] = standbys

Chef::Log.info " > Tags: #{node['tags'].inspect}"
Chef::Log.info " > Master Server: #{node['ntp_cluster']['master'].inspect}"
Chef::Log.info " > Standby Servers: #{node['ntp_cluster']['standbys'].inspect}"
