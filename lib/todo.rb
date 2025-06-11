require 'json'
require 'csv'
require 'securerandom'

class Todo
  def initialize(tasks)
    @tasks = tasks
  end

  def list
    @tasks.read
  end

  def find(id)
    list.find { |task| task[:id] == id }
  end

  def delete(id)
    data = list
    task_to_delete = find id
    data.delete task_to_delete
    @tasks.write data
    task_to_delete
  end

  def create(title, **attributes)
    raise TodoError.new('Title is required') if !title.is_a?(String) || title.empty?

    data = list

    new_task = { done: false }.merge(attributes).merge({ id: SecureRandom.uuid, title: title })
    data.push new_task
    @tasks.write data
    new_task
  end

  def edit(id, **attributes)
    data = list
    task_to_edit = find id
    return unless task_to_edit

    data[data.index(task_to_edit)] = task_to_edit.merge attributes
    @tasks.write data
    task_to_edit.merge attributes
  end
end

class JSONStorage
  def initialize(file)
    @file = file
  end

  def read
    JSON.parse(File.read(@file), { symbolize_names: true })
  rescue Errno::ENOENT
    raise TodoFileReadError.new("Unable to open #{@file} file. No such file.")
  rescue Errno::EACCES
    raise TodoFileReadError.new("Unable to read #{@file}. No permissions.")
  rescue JSON::ParserError
    raise TodoFileReadError.new("JSON malformed on #{@file} file")
  rescue StandardError => e
    raise TodoError.new("Unexpected error: #{e.message}")
  end

  def write(data)
    JSON.dump data, File.open(@file, 'w')
  rescue Errno::ENOENT
    raise TodoFileReadError.new("Unable to open #{@file} file. No such file.")
  rescue Errno::EACCES
    raise TodoFileReadError.new("Unable to write in #{@file}. No permissions")
  end
end

class CSVStorage
  def initialize(file)
    @file = file
  end

  def read
    tasks = []

    CSV.foreach @file, headers: true, header_converters: :symbol do |row|
      task = row.to_h
      task[:done] = task[:done] == 'true' if task.key? :done
      tasks << task
    end

    tasks
  rescue Errno::ENOENT
    raise TodoFileReadError.new("No such file: #{@file}.")
  rescue Errno::EACCES
    raise TodoFileReadError.new("No permissions: #{@file} ")
  rescue CSV::MalformedCSVError
    raise TodoFileReadError.new("Malformed CSV: #{@file}.")
  end

  def write(data)
    headers = data.first&.keys
    return if headers.nil?

    CSV.open @file, 'w', write_headers: true, headers: headers do |csv|
      data.each do |task|
        csv << headers.map { |header| task[header] }
      end
    end
  rescue Errno::ENOENT
    raise TodoFileReadError.new("Unable to open #{@file} file. No such file.")
  rescue Errno::EACCES
    raise TodoFileReadError.new("Unable to read #{@file} file. No permissions.")
  end
end

class MemoryStorage
  def initialize(file = [])
    @file = file || []
  end

  def read
    @file
  end

  def write(data)
    @file = data
  end
end

class TodoError < StandardError
end

class TodoFileReadError < TodoError
end

class TodoFileWriteError < TodoError
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
