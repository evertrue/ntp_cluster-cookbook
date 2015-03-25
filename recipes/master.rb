include_recipe 'apt'
include_recipe 'et_ntp::discover'

node.set['ntp']['peers'] = node['et_ntp']['pool'] unless node['et_ntp']['pool'].empty?

restrictions = []

node['network']['interfaces'].each do |_interface, config|
  config['addresses'].each do |address, details|
    if details['family'] == 'inet'
      restrictions << "#{address} mask #{details['netmask']} nomodify notrap"
    elsif details['family'] == 'inet6'
      restrictions << "-6 #{address} mask #{details['netmask']} nomodify notrap"
    end
  end
end

node.set['ntp']['restrictions'] = node['ntp']['restrictions'].concat(restrictions)

include_recipe 'ntp::default'
