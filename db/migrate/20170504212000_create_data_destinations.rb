class CreateDataDestinations < ActiveRecord::Migration[5.0]
  def change
    create_table :data_destinations do |t|
      t.text :type, null: false
      t.integer :configured_service_id, null: false, index: true
      t.text :name, null: false
      t.jsonb :settings, default: {}, null: false

      t.timestamps
    end
  end
end
