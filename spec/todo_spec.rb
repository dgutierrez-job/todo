RSpec.describe Todo do
  let(:todo) { Todo }

  describe '.list_tasks ' do
    let(file) {MockFile.new []} 
    let(task) {Todo.new mock_file}
    let(:result) { task.read }

    it 'returns a list of tasks' do
      expect(result).to all(be_a(Hash))
    end
  end

  describe '.find_task' do
    let(mock_file) {MockFile.new []} 
    let(task) {Todo.new mock_file}
    let(:id) { '201380b2-ad49-4cc0-baf4-35d2acdd733e' }
    let(:result) { task.find_task id }
    it 'finds the desired task' do
      expect(result).to be_a(Hash)
      expect(result['id']).to eq(id)
    end

    context 'With unknown ID' do
      let(:id) { '8b000d1b-375f-4bf1-9189-faf142d' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end

  describe '.delete_task' do
    let(mock_file) {MockFile.new []} 
    let(task) {Todo.new mock_file}
    let(:id) { '1' }
    let(:result) { task.delete_task id} 

    it 'deletes a desired task' do
      expect(result).to be_a(Hash)
      expect(result['id']).to eq(id)
    end

    context 'With unknown ID' do
      let(:id) { 'not a number' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end

  end


  describe '.create_task' do
     let(mock_file) {MockFile.new []} 
    let(task) {Todo.new mock_file}
    let(:id) { '1' }
    let(:title) { 'programar' }
    let(:description) { 'un dia mas ' }
    let(:status) { true }
    let(:result) { task.delete_task (
    id, 
    'title' => title,
    'description' => description,
    'status' => status
    ) 
    }

    it 'creates a new task' do
      expect(result).to be_a(Hash)
      expect(result['id']).to eq(id)
      expect(result['title']).to eq(title)
      expect(result['description']).to eq(description)
      expect(result['done']).to be_a(TrueClass)
    end

  end

  describe '.edit_task' do
    let(:id) { '201380b2-ad49-4cc0-baf4-35d2acdd733e' }
    let(:title) { 'programar' }
    let(:description) { 'un dia mas ' }
    let(:status) { true }
    let(:result) { todo.edit_task id, title, description, status }

    it 'edit an existing task' do
      expect(result).to be_a(Hash)
      expect(result['id']).to eq(id)
      expect(result['title']).to eq(title)
      expect(result['description']).to eq(description)
      expect(result['done']).to be_a(TrueClass)
    end

    context 'With unknown ID' do
      let(:id) { '8b000d1b-375f-4bf1-9189-faf142d' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end
end
