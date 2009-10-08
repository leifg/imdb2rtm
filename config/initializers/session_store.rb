# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_imdb2rtm_session',
  :secret      => 'fe9c7b32ecde0aeaa54bd405b0a709c1f8c53173a3676771626824d2cc3c13e1722ebbb6617d3c028215237ad74cdee944bf28b5c06f0592e35d56d1a7e972f3'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
