require 'rtmapi'
require 'rubygems'

class Imdb2RtmItem
  
  attr_accessor :imdb_item
  attr_reader :changed_task_name, :duration, :url
  
  def initialize(rtm_instance, rtm_task, imdb_obj=nil)
    
    if rtm_instance == nil or rtm_task == nil
      raise ArgumentError, "RTM instance (#{rtm_instance}) or RTM Task (#{rtm_task}) is nil"
    end
    
    @rtm_instance = rtm_instance
    @rtm_task = rtm_task
    
    if (imdb_obj)
      @imdb_item = imdb_obj
    else
      @imdb_item = Imdb::Search.new(@rtm_task.name).movies.first
    end
    
    if @imdb_item != nil
      @duration = @imdb_item.length.to_s + " min"
    end
    
  end
  
  # if no search result is found (@imdb_item is nil) or the title already contains a rating (contains [number.number])
  def already_changed
    @imdb_item == nil or /\[\d\.\d\]/.match @rtm_task.name
  end
  
  # remove the year in the title (e.g. "Fight Club (1999)" => "Fight Club")
  # also the numbering after the year is removes (so far until 5 (V)
  # see http://www.imdb.com/help/show_leaf?titleformat for infomration about title numbering
  def generate_movie_title(title)
    if title != nil
      title.strip!
      title.gsub! /\(\d{4}(\/.*)?\)/, ''
      title.strip!
      title += " [" + @imdb_item.rating.to_s + "]"
    end
  end
  
  def save(timeline=nil)
    
    if already_changed
      return nil
    end
    
    if (timeline == nil)
      timeline = @rtm_instance.timelines.create
    end
    
    base_argumens = {:timeline => timeline, :list_id => @rtm_task.list_id, :taskseries_id => @rtm_task.taskseries_id, :task_id => @rtm_task.task_id}
    
    class << base_argumens
      def +(add)
        temp = {}
        add.each{|k,v| temp[k] = v}
        self.each{|k,v| temp[k] = v}
        temp
      end
    end
    
    edited_tasks = Array.new
    
    edited_tasks << @rtm_instance.tasks.setName(base_argumens + {:name => generate_movie_title(@imdb_item.title)})
    edited_tasks << @rtm_instance.tasks.setURL(base_argumens + {:url => url})
    edited_tasks << @rtm_instance.tasks.setEstimate(base_argumens + {:estimate => @duration})
    
    TaskChange.new(timeline, edited_tasks)
  end
  
end