# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_provider_session',
  :secret      => '94e916ba4584cd86280d1960bbe05e708d8e0c591fd5993c67855909d017e1915102a8739938351df5ddc75471914bd6fb73a4bf181ae9d2a054b0de5b4c4b71'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
