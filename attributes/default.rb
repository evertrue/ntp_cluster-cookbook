default['ntp_cluster']['server_role'] = 'ntp_server'

default['ntp_cluster']['pool'] = []

default['ntp_cluster']['public_servers'] = [
  '0.amazon.pool.ntp.org',
  '1.amazon.pool.ntp.org',
  '2.amazon.pool.ntp.org',
  '3.amazon.pool.ntp.org'
]

set['ntp']['servers'] = node['ntp_cluster']['public_servers']
