require 'oauth/signature/hmac/base'
require "openssl"

module OAuth::Signature::HMAC
  class MD5 < Base
    implements 'hmac-md5'

    private

    def digest
      digest = OpenSSL::Digest::Digest.new('md5')
      hmac = OpenSSL::HMAC.digest(digest, secret, signature_base_string)
    end
  end
end
