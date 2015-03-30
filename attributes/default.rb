default['ntp_cluster']['server_role'] = 'ntp_server'

default['ntp_cluster']['pool'] = []

default['ntp']['servers'] = [
  '0.amazon.pool.ntp.org iburst',
  '1.amazon.pool.ntp.org iburst',
  '2.amazon.pool.ntp.org iburst',
  '3.amazon.pool.ntp.org iburst'
]
