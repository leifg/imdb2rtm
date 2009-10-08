require File.dirname(__FILE__) + '/../test_helper.rb'
require "test/unit"
require "flexmock/test_unit"

class IMDB_2_RTM_Test < Test::Unit::TestCase
  
  def setup
    @save_mock = flexmock("savemock", :title => nil, :rating => nil, :length => nil)
    @start_rtm_item = nil
  end
  
  def test_correct_title
    movie_name = 'Fight Club'
    movie_rating = 8.
    
    imdb_mock = flexmock(@save_mock)
    imdb_mock.should_receive(:title).and_return(movie_name + " (1999)")
    imdb_mock.should_receive(:rating).and_return(movie_rating)
    
    i2r_item = Imdb_2_Rtm_Item.new(@start_rtm_item, imdb_mock)
    
    assert_equal(movie_name + " (" + movie_rating.to_s + ")", i2r_item.changed_task_name)
  end
  
  def test_correct_duration
    
    duration = 139
    
    imdb_mock = flexmock(@save_mock)
    imdb_mock.should_receive(:length).and_return(duration)
    
    i2r_item = Imdb_2_Rtm_Item.new(@start_rtm_item, imdb_mock)
    
    assert_equal(duration.to_s + " min", i2r_item.duration)
  end
  
  def test_correct_url
    url = "http://www.imdb.com/title/tt0137523/"
    
    imdb_mock = flexmock(@save_mock)
    imdb_mock.should_receive(:url).and_return(url)
    
    i2r_item = Imdb_2_Rtm_Item.new(@start_rtm_item, imdb_mock)
    
    assert_equal(url, i2r_item.url)
  end
  
end