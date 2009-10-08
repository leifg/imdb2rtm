require 'rtmapi'
require 'rubygems'

class Imdb_2_Rtm_Item

attr_accessor :imdb_item
attr_reader :changed_task_name, :duration, :url

def initialize(rtm_task, imdb_obj=nil)

  @rtm_task = rtm_task

   if (imdb_obj)
      @imdb_item = imdb_obj
   else
      @imdb_item = Imdb::Search.new(rtm_task.name).movies.first
   end

  if @imdb_item != nil
      @changed_task_name = generate_movie_title(@imdb_item.title, @imdb_item.rating)
      @duration = @imdb_item.length.to_s + " min"
  end
  
end

def generate_movie_title(title, rating)
  if title != nil
    title = title.strip
    title[title.length-6..title.length] = "" unless title.length < 6
    title = title.strip
    title += " (" + @imdb_item.rating.to_s + ")"
  end
end

def save
  @changed_rtm_task = @rtm_task.setName(@changed_task_name).setUrl(@imdb_item.url).setEstimate(@duration).setUrl(url)
end

def url
  @imdb_item.url rescue nil
end

end