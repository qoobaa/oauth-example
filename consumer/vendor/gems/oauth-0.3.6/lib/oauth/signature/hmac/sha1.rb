require 'oauth/signature/hmac/base'
require "openssl"

module OAuth::Signature::HMAC
  class SHA1 < Base
    implements 'hmac-sha1'

    private

    def digest
      digest = OpenSSL::Digest::Digest.new('sha1')
      hmac = OpenSSL::HMAC.digest(digest, secret, signature_base_string)
    end
  end
end
