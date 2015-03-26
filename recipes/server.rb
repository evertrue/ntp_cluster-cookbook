restrictions = []

# Open up the interfaces to the network
node['network']['interfaces'].each do |_interface, config|
  config['addresses'].each do |address, details|
    if details['family'] == 'inet'
      restrictions << "#{address} mask #{details['netmask']} nomodify notrap"
    elsif details['family'] == 'inet6'
      restrictions << "-6 #{address} mask #{details['netmask']} nomodify notrap"
    end
  end
end

node.set['ntp']['restrictions'] = node['ntp']['restrictions'].concat(restrictions).uniq

include_recipe 'et_ntp::monitor' if node['et_ntp']['monitor']['enabled']
