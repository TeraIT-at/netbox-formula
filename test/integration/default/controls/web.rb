control 'Web server' do
  title 'should be running and enabled'

  describe.one do
    describe service('apache2') do
      it { should be_enabled }
      it { should be_running }
    end

    describe service('nginx') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
