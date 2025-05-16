RSpec.describe Todo do
  describe '.hi' do
    it 'salutes' do
      expect(Todo.hi('David')).to eq('Hi David')
    end
  end
end
