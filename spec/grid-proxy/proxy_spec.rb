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

  describe '#verify!' do
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
          expect_validation_error('Usercert not signed with trusted certificate', polish_grid_ca)
        end
      end

      context 'and proxy is signed by other user cert' do
        subject { GP::Proxy.new(load_cert 'proxy_and_differnt_user_cert') }

        it 'throws proxy not signed with user certificate' do
          expect_validation_error('Proxy not signed with user certificate', simple_ca)
        end
      end

      context 'and proxy subject does not begin with the issuer' do
        subject { GP::Proxy.new load_cert('wrong_subject') }

        it 'throws proxy subject must begin with the issuer' do
          expect_validation_error('Proxy subject must begin with the issuer', simple_ca)
        end
      end

      context 'and proxy is not actual proxy ("/CN=" not in subject difference")' do
        subject { GP::Proxy.new load_cert('no_proxy') }
        it "throws couldn't find '/CN=' in DN, not a proxy" do
          expect_validation_error("Couldn't find '/CN=' in DN, not a proxy", simple_ca)
        end
      end

      context 'and proxy is signed by other user cert' do
        subject { GP::Proxy.new load_cert('wrong_issuer') }

        it 'throws proxy and user cert mismatch' do
          expect_validation_error('Proxy and user cert mismatch', simple_ca)
        end
      end
    end

    context 'when it is to early' do
      before do
        Time.stub(:now).and_return(Time.new(2013, 12, 3, 12, 0, 0, "+01:00"))
      end

      it 'throws proxy is not valid yet' do
        expect_validation_error('Proxy is not valid yet', simple_ca)
      end
    end

    context 'when it is to late' do
      before do
        Time.stub(:now).and_return(Time.new(2013, 12, 5, 12, 0, 0, "+01:00"))
      end

      it 'throws proxy expired' do
        expect_validation_error('Proxy expired', simple_ca)
      end
    end

    context 'with invalid proxy key' do
      before do
        Time.stub(:now).and_return(Time.new(2013, 12, 4, 12, 0, 0, "+01:00"))
      end

      context 'when private key does not exist' do
        subject { GP::Proxy.new(load_cert('without_private_key')) }

        it 'throws missing proxy private key' do
          expect_validation_error('Private proxy key missing', simple_ca)
        end
      end

      context 'when cert and private key does not match' do
        subject { GP::Proxy.new(load_cert('cert_and_key_mismatch')) }
        it 'throws private key and cert mismatch' do
          expect_validation_error('Private proxy key and cert mismatch', simple_ca)
        end
      end
    end
  end

  describe '#valid?' do
    context 'when proxy is valid' do
      before do
        Time.stub(:now).and_return(Time.new(2013, 12, 4, 12, 0, 0, "+01:00"))
      end

      it 'returns true' do
        expect(subject.valid? simple_ca).to eq true
      end
    end

    context 'when proxy is not valid' do
      it 'returns false' do
        expect(subject.valid? simple_ca).to eq false
      end
    end
  end

  describe '#username' do
    it 'returns username from proxy subject' do
      expect(subject.username).to eq 'plgkasztelnik'
    end
  end

  describe '#proxy_payload' do
    it 'returns proxy payload' do
      expect(subject.proxy_payload).to eq proxy_payload
    end
  end
end