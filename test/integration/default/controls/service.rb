control 'Netbox services' do
  title 'should be running and enabled'

  describe service('netbox') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('netbox-rq') do
    it { should be_enabled }
    it { should be_running }
  end
end
