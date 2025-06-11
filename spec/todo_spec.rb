RSpec.describe Todo do
  let(:todo) { Todo }
  let :file do
    MemoryStorage.new([
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
  end
  let(:tasks) { todo.new file }

  describe '.list' do
    let(:result) { tasks.list }

    it 'returns a list of tasks' do
      expect(result).to all(be_a(Hash))
    end
  end

  describe '.find' do
    let(:id) { '1' }
    let(:result) { tasks.find id }
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

  describe '.delete' do
    let(:id) { '1' }
    let(:result) { tasks.delete id }

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

  describe '.create' do
    let(:title) { 'programar' }
    let(:attributes) { { done: true, description: 'un dia mas' } }
    # let(:description) { 'un dia mas ' }
    # let(:status) { true }
    let(:result) { tasks.create(title, **attributes) }

    it 'creates a new task' do
      expect(result).to be_a(Hash)
      expect(result[:title]).to eq(title)
      expect(result).to include(attributes)
    end
  end

  describe '.edit' do
    let(:id) { '0' }
    let(:attributes) { { title: 'jugar', description: 'un día chill', done: false } }
    let(:result) { tasks.edit(id, **attributes) }

    it 'edit an existing task' do
      expect(result).to be_a(Hash)
      expect(result[:id]).to eq(id)
      expect(result).to include(attributes)
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

RSpec.describe JSONStorage do
  let(:JSONStorage) { JSONStorage }

  describe '.read' do
    let(:file) { JSONStorage.new 'tasks.json' }
    let(:result) { file.read }
    it 'reads a desired file' do
      expect(result).to be_a(Array)
    end

    # context 'With invalid file' do
    #   let(:file) { JSONStorage.new 'sdasd.json' }
    #   let(:result) { file.read }
    #
    #   it 'Return and exception' do
    #     expect(result).to be_a(Exception)
    #   end
    # end
  end

  describe '.write' do
    let(:file) { JSONStorage.new 'task2.json' }
    let(:data) { [{ id: '12', title: 'un titulo', done: true }] }
    let(:update) { (file.write data) }
    let(:result) { file.read }
    it 'writes a desired file' do
      update
      expect(result).to eq(data)
    end

    # context 'with invalid file' do
    #   let(:file) { jsonstorage.new 'aksdflahsfk.json' }
    #   let(:result) { file.write data }
    #
    #   it 'return and exception' do
    #     expect(result).to be_a(todoerror)
    #   end
    # end
  end
end
