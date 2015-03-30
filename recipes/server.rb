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

# Open up the interfaces to the network
restrictions = node['network']['interfaces'].each_with_object do |(_interface, config), r|
  config['addresses'].each do |address, details|
    cmd = "#{address} mask #{details['netmask']} nomodify notrap"
    r << (
    if details['family'] == 'inet'
      cmd
    elsif details['family'] == 'inet6'
      "-6 #{cmd}"
    end)
  end
end.compact

node.set['ntp']['restrictions'] = node['ntp']['restrictions'].concat(restrictions).uniq

include_recipe 'ntp_cluster::monitor' if node['ntp_cluster']['monitor']['enabled']
