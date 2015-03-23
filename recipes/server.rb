include_recipe 'apt'
include_recipe 'et_ntp::discover'

node.set['ntp']['peers'] = node['et_ntp']['pool'] unless node['et_ntp']['pool'].empty?

include_recipe 'ntp::default'
