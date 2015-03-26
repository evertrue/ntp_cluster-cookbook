
template "#{node['et_ntp']['monitor']['install_dir']}/ntpcheck" do
  source 'ntpcheck.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

command = "#{node['et_ntp']['monitor']['run']}; " \
          "( #{node['et_ntp']['monitor']['install_dir']} && #{node['et_ntp']['monitor']['complete']} ) " \
          "|| #{node['et_ntp']['monitor']['fail']}"

cron 'ping the an endpoint if there is a problem' do
  hour '*'
  minute '*/5'
  command command
end
