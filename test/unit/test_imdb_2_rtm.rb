require File.dirname(__FILE__) + '/../test_helper.rb'
require "test/unit"
require "flexmock/test_unit"

class IMDB_2_RTM_Test < Test::Unit::TestCase
  
  def setup
    @save_mock = flexmock("save_mock", :title => nil, :rating => nil, :length => nil)
    @rtm_transaction_mock = flexmock("rtm_transaction_mock", :id => "123")
    @rtm_task_mock = flexmock("rtm_task_mock", :name => nil, :list_id => nil, :taskseries_id => nil, :task_id => nil, :rtm_transaction => @rtm_transaction_mock)
    @rtm_ns_mock = flexmock("rtm_ns_mock", :setName => @rtm_task_mock, :setEstimate => @rtm_task_mock, :setURL => @rtm_task_mock)
    @rtm_mock = flexmock("rtm_mock", :tasks => @rtm_ns_mock)

  end
  
  def test_correct_title
    movie_name = 'Fight Club'
    movie_rating = 8.8
    
    imdb_mock = flexmock(@save_mock)
    imdb_mock.should_receive(:rating).and_return(movie_rating)
    
    assert_equal(movie_name + " [" + movie_rating.to_s + "]", Imdb2RtmItem.new(@rtm_mock, @rtm_task_mock, imdb_mock).generate_movie_title(movie_name + " (1999)    "))
  end
  
  def test_correct_title_with_numbering
    movie_name = 'Twilight'
    movie_rating = 8.7
    
    imdb_mock = flexmock(@save_mock)
    imdb_mock.should_receive(:rating).and_return(movie_rating)
    
    assert_equal(movie_name + " [" + movie_rating.to_s + "]", Imdb2RtmItem.new(@rtm_mock, @rtm_task_mock, imdb_mock).generate_movie_title(movie_name + " (2008/IV)    "))
  end
  
  def test_correct_title_without_year
    movie_name = 'Choke'
    movie_rating = 6.7
    
    imdb_mock = flexmock(@save_mock)
    imdb_mock.should_receive(:rating).and_return(movie_rating)
    
    assert_equal(movie_name + " [" + movie_rating.to_s + "]", Imdb2RtmItem.new(@rtm_mock, @rtm_task_mock, imdb_mock).generate_movie_title(movie_name))
  end
  
  def test_correct_title_with_braces
    movie_name = 'Take the long road (and walk it)'
    movie_rating = 3.6
    
    imdb_mock = flexmock(@save_mock)
    imdb_mock.should_receive(:rating).and_return(movie_rating)
    
    assert_equal(movie_name + " [" + movie_rating.to_s + "]", Imdb2RtmItem.new(@rtm_mock, @rtm_task_mock, imdb_mock).generate_movie_title(movie_name + " (1963/IV)    "))
  end
  
  def test_correct_duration
    duration = 139
    
    imdb_mock = flexmock(@save_mock)
    imdb_mock.should_receive(:length).and_return(duration)
    
    i2r_item = Imdb2RtmItem.new(@rtm_mock, @rtm_task_mock, imdb_mock)
    
    assert_equal(duration.to_s + " min", i2r_item.duration)
  end
  
  def test_correct_return_nil
    i2r_item = flexmock(Imdb2RtmItem.new(@rtm_mock, @rtm_task_mock, @save_mock))
    i2r_item.should_receive(:already_changed).and_return(true)
    
    assert_equal(nil, i2r_item.save("123"))
  end
  
  def test_correct_return_array
    i2r_item = flexmock(Imdb2RtmItem.new(@rtm_mock, @rtm_task_mock, @save_mock))
    i2r_item.should_receive(:already_changed).and_return(false)
    
    returnval = i2r_item.save("123")
    
    assert_equal(TaskChange, returnval.class)
  end
  
end