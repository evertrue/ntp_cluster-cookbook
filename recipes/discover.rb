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

discover = "#{node['ntp_cluster']['discovery']} AND chef_environment:#{node.chef_environment}"
pool = search(
  :node,
  discover
)

if pool.any?
  node.default['ntp_cluster']['pool'] = pool.map { |n| n['fqdn'] }
else
  log(
    "Could not find any private ntp servers using the search string: '#{discover}'"
  )
end

# Go through the pool and put the sandbys in the standbys list and masters in the masters list
master_nodes = pool.select do |n|
  n['tags'] && n['tags'].include?(node['ntp_cluster']['master_tag'])
end

masters = master_nodes.map { |n| n['fqdn'] }.compact

standbys = (pool.map { |n| n['fqdn'] } - masters).compact

if masters.length > 1

  masters_list =  masters.map { |fqdn| " * #{fqdn}" }.join "\n"
  log(
    "Chef found more than 1 ntp master in this cluster, this is not correct!\n" \
    "Only 1 node should be an ntp master for the cluster, otherwise there\n" \
    "will be multiple true times.\n" \
    "Masters are:\n" \
    "#{masters_list}"
  )

  if masters.include?(node['fqdn'])
    standbys << node['fqdn']
    masters.delete node['fqdn']

    # remove the master tage from this node
    node.normal['tags'] = node['tags'].reject { |t| t == node['ntp_cluster']['master_tag'] }.uniq

    if node['tags'].include? 'ntp_master'
      fail '  > You are overriding me! Please check your overrides for tags attribute'
    end
  end

  # by default in a multimaster env, the master is the node with the highest fqdn
  node.set['ntp_cluster']['master'] = masters.max

elsif masters.length == 1
  log 'Master is ' + masters.first
  node.set['ntp_cluster']['master'] = masters.first
else
  tags = node['tags'] || []
  node.normal['tags'] = tags.push(node['ntp_cluster']['master_tag']).uniq

  node.set['ntp_cluster']['master'] = node['fqdn']
end

node.set['ntp_cluster']['standbys'] = standbys.compact

Chef::Log.info " > Tags: #{node['tags'].inspect}"
Chef::Log.info " > Master Server: #{node['ntp_cluster']['master'].inspect}"
Chef::Log.info " > Standby Servers: #{node['ntp_cluster']['standbys'].inspect}"
