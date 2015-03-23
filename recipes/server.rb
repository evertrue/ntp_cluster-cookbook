include_recipe 'et_ntp::discover'

node.set['ntp']['peers'] = node['et_ntp']['pool']

include_recipe 'ntp::default'
