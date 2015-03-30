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

# Go through the pool and put the sandbys in the standbys list and masters in the masters list
masters = pool.select do |n|
  n['tags'] && n['tags'].include?(node['et_ntp']['master_tag'])
end

masters = masters.map { |n| n['fqdn'] }.compact

standbys = (pool.map { |n| n['fqdn'] } - masters).compact

if masters.length > 1
  log(
    "Chef found more than 1 ntp master in this cluster, this is not correct!\n" \
    "Only 1 node should be an ntp master for the cluster, otherwise there\n" \
    "will be multiple true times.\n"
  )

  # Go through each of the nodes tagged as masters to see if we are an offending node and should
  # become a standby node
  masters.each do |master|
    puts 'bleah' + master
    log(" * #{master['fqdn']} (#{master['ipaddess']}) is listed as a master")
    # In a multi-master situation, the master we look to will be the server with the highest fqdn
    node.default['et_ntp']['master'] = node['fqdn'] if node['fqdn'] > node['et_ntp']['master']

    # However, If one of the multiple masters is this node, then we will demote this node
    next unless master['fqdn'] == node['fqdn']

    log(
      "  > #{node['fqdn']} is the node that this chef client is currently running on." \
      "  > Demoting this node to a standby node\n"
    )

    # remove the ntp_master tag from this node
    tags = node['tags']
    tags.delete node['et_ntp']['master_tag']
    node.normal['tags'] = tags.uniq
    # Ensure that the tag was removed.  If not then fail.
    if node['tags'].include? 'ntp_master'
      fail '  > You are overriding me! Please check your overrides for the et_ntp/master/enabled attribute'
    else
      log "  > Chef has demoted #{node['fqdn']} to a standby node\n"
    end
    # Add this server to our list of standbys and remove it from our list of masters
    standbys << node['fqdn']
    masters.delete node['fqdn']

    # If there is only 1 master remaining, then set that as the new master and break out of this loop
    next unless masters.length == 1

    node.default['et_ntp']['master'] = masters.first

    # We have a vaild master setup now do not continue
    break
  end
elsif masters.length == 1
  log 'Master is ' + masters.first
  node.default['et_ntp']['master'] = masters.first
else
  tags = node['tags']
  tags = [] if tags.nil?
  tags << 'ntp_master'
  node.normal['tags'] = tags.uniq

  node.default['et_ntp']['master'] = node['fqdn']
end

node.default['et_ntp']['standbys'] = standbys

log 'Node Discovery Done'
log node['tags'].inspect
log node['et_ntp']['master'].inspect
log node['et_ntp']['standbys'].inspect
