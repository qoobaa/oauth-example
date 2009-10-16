class User < ActiveRecord::Base
  validates_presence_of :login
  validates_uniqueness_of :login

  has_many :cv_tokens

  def self.find_or_create_by_cv_token(cv_token)
    response = cv_token.client.get("http://localhost:3000/account.json")
    if (200...300).include?(response.code)
      user_attributes = JSON.parse(response.body)["user"]
      if user_attributes
        user = find_or_create_by_login(user_attributes["login"])
        user.name = user_attributes["name"]
        user.cv_tokens << cv_token
        user
      end
    end
  end
end
