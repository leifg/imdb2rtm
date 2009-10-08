class Imdb2Rtm_Command
  
  #This class is responsible for executing the imdb2rtm algorithm on a specific list
  #therefore a rtm_instance and a list name is passed to the class
  
  def initialize(rtm_instance, list_name)
    @rtm_instance = rtm_instance
    @list_name = list_name
  end
  
  def do
    if (@rtm_instance != nil)
      #create timeline
      timeline = @rtm_instance.timeline.create
      
      # TODO fetch list_id from list_name 
            
      list_id = nil
      
      #fetch all todo-items of list
      
      #change all todo items and save to list
    end
  end
  
  def undo
    #
  end
  
end