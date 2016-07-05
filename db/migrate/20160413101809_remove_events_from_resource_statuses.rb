class RemoveEventsFromResourceStatuses < ActiveRecord::Migration
  def change
	remove_column( :resource_statuses, :event, :text)
  end
end
