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

template "#{node['ntp_cluster']['monitor']['install_dir']}/ntpcheck" do
  source 'ntpcheck.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

# Please note that when you want to make changes to the command you should
# Disable the cron job, converge everything to delete it, then edit the command and reenable
cron_d 'ntpcheck' do
  hour node['ntp_cluster']['monitor']['hour']
  minute node['ntp_cluster']['monitor']['minute']
  command "#{node['ntp_cluster']['monitor']['begin']}; " \
          "( #{node['ntp_cluster']['monitor']['install_dir']}/ntpcheck " \
          "&& #{node['ntp_cluster']['monitor']['success']} ) " \
          "|| #{node['ntp_cluster']['monitor']['fail']} " \
          "| logger -t ntpcheck -p cron.info"
  action node['ntp_cluster']['monitor']['enabled'] ? :create : :delete
end
