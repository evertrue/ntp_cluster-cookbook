default['ntp_cluster']['server_role'] = 'ntp_server'

default['ntp_cluster']['pool'] = []

default['ntp_cluster']['public_servers'] = [
  '0.amazon.pool.ntp.org iburst',
  '1.amazon.pool.ntp.org iburst',
  '2.amazon.pool.ntp.org iburst',
  '3.amazon.pool.ntp.org iburst'
]

set['ntp']['servers'] = node['ntp_cluster']['public_servers']
