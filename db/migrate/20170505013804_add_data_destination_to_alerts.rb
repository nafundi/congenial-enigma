class AddDataDestinationToAlerts < ActiveRecord::Migration[5.0]
  def change
    remove_column :alerts, :email, :text
    add_column :alerts, :data_destination_id, :integer, null: false, index: true
  end
end
