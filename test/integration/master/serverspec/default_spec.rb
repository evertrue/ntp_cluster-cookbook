require 'spec_helper'

describe 'ntp_cluster::default' do
  context 'installs /etc/ntp.conf' do
    describe file '/etc/ntp.conf' do
      ip_address = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
      netmask =
        Socket.getifaddrs.find { |intf| intf.name == 'eth0' && intf.addr.ipv4? }.netmask.ip_address
      ip6_address =
        Socket.ip_address_list.detect{|intf| intf.ipv6_linklocal?}.ip_address.sub('%eth0','')
      its(:content) { is_expected.to match(/^server 0\.pool\.ntp\.org/) }
      its(:content) { is_expected.to match(/^server 1\.pool\.ntp\.org/) }
      its(:content) { is_expected.to match(/^server 2\.pool\.ntp\.org/) }
      its(:content) { is_expected.to match(/^server 3\.pool\.ntp\.org/) }
      its(:content) { is_expected.to_not match(/^peer/) }
      its(:content) { is_expected.to contain "restrict default kod notrap nomodify nopeer noquery
restrict 127.0.0.1
restrict -6 default kod notrap nomodify nopeer noquery
restrict -6 ::1

restrict 127.0.0.1 mask 255.0.0.0 nomodify notrap
restrict -6 ::1 mask  nomodify notrap
restrict #{ip_address} mask #{netmask} nomodify notrap
restrict -6 #{ip6_address} mask  nomodify notrap" }
    end
  end

  context 'should listen on port 123' do
    describe port 123 do
      it { is_expected.to be_listening.on('127.0.0.1').with('udp') }
      it { is_expected.to be_listening.on(host_inventory['ipaddress']).with('udp') }
    end
  end
end
