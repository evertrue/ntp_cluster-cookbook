name             'ntp_cluster'
maintainer       'EverTrue, Inc.'
maintainer_email 'devops@evertrue.com'
license          'apache2'
description      'Configures an HA and highly consistent NTP Cluster synced to wall clock time'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.1.3'

supports 'ubuntu', '>= 14.04'

depends 'ntp', '~> 3.0'
depends 'apt'
depends 'cron', '~> 3.0'
