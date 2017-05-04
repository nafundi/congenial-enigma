class CreateConfiguredServices < ActiveRecord::Migration[5.0]
  def change
    create_table :configured_services do |t|
      t.text :type, null: false
      t.text :name, null: false
      t.jsonb :settings, default: {}, null: false

      t.timestamps
    end

    add_column :data_sources, :configured_service_id, :integer, null: false,
               index: true
  end
end
