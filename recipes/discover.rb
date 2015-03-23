discover = node['et_ntp']['discovery'] + " AND chef_environment:#{node.chef_environment}"
pool = search(
  :node,
  discover
)

if pool.any?
  node.default['et_ntp']['pool'] = pool.map { |n| n['fqdn'] }
else
  log(
    "Could not find any private ntp servers using the search string: '#{discover}'"
  )
end
