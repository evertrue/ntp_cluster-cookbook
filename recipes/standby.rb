
node.set['ntp']['servers'] = [
  node['et_ntp']['master']
]
node.default['ntp']['server']['prefer'] = node['et_ntp']['master']

node.set['ntp']['peers'] = node['et_ntp']['standbys']

include_recipe 'et_ntp::server'
