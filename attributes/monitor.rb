default['ntp_cluster']['monitor']['enabled'] = false

default['ntp_cluster']['monitor']['begin'] = 'true'
default['ntp_cluster']['monitor']['complete'] = 'true'
default['ntp_cluster']['monitor']['fail'] = 'false'

default['ntp_cluster']['monitor']['install_dir'] = '/usr/bin'

node['ntp_cluster']['monitor']['hour'] = '*'
node['ntp_cluster']['monitor']['minute'] = '*/5'
