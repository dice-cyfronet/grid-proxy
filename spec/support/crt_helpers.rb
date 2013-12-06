module CrtHelpers
  def proxy_payload
    @proxy_payload ||= load_cert('valid_proxy')
  end

  def load_cert(cert_name)
    File.read File.join(File.dirname(__FILE__), '..', 'certs', cert_name)
  end

  def expect_validation_error(error_msg, ca)
    expect {
      subject.verify! ca
    }.to raise_error(GP::ProxyValidationError, error_msg)
  end
end