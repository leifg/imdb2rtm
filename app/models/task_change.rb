# Return value for a change of a task contains
# timeline
# all transactions_ids
# task name before change
# task name after change


class TaskChange
  
  attr_accessor :timeline, :transaction_ids,  :name_before_change, :name_after_change
  
  def initialize(timeline, tasks)
    @timeline = timeline
    @transaction_ids = UniqueArray.new
    
    tasks.each { |element| @transaction_ids << element.rtm_transaction.id }
    @name_before_change = tasks.first.name
    @name_after_change = tasks.last.name
  end
end