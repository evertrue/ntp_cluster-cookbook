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


if node.recipes.include? 'et_ntp_client::default'
  raise 'Please remove ntp_cluster::server from the run list. These cookbooks cannot co-exist.'
end

include_recipe 'apt'
include_recipe 'ntp_cluster::discover'

if node['tags'].include? 'ntp_master' # MASTER
  Chef::Log.debug 'NTP: Node is a master server'
  node.override['ntp']['peers']   = []
  node.override['ntp']['servers'] = node['ntp_cluster']['public_servers']
else # STANDBY
  Chef::Log.debug 'NTP: Node is a standby server'
  node.override['ntp']['peers']            = node['ntp_cluster']['standbys']
  node.override['ntp']['servers']          = [node['ntp_cluster']['master']]
  node.override['ntp']['server']['prefer'] = node['ntp_cluster']['master']

  Chef::Log.debug("NTP Peers: #{node['ntp']['peers'].inspect}")
  
  include_recipe 'ntp_cluster::monitor'
end

Chef::Log.debug("NTP Servers: #{node['ntp']['servers'].inspect}")

# Open up the interfaces to the network
node.override['ntp']['restrictions'] = node['network']['interfaces'].map do |_interface, config|
  config['addresses'].map do |address, details|
    cmd = "#{address} mask #{details['netmask']} nomodify notrap"
    case details['family']
    when 'inet6'
      "-6 #{cmd}"
    when 'inet'
      cmd
    end
  end
end.flatten.compact.uniq

include_recipe 'ntp::default'

execute 'verify ntp pool connectivity' do
  command '! /usr/bin/ntpq -p | grep "\.INIT\."'
  retries node['ntp_cluster']['verify']['retries']
  retry_delay node['ntp_cluster']['verify']['retry_delay']
end
