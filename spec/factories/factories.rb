FactoryGirl.define do
  factory :data_source do
    name 'Test Data Source'
  end

  factory :data_source_odk, class: DataSources::Odk, parent: :data_source do
    settings do
      { 'url' => 'https://some.url' }
    end
  end
end
