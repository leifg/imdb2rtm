#!/usr/bin/env ruby
# This file is part of the RTM Ruby API Wrapper.
#  
# The RTM Ruby API Wrapper is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.  
# 
# The RTM Ruby API Wrapper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#                                  
# You should have received a copy of the GNU General Public License
# along with the RTM Ruby API Wrapper; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
# (c) 2006, QuantumFoam.org, Inc.

require File.dirname(__FILE__) + '/../test_helper.rb'
require 'rubygems'

if File.exists?('lib/rtmapi.rb')
  puts "Running with local version of rtmapi"
  require 'lib/rtmapi'
else
  puts "Running with gem version of rtmapi"
  require 'rtmapi'
end
require 'test/unit'

class RememberTheMilkTester < RememberTheMilk

  # let's cache the data we get from RTM
  def call_api_method( method, args={} )
    caller.find {|frame| frame =~ /test-rtmapi.rb:\d+:in .*\`(.*)\'/}
    calling_test = $1
    @test_hash ||= {}
    @test_hash[calling_test] ||= 0
    @test_hash[calling_test] += 1
    
    # if we're running as a gem, figure out where the test data might be
    if !defined?(@basedir)
      @basedir = '.'
      new_base = $:.find {|path| path =~ /gems\/rtmapi-[\d\.]+\/lib/ }
      if new_base
        new_base =~ /^(.*)\/lib$/
        @basedir = "#{$1}/test"
      end
    end
    
    filename = "#{@basedir}/data/#{calling_test}.#{@test_hash[calling_test]}.xml"

    if File.exists?(filename)
      # read from the cache
      args[:test_data] = File.open(filename).readlines.join
      debug('Grabbed data from %s: %s', filename, args[:test_data])
    else
      # write the data to the cache
      @return_raw_response = true
      response = super( method, args )
      @return_raw_response = false
      
      File.open( filename, "w" ) {|file| file.write(response)}
      args[:test_data] = response
    end

    super( method, args )
  end
end

class TestRememberTheMilk < Test::Unit::TestCase
 
  def setup
    @rtm = RememberTheMilkTester.new( 'not a real key', 'not a real secret key' )
    @auth_token = '5285bb669757daff7cde3793b2a60a5c258002cb'
    @rtm.auth_token = 'not a real token'
    @acct_name = 'Fifi TheCow'
    @InboxListId = '421862'
    @APITestListId = '431158' # "API Test List"
    @ReallyBadListId = '421865'
    @fake_pid = '666'
    @fake_nowtime = Time.parse("Thu Feb 01 13:50:36 EST 2007")
#    @rtm.debug = 1
  end

  def test_rtm_reflection_getMethods
    expected_methods = ['rtm.auth.checkToken', 'rtm.auth.getFrob', 
    'rtm.auth.getToken', 'rtm.contacts.add', 'rtm.contacts.delete', 
    'rtm.contacts.getList', 'rtm.groups.add', 'rtm.groups.addContact', 
    'rtm.groups.delete', 'rtm.groups.getList', 'rtm.groups.removeContact',
    'rtm.lists.add', 'rtm.lists.archive', 'rtm.lists.getList', 
    'rtm.lists.setDefaultList', 'rtm.lists.setName', 'rtm.lists.unarchive',
    'rtm.reflection.getMethodInfo', 'rtm.reflection.getMethods', 
    'rtm.settings.getList', 'rtm.tasks.add', 'rtm.tasks.addTags', 
    'rtm.tasks.complete', 'rtm.tasks.delete', 'rtm.tasks.getList', 
    'rtm.tasks.movePriority', 'rtm.tasks.moveTo', 'rtm.tasks.notes.add', 
    'rtm.tasks.notes.delete', 'rtm.tasks.notes.edit', 'rtm.tasks.postpone', 
    'rtm.tasks.removeTags', 'rtm.tasks.setDueDate', 'rtm.tasks.setEstimate', 
    'rtm.tasks.setName', 'rtm.tasks.setPriority', 'rtm.tasks.setRecurrence', 
    'rtm.tasks.setTags', 'rtm.tasks.setURL', 'rtm.tasks.uncomplete', 
    'rtm.test.echo', 'rtm.test.login', 'rtm.time.convert', 'rtm.time.parse', 
    'rtm.timelines.create', 'rtm.timezones.getList', 'rtm.transactions.undo']
  
    data = @rtm.reflection.getMethods()
    assert_equal Array, data.class
    if expected_methods.size != data.size
      # convert data to a hash
      h = {}
      expected_methods.each { |m| h[m] = true }
      data.each { |m| puts "new method<#{m}> in API" unless h[m] }

      h = {}
      data.each { |m| h[m] = true } 
      expected_methods.each { |m| puts "old method<#{m}> no longer in API" unless h[m] }
      
      # uncomment this line if you want to put a new expected methods array together
      #puts data.inspect
    end

    assert_equal expected_methods.size, data.size
  end
  
  def test_rtm_get_frob
    frob = @rtm.auth.getFrob()
    assert_equal String, frob.class
    assert_equal 40, frob.length
  end
  
  def test_rtm_settings_getList
    data = @rtm.settings.getList
    assert_equal nil, data.defaultlist
    assert_equal nil, data.timezone
    assert_equal '0', data.timeformat
    assert_equal '1', data.dateformat
  end
  
  def test_rtm_timezones_getList
    data = @rtm.timezones.getList
    assert_equal 388, data.keys.size
    assert_equal '0', data['Asia/Hong_Kong'].dst
    assert_equal '3600', data['Africa/Douala'].offset
  end
  
  def test_get_method_exceptions
    assert_raise(RememberTheMilkAPIError) { @rtm.foo.bar() }
    assert_nothing_raised() { @rtm.reflection.getMethods() }
    begin
      @rtm.foo.bar
      assert nil  # this should be unreachable
    rescue RememberTheMilkAPIError => rtm_err
      assert_equal 112, rtm_err.error_code
      assert_equal "Method \"rtm.foo.bar\" not found", rtm_err.error_message
    end
  end

  def test_rtm_test_echo
    response = nil
    # this also tests that the Ruby API coerces things to Strings...
    assert_nothing_raised() { response = @rtm.test.echo( :arg1 => 'value1', 
                                                         'arg2' => :value2, 
                                                         :arg3 => 666, 
                                                         'arg4' => '777') }
    assert_equal RememberTheMilkHash, response.class
    assert_equal 8, response.keys.size
    assert_equal @auth_token, response.auth_token
    assert_equal 'ok', response.stat
    assert_equal 'value1', response.arg1
    assert_equal 'value2', response.arg2
    assert_equal '666', response.arg3
    assert_equal '777', response.arg4
    assert_equal @rtm.api_key, response.api_key
    assert_equal 'rtm.test.echo', response[:method] # method is a ruby keyword
  end

  def test_rtm_time_parse
    date = @rtm.time_to_user_tz(@rtm.time.parse(:text => @fake_nowtime.to_s, :parse=>'true'))
    assert_equal Time, date.class
    assert_equal Time.parse("Thu Feb 01 13:50:00 UTC 2007"),date 
  end

  def test_rtm_user
    user = @rtm.user
    assert_equal @acct_name, user.fullname
  end

  def test_rtm_auth_checkToken_good
    @rtm.auth_token = nil
    data = @rtm.auth.checkToken( :auth_token => @auth_token )
    assert_equal RememberTheMilkHash, data.class
    assert_equal 'delete', data.perms
    assert_equal @auth_token, data.token
    assert_equal @acct_name, data.user.fullname
  end

  def test_rtm_auth_checkToken_bad
    assert_raise(RememberTheMilkAPIError) { @rtm.auth.checkToken( 'auth_token' => 'badtokenvalue' ) }
  end
  
  def test_rtm_contacts_getList
    data = @rtm.contacts.getList
    assert_equal Array, data.class
    assert_equal 2, data.size
    assert_equal 3, data[0].keys.size
    assert_equal 'foofoo.thecow', data[0].username  # 159979
    assert_equal 'barbar.thecow', data[1].username  # 159980
  end

  
  def test_rtm_tasks_getList_from_smartlist
#    @rtm.debug = 1
# This appears not to work with a smartlist, you have to request the actual
# list, not rely on all the lists you get back.
# see http://groups.google.com/group/rememberthemilk-api/browse_thread/thread/745a335461f9b731
#    data = @rtm.tasks.getList
#    missing_tags = data['426013']
    missing_tags = @rtm.tasks.getList( :list_id => '426013' )  # "Missing Tags"
    
    assert_equal RememberTheMilkHash, missing_tags.class
    assert_equal 4, missing_tags.keys.size
    assert_equal ["421862", "421863", "421866", @APITestListId], missing_tags.keys.sort

    missing_tags.keys.each do |k|
      missing_tags[k].values.each do |task|
        assert_equal [], task.tags
      end
    end
#    puts missing_tags.inspect
    # TODO-- figure out how to examine the returned data structure (i await
    #  more info on what it is)
  end

  def test_rtm_tasks_getList_all
    data = @rtm.tasks.getList
    assert_equal RememberTheMilkHash, data.class
    assert_equal 4, data[@APITestListId].keys.size
  end

  def test_rtm_tasks_getList
    list_id = @APITestListId
    data = @rtm.tasks.getList( :list_id => list_id )  
    assert_equal RememberTheMilkHash, data.class
    assert_equal 4, data.keys.size
    assert_equal "this is my first test task", data['782833'].name
    assert_equal "http://slashdot.org/", data['782833'].url
    assert data['782833'].participants
    assert_equal Array, data['782833'].participants.class
    assert_equal 2,  data['782833'].participants.size
    assert data['782833'].participants[1]
    assert_equal "BarBar thecow", data['782833'].participants[1].fullname
    assert_equal "2006-06-20T13:51:02Z", data['782838'].created
    assert_equal list_id, data['782838'].parent_list
    ## also test strict_keys class variable here...
    RememberTheMilkHash::strict_keys = false
    assert_nothing_raised      { data['782838'].this_is_not_a_valid_key }
    RememberTheMilkHash::strict_keys = true
    assert_raise(RuntimeError) { data['782838'].this_is_not_a_valid_key }
  end

  def test_rtm_tasks_getList_with_only_one_task
    list_id = "426012"
    data = @rtm.tasks.getList( :list_id => list_id )  
    assert_equal RememberTheMilkHash, data.class
    assert_equal 1, data.keys.size
    assert_equal "only one task in this list", data.values[0].name
  end

  def test_rtm_tasks_getList_empty
    list_id = "759197"
    data = @rtm.tasks.getList( :list_id => list_id )  
    assert_equal RememberTheMilkHash, data.class
    assert_equal 0, data.keys.size
  end


  def test_rtm_get_task_and_is_complete
    data = @rtm.tasks.getList( :list_id => '421865' )
    assert_equal RememberTheMilkHash, data.class
    assert_equal 2, data.keys.size
    assert data['1898821']
    assert !data['1898821'].completed
    assert data['1898823']
    assert data['1898823'].completed
  end
    
  def test_rtm_groups_getList
    data = @rtm.groups.getList()
    group_id = '8970'
    assert_equal RememberTheMilkHash, data.class
    assert_equal 1, data.keys.size
    assert_equal "RTM_API_Test", data[group_id].name
    assert_equal 2, data[group_id].contacts.size
    ['159979','159980'].each do |uid|
      found_id = 0
      data[group_id].contacts.each { |cid| found_id = cid if cid == uid }
      assert_equal uid, found_id
    end
  end
  
  
  def test_rtm_timelines_and_transactions_with_tags
    timeline = @rtm.timelines.create
    assert String, timeline.class
    list_id = @APITestListId
    tasks = @rtm.tasks.getList( 'list_id' => list_id )
    taskseries_id = '783144'
    assert_equal 'this is my tag test task', tasks[taskseries_id].name
    task_id = tasks[taskseries_id].tasks[0][:id]

    num_tags = tasks[taskseries_id].tags.size
    prefix = "tag#{num_tags}_"
    new_tags = [ prefix + 'foo123', prefix + 'bar123' ]
    
    edited_task = @rtm.tasks.addTags( 'timeline' => timeline, 'list_id' => list_id, 
                                      'taskseries_id' => taskseries_id, 'task_id' => task_id, 
                                      'tags' => new_tags.join(',') )

    assert_equal '1', edited_task.rtm_transaction.undoable

    mod_tasks = @rtm.tasks.getList( 'list_id' => list_id )

    assert_equal num_tags+new_tags.size, mod_tasks[taskseries_id].tags.size
    assert @rtm.transactions.undo( 'timeline' => timeline, 'transaction_id' => edited_task.rtm_transaction.rtm_id )

    undone_tasks = @rtm.tasks.getList( 'list_id' => list_id )
    assert_equal num_tags, undone_tasks[taskseries_id].tags.size
  end

  def test_rtm_timelines_and_transactions_with_priorities
    timeline = @rtm.timelines.create
    assert String, timeline.class
    list_id = @APITestListId
    tasks = @rtm.tasks.getList( :list_id => list_id )
    taskseries_id = '783144'
    assert_equal 'this is my tag test task', tasks[taskseries_id].name
    task_id = tasks[taskseries_id].tasks[0].id

    old_prio = tasks[taskseries_id].tasks[0].priority
    edited_task = @rtm.tasks.setPriority( :timeline => timeline, :list_id => list_id, 
                           :taskseries_id => taskseries_id, :task_id => task_id, 
                           :priority => '3' )
    assert_equal '1', edited_task.rtm_transaction.undoable

    mod_tasks = @rtm.tasks.getList( 'list_id' => list_id )

    new_prio = mod_tasks[taskseries_id].tasks[0].priority
    assert_equal '3', new_prio
    assert_not_equal old_prio, new_prio

    assert @rtm.transactions.undo( 'timeline' => timeline, 'transaction_id' => edited_task.rtm_transaction.rtm_id )
    undone_tasks = @rtm.tasks.getList( 'list_id' => list_id )
    assert_equal old_prio, undone_tasks[taskseries_id].tasks[0].priority
  end
  
  def test_rtm_groups_add_and_delete
    timeline = @rtm.timelines.create
    group_name = "DeleteMeNow.#{@fake_pid}"
    new_group = @rtm.groups.add( 'timeline' => timeline, 'group' => group_name )
    assert_equal '0', new_group.rtm_transaction.undoable
    group_id = nil
    data = @rtm.groups.getList
    data.each {|k,v| group_id = k if data[k].name == group_name}
    assert_equal group_id, data[group_id].rtm_id
    assert_equal group_id, new_group.rtm_id

    contact_id = '159980' # barbar.thecow
    transaction = @rtm.groups.addContact( 'timeline' => timeline, 'group_id' => group_id, 
                                          'contact_id' => contact_id )
    assert_equal '0', transaction.undoable
    data = @rtm.groups.getList
    assert_equal 1, data[group_id].contacts.size
    assert_equal contact_id, data[group_id].contacts[0]


    assert @rtm.groups.removeContact( 'timeline' => timeline, 'group_id' => group_id, 
                                      'contact_id' => contact_id )
    data = @rtm.groups.getList
    assert_equal 0, data[group_id].contacts.size


    transaction = @rtm.groups.delete( 'timeline' => timeline, 'group_id' => group_id )
    assert_equal '0', transaction.undoable
    
    data = @rtm.groups.getList
    assert data.has_key?(group_id) == false
  end
  
  def test_rtm_contacts_delete_and_add
    timeline = @rtm.timelines.create
    test_name = 'foofoo.thecow'
    contact_id = 0
    contacts = @rtm.contacts.getList
    contacts.each { |c| contact_id = c.id if c.username == test_name }
    assert_not_equal  0, contact_id
    
    transaction = @rtm.contacts.delete( 'timeline' => timeline, 'contact_id' => contact_id ) 
    assert_equal '0', transaction.undoable
    
    contacts = @rtm.contacts.getList()
    
    assert_equal 1, contacts.size
    assert_not_equal contact_id, contacts[0].id
    
    @rtm.contacts.add( 'timeline' => timeline, 'contact' => test_name )

    contacts = @rtm.contacts.getList()
    assert_equal 2, contacts.size
    found_test_name = false
    contacts.each { |c| found_test_name = true if c.id == contact_id }
    assert found_test_name
  end

# this test used to be undoable.  it no longer is  
#   def test_rtm_lists_add
# @rtm.debug = true
#     data = @rtm.lists.getList
#     new_list_name = "#{data.values[0].name}.#{@fake_pid}"
#     assert !data.values.find {|l| l.name == new_list_name}
# 
#     timeline = @rtm.timelines.create
#     new_list = @rtm.lists.add( :timeline => timeline, :name => new_list_name )
#     assert_equal "1", new_list.rtm_transaction.undoable
#     assert @rtm.transactions.undo( :timeline => timeline, :transaction_id => new_list.rtm_transaction.id )
#     assert_equal new_list_name, new_list.name 
#   end
#     
  
  def test_rtm_lists_getList
    data = @rtm.lists.getList
    data.delete_if {|k,v| v.deleted == '1'}
    assert_equal RememberTheMilkHash, data.class
    assert_equal 11, data.keys.size
    assert_equal 'Inbox', data[@InboxListId].name
    assert_equal 'API Test List', data[@APITestListId].name
    # Missing Tags
    assert_not_nil data['426013']
    assert_equal '(isTagged:false)', data['426013'].filter
  end
  
  def test_rtm_lists_setName
    lists = @rtm.lists.getList
    list = lists[@ReallyBadListId] # needs to be a user created list.  this happens to be one of those.
    list_id = list.rtm_id
    old_list_name = list.name
    new_list_name = "BadList.#{@fake_pid}"
    assert_not_equal old_list_name, new_list_name
    
    timeline = @rtm.timelines.create

    changed_list = @rtm.lists.setName( 'timeline' => timeline, 'name' => new_list_name, 'list_id' => list_id )
    assert_equal "1", changed_list.rtm_transaction.undoable
    assert_equal changed_list.id, @ReallyBadListId
    
    new_lists = @rtm.lists.getList
    assert new_lists[changed_list.id]
    assert_equal new_lists[changed_list.id].name, new_list_name
    assert_equal TrueClass, @rtm.transactions.undo( 'timeline' => timeline, 'transaction_id' => changed_list.rtm_transaction.id).class
    
    new_old_lists = @rtm.lists.getList()
    assert new_old_lists[@ReallyBadListId]
    assert_equal new_old_lists[@ReallyBadListId].name, old_list_name
  end
  
  def test_rtm_tasks_add
    timeline = @rtm.timelines.create
  
    new_task = @rtm.tasks.add( :list_id => @InboxListId, :name => 'test_rtm_tasks_add', :timeline => timeline )
    assert @rtm.transactions.undo( :timeline => timeline, :transaction_id => new_task.rtm_transaction.rtm_id )
    
    assert new_task
    assert_equal RememberTheMilkTask, new_task.class
    assert new_task.rtm_transaction
    assert_equal '0', new_task.rtm_transaction.undoable
    assert_equal 'test_rtm_tasks_add', new_task.name
  end
  
  def test_rtm_tasks_setDueDate
    list_id = @APITestListId
    tasks = @rtm.tasks.getList( :list_id => list_id )
    task = tasks['783144']
    assert_equal 'this is my tag test task', task.name
    assert_equal "", task.tasks[0].due

    timeline = @rtm.timelines.create
    time_string = @fake_nowtime.iso8601
    modified_task = @rtm.tasks.setDueDate( :timeline => timeline, 
                                           :list_id => list_id, 
                                           :taskseries_id => task.rtm_id, 
                                           :task_id => task.tasks[0].rtm_id, 
                                           :has_due_time => '0',
                                           :due => time_string )

    assert @rtm.transactions.undo( :timeline => timeline, 
                                   :transaction_id => modified_task.rtm_transaction.rtm_id )
                     
    assert_equal Time, modified_task.tasks[0].due.class
    assert @fake_nowtime - modified_task.tasks[0].due < 60  # rtm truncates seconds, so this should work
    
    # test with Zulu time
    new_due_date = "2005-10-14T11:54:00Z"
    modified_task = @rtm.tasks.setDueDate( :timeline => timeline, 
                                           :list_id => list_id, 
                                           :taskseries_id => task.rtm_id, 
                                           :task_id => task.tasks[0].rtm_id, 
                                           :has_due_time => '0',
                                           :due => new_due_date )

    assert @rtm.transactions.undo( :timeline => timeline, 
                                   :transaction_id => modified_task.rtm_transaction.rtm_id )
    assert_equal new_due_date, modified_task.tasks[0].due.iso8601
    
  end
  
  def test_rtm_tasks_setRecurrence
    list_id = @APITestListId
    tasks = @rtm.tasks.getList( :list_id => list_id )
    task = tasks['783144']
    assert_equal 'this is my tag test task', task.name
    #    assert_equal nil, task.recurrence

    timeline = @rtm.timelines.create

    modified_task = @rtm.tasks.setRecurrence( :timeline => timeline, 
                                              :list_id => list_id,
                                              :taskseries_id => task.rtm_id, 
                                              :task_id => task.tasks[0].rtm_id, 
                                              :repeat => 'FREQ=WEEKLY;INTERVAL=2' )
                                              
    assert @rtm.transactions.undo( :timeline => timeline, 
                                   :transaction_id => modified_task.rtm_transaction.rtm_id )

    assert_equal modified_task.rtm_id, task.rtm_id
    assert_equal "1", modified_task.recurrence.every
# API is broken right now, so interval gets ignored
#    assert_equal 'FREQ=WEEKLY;INTERVAL=2', modified_task.recurrence.rule
    assert_equal 'FREQ=WEEKLY;INTERVAL=1', modified_task.recurrence.rule
  end
end
