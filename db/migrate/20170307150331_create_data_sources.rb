class CreateDataSources < ActiveRecord::Migration[5.0]
  def change
    create_table :data_sources do |t|
      t.text :name, null: false

      t.timestamps
    end
  end
end
