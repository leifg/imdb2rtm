require 'imdb2rtm_item'
require 'unique_array'

class Imdb2RtmCommand
  
  #This class is responsible for executing the imdb2rtm algorithm on a specific list
  #therefore a rtm_instance and a list name is passed to the class
  
  def initialize(rtm_instance, list_id, task_changes = nil)
    @rtm_instance = rtm_instance
    @list_id = list_id
    @task_changes = task_changes
  end
  
  def do    
    if (@rtm_instance != nil)
      todo_items = @rtm_instance.tasks.getList(:list_id => @list_id, :filter => "status:incomplete")
      
      timeline = @rtm_instance.timelines.create
      task_changes = Array.new
      
      todo_items.each_value { |item| 
          current_task_change = Imdb2RtmItem.new(@rtm_instance, item).save(timeline)
          task_changes << current_task_change unless current_task_change == nil
      }
      
      #TODO better management of timeline
      {timeline => task_changes}
    end
  end
  
  def undo
    if (@task_changes != nil)
      
      all_transactions = UniqueArray.new
      
      timeline = ""
      
      @task_changes.each_key { |key| timeline = key }
      
      #TODO look deeper into that...
      @task_changes[timeline].each { |task_change| 
        
        task_change.transaction_ids.each { |transaction_id| all_transactions << transaction_id}
        
      } unless @task_changes == nil
      
      all_transactions.each { |transaction| @rtm_instance.transactions.undo(:timeline => timeline, :transaction_id => transaction)  }
    end
  
  end
  
end