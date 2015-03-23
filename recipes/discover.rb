pool = search(
  :node,
  node['et_ntp']['discovery'] +
  " AND chef_environment:#{node.chef_environment}"
)

if pool.any?
  node.default['et_ntp']['pool'] = pool.map { |n| n['fqdn'] }
else
  log(
    'Could not find private ntp servers using the search string: ' \
    "#{node['et_ntp']['discovery']}" \
    " AND chef_environment:#{node.chef_environment}" \
    'Falling back to the ntp cookbook\'s defaults'
  )
end
