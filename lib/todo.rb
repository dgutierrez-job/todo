require 'json'

class Todo
  def initialize(tasks)
    @tasks = tasks
  end

  def list_tasks
    @tasks.read_file
  end

  def find_task(id)
    list_tasks.find { |task| task['id'] == id }
  end

  def delete_task(id)
    data = list_tasks
    task_to_delete = find_task id
    data.delete task_to_delete
    @tasks.write_file data
    task_to_delete
  end

  def create_task(id, title, **attributes)
    data = list_tasks

    new_task = {
      'id' => id,
      'title' => title,
    }.merge(attributes)

    data.push new_task
    @tasks.write_file data
    new_task
  end

  def edit_task(id, **attributes)
    data = list_tasks
    task_to_edit = find_task id
    return unless task_to_edit

    data[data.index(task_to_edit)] = task_to_edit.merge attributes
    @tasks.write_file data
    task_to_edit.merge attributes
  end
end

class JSONFile
  def initialize(file)
    @file = file
  end

  def read_file
    JSON.parse File.read(@file)
  end

  def write_file(data)
    File.write @file, JSON.generate(data)
  end
end

class MockFile
  def initialize(file)
    @file = file
  end

  def read_file
    @file
  end

  def write_file(data)
    @file = data
  end
end

file = MockFile.new []
tasks = Todo.new file
tasks.create_task '1', 'Título 1', 'Description' => 'Una descrición'
puts tasks.create_task '2', 'Título 2', 'Description' => 'Otra descripción'
# tasks.edit_task '1', 'title' => 'nuevo título'
# puts tasks.list_tasks
# tasks.delete_task '2'

# task.delete_task '02bfe74-5e9e-48e9-9e23-7fdb5aeaa4ab'
# task.create_task
# task.update 'a9cf94eb-0f55-40c8-8888-9d2be6830798', 'title' => 'nuevo titulo', 'description' => 'una nueva descripcion'
