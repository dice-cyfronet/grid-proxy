module GP
  class Proxy
    CERT_START = '-----BEGIN CERTIFICATE-----'

    def initialize(proxy_payload)
      @proxy_payload = proxy_payload
    end

    def proxycert
      @proxycert ||= cert_for_element(1)
    end

    def usercert
      @usercert ||= cert_for_element(2)
    end

    def verify!(ca_cert_payload)
      now = Time.now
      raise GP::ProxyValidationError.new('Proxy is not valid yet') if now < proxycert.not_before
      raise GP::ProxyValidationError.new('Proxy expired') if now > proxycert.not_after
      raise GP::ProxyValidationError.new('Usercert not signed with trusted certificate') unless ca_cert_payload && usercert.verify(cert(ca_cert_payload).public_key)
      raise GP::ProxyValidationError.new('Proxy not signed with user certificate') unless proxycert.verify(usercert.public_key)
    end

    private

    def cert_for_element(element_nr)
      cert "#{CERT_START}#{@proxy_payload.split(CERT_START)[element_nr]}"
    end

    def cert(payload)
      OpenSSL::X509::Certificate.new payload
    end
  end
end