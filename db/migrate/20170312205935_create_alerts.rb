class CreateAlerts < ActiveRecord::Migration[5.0]
  def change
    create_table :alerts do |t|
      t.text :rule_type, null: false
      t.jsonb :rule_data, null: false
      t.text :email, null: false
      t.text :message, null: false

      t.timestamps
    end

    create_table :data_source_alerts do |t|
      t.integer :data_source_id, null: false, index: true
      t.integer :alert_id, null: false, index: true

      t.timestamps
    end
  end
end
