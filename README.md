# Grid::Proxy

Simple utility for validating grid proxy.

## Installation

Add this line to your application's Gemfile:

    gem 'grid-proxy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grid-proxy

## Usage

```ruby
require 'grid-proxy'

# Username prefix is used to find correct user name.
# For example in PlGrid infrastructure all users have 'plg' prefix
# and this value is the default.
proxy = GP::Proxy(proxy_payload, username_prefix)

# throws GP::ProxyValidationError with message describing failure, 
# when proxy is not valid. `path_to_crl_file` is optional
proxy.verify!(ca_crt_payload, path_to_crl_file) 

# `true` if proxy is valid, false otherwise.
proxy.valid?(ca_crt_payload, path_to_crl_file)

# Get proxy elements
proxy.proxycert
proxy.proxykey
proxy.usercert

# Get user name basing on given prefix
proxy.username
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
