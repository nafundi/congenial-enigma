RSpec.describe DataSource do
  describe 'name' do
    let(:data_source) { build(:data_source) }

    it 'saves a valid data source' do
      data_source.save!
    end

    it 'requires a name' do
      data_source.name = nil
      expect(data_source).not_to be_valid
    end

    it 'strips the name after save' do
      name = data_source.name
      data_source.name += " \t\n"
      data_source.save!
      expect(data_source.name).to eq(name)
    end
  end
end
