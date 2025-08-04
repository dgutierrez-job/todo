require 'json'
require 'csv'
require 'securerandom'
require 'pg'
require 'sequel'

require_relative 'todo/errors'
require_relative 'todo/storage'
require_relative 'todo/entities'
require_relative 'todo/repository'

class Todo
  attr_reader :user


  def initialize(username, force: false)
    @user = repository.find_user_by_username username

    return unless user.nil?

    raise Todo::InvalidUsernameError.new("Username not found") unless force

    @user = repository.create_user username
  end

  def list(filters={})
     
    repository.list_tasks(user.id, filters)

  end

  def find(id)
    repository.find_task_by_id(id)
  end

  def delete(id)
    repository.delete_task_by_id(id)
  end

  def create(tittle, **options)
    raise todoerror.new('title is required') if !tittle.is_a?(String) || tittle.empty?
    
    options  = options.merge({ user_id: user.id })

    repository.create_task({
      tittle: options[:tittle],
      user_id: options[:user_id],
      description: options.fetch(:description, nil),
      deadline: options.fetch(:deadline, nil),
      done: options.fetch(:done, false)
    })

  end

  def update(id, tittle, **options)
  
    task = repository.find_task_by_id(id)


    repository.update_task_by_id({
      id: id,
      tittle: tittle,
      description: options.fetch(:description, task.description),
      deadline: options.fetch(:deadline, task.deadline),
      done: options.fetch(:done, task.done)
    })

  end

  private
  
  def repository
      @repository ||= Todo::Repository.new
  end

end
