require 'spec_helper'

describe GP::Proxy do
  include CrtHelpers

  subject { GP::Proxy.new(proxy_payload) }

  let(:simple_ca) { load_cert('simple_ca.crt') }

  it 'loads proxy' do
    expect(subject.proxycert).to be_an_instance_of OpenSSL::X509::Certificate
  end

  it 'loads user cert' do
    expect(subject.usercert).to be_an_instance_of OpenSSL::X509::Certificate
  end

  describe '#verify' do
    context 'when time is ok' do
      before do
        Time.stub(:now).and_return(Time.new(2013, 12, 4, 12, 0, 0, "+01:00"))
      end

      context 'and user cert is signed by ca' do
        it 'does not throw any exception - proxy is verify' do
          subject.verify!(simple_ca)
        end
      end

      context 'and user cert is not signed by ca' do
        let(:polish_grid_ca) { load_cert('other_ca.crt') }

        it 'throws usercert not signed with trusted certificate' do
          expect {
            subject.verify!(polish_grid_ca)
          }.to raise_error(GP::ProxyValidationError, 'Usercert not signed with trusted certificate')
        end
      end

      context 'and proxy is signed by other user cert' do
        subject { GP::Proxy.new(load_cert 'proxy_and_differnt_user_cert.crt') }

        it 'throws proxy not signed with user certificate' do
          expect {
            subject.verify!(simple_ca)
          }.to raise_error(GP::ProxyValidationError, 'Proxy not signed with user certificate')
        end
      end

      context 'and proxy subject does not begin with the issuer' do
        #  raise "Proxy error: Proxy subject must begin with the issuer." if proxycert.subject.to_s.index(proxycert.issuer.to_s) != 0
      end

      context 'and proxy is not actual proxy ("/CN=" not in subject difference")' do
        #  raise "Proxy error: Couldn't find '/CN=' in DN, not a proxy." if !proxycert.subject.to_s.include?('/CN=')
      end

      context 'and proxy is signed by other user cert' do
        #  raise "Proxy error: Proxy and user cert missmatch." if proxycert.issuer.to_s != usercert.subject.to_s
      end

      #  raise "Proxy error: Shortened DN not permited." if proxycert.issuer.to_s.length > proxycert.subject.to_s.length
    end

    context 'when it is to early' do
      before do
        Time.stub(:now).and_return(Time.new(2013, 12, 3, 12, 0, 0, "+01:00"))
      end

      it 'throws proxy is not valid yet' do
        expect {
          subject.verify!(simple_ca)
        }.to raise_error(GP::ProxyValidationError, 'Proxy is not valid yet')
      end
    end

    context 'when it is to late' do
      before do
        Time.stub(:now).and_return(Time.new(2013, 12, 5, 12, 0, 0, "+01:00"))
      end

      it 'throws proxy expired' do
        expect {
          subject.verify!(simple_ca)
        }.to raise_error(GP::ProxyValidationError, 'Proxy expired')
      end
    end
  end
end