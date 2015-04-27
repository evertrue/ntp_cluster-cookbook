name             'ntp_cluster'
maintainer       'EverTrue, Inc.'
maintainer_email 'devops@evertrue.com'
license          'apache2'
description      'Configures an HA and highly consistent NTP Cluster synced to wall clock time'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.3'

supports 'ubuntu', '>= 12.04'

depends 'ntp', '~> 1.7'
depends 'apt'
depends 'cron', '~> 1.6'
