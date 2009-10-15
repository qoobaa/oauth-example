require 'oauth/signature/hmac/base'
require "openssl"

module OAuth::Signature::HMAC
  class RMD160 < Base
    implements 'hmac-rmd160'

    private

    def digest
      digest = OpenSSL::Digest::Digest.new('rmd160')
      hmac = OpenSSL::HMAC.digest(digest, secret, signature_base_string)
    end
  end
end
