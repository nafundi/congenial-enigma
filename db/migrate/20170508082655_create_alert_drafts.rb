class CreateAlertDrafts < ActiveRecord::Migration[5.0]
  def change
    create_table :alert_drafts do |t|
      t.integer :data_source_configured_service_id
      t.integer :data_source_id
      t.text :field_name
      t.text :rule_type
      t.decimal :rule_value
      t.text :message
      t.integer :data_destination_configured_service_id
      t.integer :data_destination_id

      # We'll use this uniqueness constraint to ensure that there is only a
      # single draft at a time.
      t.integer :row_count_constraint, default: 0
      t.index :row_count_constraint, unique: true

      t.timestamps
    end
  end
end
