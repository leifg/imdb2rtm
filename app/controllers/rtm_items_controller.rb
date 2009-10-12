require 'rtmapi'
require 'rubygems'
require 'yaml'
require 'imdb2rtm_command'

class RtmItemsController < ApplicationController
  
  RememberTheMilkHash.strict_keys = false
  
  def index
    @rtm = getRtmInstance
    uri = @rtm.auth_url 
    
    if !params[:frob]
      redirect_to uri
    else
      begin
        token = @rtm.auth.getToken(:frob => params[:frob])
        session[:rtm_auth_token] = token
        
        @authenticated = true
        
        @rtm.auth_token = token.token
        @lists = @rtm.lists.getList
                
        @list_names = Array.new
        
        @lists.each { |id, data| @list_names << [data[:name], id] }
        @list_names.sort!
        
      rescue RememberTheMilkAPIError => autherror
        puts autherror
        @authenticated = false
      end
    end
  end
  
  def show
    
    if params and params[:lists] and params[:lists][:selected]
      @authenticated = true
      selected_list_id = params[:lists][:selected]
      
      session[:task_changes] = Imdb2RtmCommand.new(getRtmInstance(session[:rtm_auth_token]), selected_list_id).do
    end
    
    puts @lists
  end
  
  def undo
    task_changes = session[:task_changes]
    
    Imdb2RtmCommand.new(getRtmInstance(session[:rtm_auth_token]), nil, task_changes).undo
  end
  
end
