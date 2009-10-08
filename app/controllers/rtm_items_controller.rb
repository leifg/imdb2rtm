require 'rtmapi'
require 'rubygems'
require 'yaml'

class RtmItemsController < ApplicationController
  
  @@app_config = YAML::load_file('config/rtm.yml')
  
  @@api_key = @@app_config['api_key']
  @@shared_secret = @@app_config['shared_secret']
  
  def index
    @rtm = RememberTheMilk.new(@@api_key, @@shared_secret)
   
    uri = @rtm.auth_url 
    
  if !params[:frob]
    redirect_to uri
    else
      begin
        token = @rtm.auth.getToken(:frob => params[:frob])
        @rtm.auth.checkToken(:auth_token => token.token)
        @authenticated = true
        
        @rtm.auth_token =  token.token
        @lists = @rtm.lists.getList
        
        @list_names = Array.new
        @lists.each { |id, data| @list_names << [data[:name], id] }
        
      rescue RememberTheMilkAPIError => autherror
        puts autherror
        @authenticated = false
      end
    end
  end
  
  def show
    res = RTM::Auth::GetToken.new(@frob).invoke
    @token = res[:token]
    lists = RTM::Lists::GetList.new(token).invoke
    lists.each { |l| puts l.name } 
  end

end
