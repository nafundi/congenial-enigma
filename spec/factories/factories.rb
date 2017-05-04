FactoryGirl.define do
  factory :configured_service do
    name 'Test Configured Service'
  end

  factory :configured_service_odk, class: ConfiguredServices::Odk,
          parent: :configured_service do
    settings do
      { 'url' => 'https://some.url' }
    end
  end

  factory :data_source do
    name 'Test Data Source'
  end

  factory :data_source_odk, class: DataSources::Odk, parent: :data_source do
    association :configured_service, factory: :configured_service_odk
    settings do
      { 'form_id' => 'some_id' }
    end
  end
end
