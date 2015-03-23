require 'spec_helper'

describe 'et_ntp::default' do
  context 'installs /etc/ntp.conf' do
    describe file '/etc/ntp.conf' do
      its(:content) { is_expected.to match(/restrict/) }
    end
  end

  context 'should listen on port 123' do
    describe port 123 do
      it { is_expected.to be_listening.on('127.0.0.1').with('udp') }
      it { is_expected.to be_listening.on(host_inventory['ipaddress']).with('udp') }
    end
  end
end
