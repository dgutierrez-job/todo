require 'json'
require 'csv'
require 'securerandom'

class Todo
  def initialize(tasks)
    @tasks = tasks
  end

  def list_tasks
    @tasks.read_file
  end

  def find_task(id)
    list_tasks.find { |task| task[:id] == id }
  end

  def delete_task(id)
    data = list_tasks
    task_to_delete = find_task id
    data.delete task_to_delete
    @tasks.write_file data
    task_to_delete
  end

  def create_task(title, **attributes)
    raise 'Title is required' if !title.is_a?(String) || title.empty?

    data = list_tasks

    new_task = { done: false }.merge(attributes).merge({ id: SecureRandom.uuid, title: title })
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
    JSON.parse(File.read(@file), { symbolize_names: true })
  end

  def write_file(data)
    File.write @file, JSON.generate(data)
  end
end

class CSVFile
  def initialize(file)
    @file = file
  end

  def read_file
    tasks = []
    CSV.foreach @file, headers: true, header_converters: :symbol do |row|
      task = row.to_h
      task[:done] = task[:done] == 'true' if task.key? :done
      tasks << task
    end

    tasks
  end

  def write_file(_data)
    headers = tasks.first&.keys
    return if headers.nil?

    CSV.open @file, 'w', write_headers: true, headers: headers do |csv|
      tasks.each do |task|
        csv << headers.map { |header| task[header] }
      end
    end
  end
end

class MockFile
  def initialize(file = [])
    @file = file || []
  end

  def read_file
    @file
  end

  def write_file(data)
    @file = data
  end
end

# new_file = MockFile.new([
#  [ #    id: '0',
#    title: 'wake up',
#    description: 'just open your eyes and start the day',
#    done: true,
# ],
#  [ #    id: '1',
#    title: 'prepare coffe and drink it',
#    description: 'we need some energy to start the day',
#    done: true,
# ],
# ])

# tasks = Todo.new new_file
# puts tasks.list_tasks
# puts tasks.find_task('0')
