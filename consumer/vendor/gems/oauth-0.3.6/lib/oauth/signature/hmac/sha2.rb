require 'oauth/signature/hmac/base'
require "openssl"

module OAuth::Signature::HMAC
  class SHA2 < Base
    implements 'hmac-sha2'

    private

    def digest
      digest = OpenSSL::Digest::Digest.new('sha2')
      hmac = OpenSSL::HMAC.digest(digest, secret, signature_base_string)
    end
  end
end
