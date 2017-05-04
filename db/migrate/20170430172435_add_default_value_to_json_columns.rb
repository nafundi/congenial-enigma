class AddDefaultValueToJsonColumns < ActiveRecord::Migration[5.0]
  def change
    change_column_default :data_sources, :settings, from: nil, to: {}
    change_column_default :alerts, :rule_data, from: nil, to: {}
  end
end
