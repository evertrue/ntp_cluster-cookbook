default['ntp_cluster']['discovery'] = "role:#{node['ntp_cluster']['server_role']}"
default['ntp_cluster']['master_tag'] = 'ntp_master'
