require 'json'

class Todo
  def initialize(file)
    @file = file
  end

  def read
    @file.list_tasks
  end

  def find_task(id)
    @file.find_task id
  end

  def delete_task(id)
    @file.delete_task id
  end

  def create_task(id, title, **attributes)
    @file.create_task(id, title, **attributes)
  end

  def update(id, **attributes)
    @file.edit_task(id, **attributes)
  end
end

class JSONFile
  def initialize(tasks)
    @tasks = tasks
  end

  def list_tasks
    JSON.parse File.read(@tasks)
  end

  def find_task(id)
    list_tasks.find { |task| task['id'] == id }
  end

  def delete_task(id)
    data = list_tasks
    task_to_delete = find_task id
    data.delete task_to_delete
    File.write @tasks, JSON.generate(data)
  end

  def create_task(id, title, **attributes)
    data = list_tasks

    new_task = {
      'id' => id,
      'title' => title,
    }.merge(attributes)

    data.push new_task
    File.write @tasks, JSON.generate(data)
  end

  def edit_task(id, **attributes)
    data = list_tasks
    task_to_edit = find_task id
    return unless task_to_edit

    data[data.index(task_to_edit)] = task_to_edit.merge attributes
    File.write @tasks, JSON.generate(data)
  end
end

class MockFile
  def initialize(tasks)
    @tasks = tasks
  end

  def list_tasks
    @tasks
  end

  def find_task(id)
    list_tasks.find { |task| task['id'] == id }
  end

  def delete_task(id)
    task_to_delete = find_task id
    data = @tasks.delete task_to_delete
    @tasks = data
  end

  def create_task(id, title, **attributes)
    new_task = {
      'id' => id,
      'title' => title,
    }.merge(attributes)

    @tasks.push new_task
  end

  def edit_task(id, **attributes)
    data = list_tasks
    task_to_edit = find_task id
    return unless task_to_edit

    data[data.index(task_to_edit)] = task_to_edit.merge attributes
  end
end

mock_file = MockFile.new []
task = Todo.new mock_file
task.create_task '1', 'Título 1', 'Description' => 'Una descrición'
task.create_task '2', 'Título 2', 'Description' => 'Otra descripción'
# task.delete_task '1'

# task.delete_task '02bfe74-5e9e-48e9-9e23-7fdb5aeaa4ab'
# task.create_task
# task.update 'a9cf94eb-0f55-40c8-8888-9d2be6830798', 'title' => 'nuevo titulo', 'description' => 'una nueva descripcion'
