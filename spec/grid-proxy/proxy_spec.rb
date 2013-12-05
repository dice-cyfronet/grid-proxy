require 'spec_helper'

describe GP::Proxy do
  include CrtHelpers

  subject { GP::Proxy.new proxy_payload }

  let(:simple_ca) { load_cert 'simple_ca.crt' }

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
          subject.verify! simple_ca
        end
      end

      context 'and user cert is not signed by ca' do
        let(:polish_grid_ca) { load_cert('other_ca.crt') }

        it 'throws usercert not signed with trusted certificate' do
          expect {
            subject.verify! polish_grid_ca
          }.to raise_error(GP::ProxyValidationError, 'Usercert not signed with trusted certificate')
        end
      end

      context 'and proxy is signed by other user cert' do
        subject { GP::Proxy.new(load_cert 'proxy_and_differnt_user_cert') }

        it 'throws proxy not signed with user certificate' do
          expect {
            subject.verify! simple_ca
          }.to raise_error(GP::ProxyValidationError, 'Proxy not signed with user certificate')
        end
      end

      context 'and proxy subject does not begin with the issuer' do
        subject { GP::Proxy.new load_cert('wrong_subject') }

        it 'throws proxy subject must begin with the issuer' do
          expect {
            subject.verify! simple_ca
          }.to raise_error(GP::ProxyValidationError, 'Proxy subject must begin with the issuer')
        end
      end

      context 'and proxy is not actual proxy ("/CN=" not in subject difference")' do
        subject { GP::Proxy.new load_cert('no_proxy') }
        #  raise "Proxy error: Couldn't find '/CN=' in DN, not a proxy." if !proxycert.subject.to_s.include?('/CN=')
        it "throws couldn't find '/CN=' in DN, not a proxy" do
          expect_validation_error("Couldn't find '/CN=' in DN, not a proxy")
        end
      end

      context 'and proxy is signed by other user cert' do
        subject { GP::Proxy.new load_cert('wrong_issuer') }

        it 'throws proxy and user cert mismatch' do
          expect {
            subject.verify! simple_ca
          }.to raise_error(GP::ProxyValidationError, 'Proxy and user cert mismatch')
        end
      end
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

  describe '#username' do
    it 'returns username from proxy subject' do
      expect(subject.username).to eq 'plgkasztelnik'
    end
  end
end