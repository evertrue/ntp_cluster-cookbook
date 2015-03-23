@pool = search(
  :node,
  node['et_base']['ntp']['discovery'] +
  " AND chef_environment:#{node.chef_environment}"
)

if pool.any?
  @pool = pool.map { |n| n['fqdn'] }
else
  log(
    'Could not find private ntp servers using the search string: ' \
    "#{node['et_base']['ntp']['discovery']}" \
    " AND chef_environment:#{node.chef_environment}" \
    'Falling back to the ntp cookbook\'s defaults'
  )
end
