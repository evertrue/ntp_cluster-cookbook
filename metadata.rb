name             'ntp_cluster'
maintainer       'EverTrue, Inc.'
maintainer_email 'devops@evertrue.com'
license          'apache2'
description      'Installs/Configures ntp_cluster'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

supports 'ubuntu', '~> 14.04'
supports 'ubuntu', '~> 12.04'

depends 'ntp', '~> 1.7'
depends 'apt'
