include_recipe 'et_ntp::discover'

node.set['ntp']['peers'] = @pool

include_recipe 'ntp::default'
