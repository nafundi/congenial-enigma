class DataSourceSti < ActiveRecord::Migration[5.0]
  def change
    add_column :data_sources, :type, :text, null: false
    add_column :data_sources, :settings, :jsonb, null: false
  end
end
