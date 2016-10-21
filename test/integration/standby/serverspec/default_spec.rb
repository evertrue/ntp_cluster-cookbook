require 'spec_helper'

describe 'ntp_cluster::default' do
  context 'installs /etc/ntp.conf' do
    describe file '/etc/ntp.conf' do
      ip_address = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
      netmask =
        Socket.getifaddrs.find { |intf| intf.name == 'eth0' && intf.addr.ipv4? }.netmask.ip_address
      ip6_address =
        Socket.ip_address_list.detect{|intf| intf.ipv6_linklocal?}.ip_address.sub('%eth0','')
      its(:content) { is_expected.to match(/^server 46\.22\.26\.12/) }
      its(:content) { is_expected.to match(/^peer 89\.188\.26\.129/) }
      its(:content) { is_expected.to match(/^peer 92\.63\.212\.161/) }
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

  context 'should have the ntpcheck script' do
    describe file '/usr/bin/ntpcheck' do
      its(:content) { is_expected.to match(/\(\\\+|\\\#\)|\\\*\)46\.22\.26\.12/) }
      its(:content) { is_expected.to match(/\(\\\+|\\\#\)|\\\*\)89\.188\.26\.129/) }
      its(:content) { is_expected.to match(/\(\\\+|\\\#\)|\\\*\)92\.63\.212\.161/) }
    end

    describe command '/usr/bin/ntpcheck' do
      its(:exit_status) { is_expected.to be 0 }
    end
  end

  context 'should have the monitor cron job' do
    describe file '/etc/cron.d/ntpcheck' do
      its(:content) do
        is_expected.to include(
          "* * * * * root bash -c 'echo begin; ( /usr/bin/ntpcheck && echo success ) " \
          "|| echo fail' | logger -t ntpcheck -p cron.info"
        )
      end
    end
  end
end
