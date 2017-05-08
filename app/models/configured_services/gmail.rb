class ConfiguredServices::Gmail < ConfiguredService
  with_technology_name 'Gmail'
  provides :data_destination
end
