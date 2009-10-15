# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_consumer_session',
  :secret      => 'c8467483f0af29a4f17dae0059d6d0e178d7a8c627e8b37b8c91c03b076b21f81fffeda27d3305ff84a4bc32efc7e499211ee21d861d06df5750e3d4e097a05b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
