name             'et_ntp'
maintainer       'EverTrue, Inc.'
maintainer_email 'devops@evertrue.com'
license          'apache2'
description      'Installs/Configures et_ntp'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.2'

supports 'ubuntu', '~> 14.04'
supports 'ubuntu', '~> 12.04'

depends 'ntp', '~> 1.7'
depends 'apt'
