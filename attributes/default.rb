default['ntp_cluster']['server_role'] = 'ntp_server'

default['ntp_cluster']['pool'] = []

default['ntp_cluster']['public_servers'] = %w(
  0.pool.ntp.org
  1.pool.ntp.org
  2.pool.ntp.org
  3.pool.ntp.org
)

default['ntp_cluster']['verify']['retries'] = 12
default['ntp_cluster']['verify']['retry_delay'] = 5

override['ntp']['servers'] = node['ntp_cluster']['public_servers']
override['ntp']['conf_restart_immediate'] = true
