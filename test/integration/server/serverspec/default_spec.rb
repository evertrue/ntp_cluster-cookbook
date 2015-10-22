require 'spec_helper'

describe 'ntp_cluster::server' do
  context 'installs /etc/ntp.conf' do
    describe file '/etc/ntp.conf' do
      its(:content) { is_expected.to match(/^server _default-ntp-1b\.priv\.evertrue\.com/) }
      its(:content) { is_expected.to_not match(/^server [^_]/) }
      its(:content) { is_expected.to match(/^peer _default-ntp-1c\.priv\.evertrue\.com/) }
      its(:content) { is_expected.to match(/^peer _default-ntp-1d\.priv\.evertrue\.com/) }
      its(:content) { is_expected.to_not match(/^peer [^_]/) }
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
      its(:content) { is_expected.to match(/\*_default-ntp-1b\.priv\.evertrue\.com/) }
      its(:content) { is_expected.to match(/\(\\\+|\\\#\)_default-ntp-1c\.priv\.evertrue\.com/) }
      its(:content) { is_expected.to match(/\(\\\+|\\\#\)_default-ntp-1d\.priv\.evertrue\.com/) }
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
