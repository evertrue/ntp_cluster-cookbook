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

node.set['ntp']['servers'] = [
  node['ntp_cluster']['master']
]
node.default['ntp']['server']['prefer'] = node['ntp_cluster']['master']

node.set['ntp']['peers'] = node['ntp_cluster']['standbys']

include_recipe 'ntp_cluster::server'
