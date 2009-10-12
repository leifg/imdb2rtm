# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  @@app_config = YAML::load_file('config/rtm.yml')
  
  @@api_key = @@app_config['api_key']
  @@shared_secret = @@app_config['shared_secret']

  def getRtmInstance(auth_token = nil)
    rtm = RememberTheMilk.new(@@api_key, @@shared_secret, 'https://www.rememberthemilk.com/services/rest/')
    
    if (auth_token != nil)
      rtm.auth_token = auth_token.token
    end
    
    return rtm
  end

end
