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

include_recipe 'apt'
include_recipe 'ntp_cluster::discover' if node['ntp_cluster']['discovery']

if node.role? node['ntp_cluster']['server_role'] # server?
  include_recipe 'ntp_cluster::server'
else
  Chef::Log.debug 'NTP: Node is a client'
  include_recipe 'ntp_cluster::client'
end

Chef::Log.debug("NTP Servers: #{node['ntp']['servers'].inspect}")
Chef::Log.debug("NTP Peers: #{node['ntp']['peers'].inspect}")

include_recipe 'ntp::default'

execute 'verify ntp pool connectivity' do
  command '! /usr/bin/ntpq -p | grep "\.INIT\."'
  retries node['ntp_cluster']['verify']['retries']
  retry_delay node['ntp_cluster']['verify']['retry_delay']
end
