RSpec.describe Todo do
  new_file = MockFile.new([
    {
      id: '0',
      title: 'wake up',
      description: 'just open your eyes and start the day',
      done: true,
    },
    {
      id: '1',
      title: 'prepare coffe and drink it',
      description: 'we need some energy to start the day',
      done: true,
    },
  ])

  let(:todo) { Todo }
  let(:file) { new_file }
  let(:tasks) { todo.new file }

  describe '.list_tasks ' do
    let(:result) { tasks.list_tasks }

    it 'returns a list of tasks' do
      expect(result).to all(be_a(Hash))
    end
  end

  describe '.find_task' do
    let(:id) { '1' }
    let(:result) { tasks.find_task id }
    it 'finds the desired task' do
      expect(result).to be_a(Hash)
      expect(result[:id]).to eq(id)
    end

    context 'With unknown ID' do
      let(:id) { '4' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end

  describe '.delete_task' do
    let(:id) { '0' }
    let(:result) { tasks.delete_task id }

    it 'deletes a desired task' do
      expect(result).to be_a(Hash)
      expect(result[:id]).to eq(id)
    end

    context 'With unknown ID' do
      let(:id) { '5' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end

  describe '.create_task' do
    let(:id) { '2' }
    let(:title) { 'programar' }
    let(:description) { 'un dia mas ' }
    let(:status) { true }
    let(:result) { tasks.create_task id, title }

    it 'creates a new task' do
      expect(result).to be_a(Hash)
      expect(result[:id]).to eq(id)
      # expect(result['title']).to eq(title)
      # expect(result[:description]).to eq(description)
      # expect(result['status']).to eq(status)
    end
  end

  describe '.edit_task' do
    let(:id) { '1' }
    # let(:title) { 'jugar' }
    # let(:description) { 'un día de chill' }
    # let(:status) { false }
    let(:result) { tasks.edit_task id }

    it 'edit an existing task' do
      expect(result).to be_a(Hash)
      expect(result[:id]).to eq(id)
      # expect(result[:title]).to eq(title)
      # expect(result['description']).to eq(description)
      # expect(result['status']).to eq(status)
    end

    context 'With unknown ID' do
      let(:id) { '7' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end
end
