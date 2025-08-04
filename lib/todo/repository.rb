class Todo
  class Repository
    DB_CONNECTION_URI = ENV.fetch(
      'DB_CONNECTION_URI',
      'postgres://username:password@localhost:5433/todo'
    )

    def initialize(uri = DB_CONNECTION_URI)
      @db = Sequel.connect uri
    end

    FIND_USER_BY_NAME = <<~SQL.freeze
      SELECT * FROM users
      WHERE username = :username
        AND deleted_at IS NULL
    SQL

    def find_user_by_username(username)
      record = db.fetch(FIND_USER_BY_NAME, { username: username }).first

      return if record.nil?

      Todo::Entities::User.new record
    end

    CREATE_USER = <<~SQL
      INSERT INTO users (username)
      VALUES(:username)
      ON CONFLICT (username) DO UPDATE SET deleted_at = NULL
      RETURNING *
    SQL

    def create_user(username)
      record = db.fetch(CREATE_USER, { username: username }).first

      return if record.nil?

      Todo::Entities::User.new record
    end

    LIST_TASKS = <<~SQL
      SELECT *
      FROM tasks
      WHERE deleted_at IS NULL 
      AND user_id = :user_id
    SQL

    def list_tasks(user_id, filters = {})

      conditions = []

      tittle, done, start_deadline, end_deadline = filters.values_at(
        :tittle,
        :done,
        :start_deadline,
        :end_deadline
      )

      conditions << 'tittle LIKE :tittle' unless tittle.nil?

      conditions << 'done = :done ' unless done.nil?

      if start_deadline && end_deadline 
        conditions << 'deadline >= :start_deadline AND deadline < :end_deadline'
      elsif start_deadline
        conditions << 'deadline >= :start_deadline'
      elsif end_deadline
        conditions << 'deadline < :end_deadline'
      end

      query = LIST_TASKS

      conditions.each do |condition|
        query = "#{query} AND #{condition}"
      end

      db.fetch(query, filters.merge({ user_id: user_id })).all.map do |task|
        Todo::Entities::Task.new task
      end

    end

    FIND_TASKS_BY_ID = <<~SQL
      SELECT *
      FROM tasks
      WHERE deleted_at IS NULL AND id = :id;
    SQL

    def find_task_by_id(id)
      record = db.fetch(FIND_TASKS_BY_ID, { id: id }).first

      return if record.nil?

      Todo::Entities::Task.new record
    end

    DELETE_TASK_BY_ID = <<~SQL
      UPDATE tasks
      SET deleted_at = NOW()
      WHERE deleted_at IS NULL AND id = :id
      RETURNING *
    SQL

    def delete_task_by_id(id)
      record = db.fetch(DELETE_TASK_BY_ID, { id: id }).first

      return if record.nil?

      Todo::Entities::Task.new record
    end

    CREATE_TASK = <<~SQL
      INSERT INTO tasks (tittle, user_id, description, done, deadline)
      VALUES (:tittle, :user_id, :description, :done, :deadline)
      RETURNING *
    SQL

    def create_task(input)
      record = db.fetch(CREATE_TASK, input).first

      Todo::Entities::Task.new record
    end

    UPDATE_TASK_BY_ID = <<~SQL
      UPDATE tasks
      SET tittle = :tittle,
          description = :description,
          done = :done,
          deadline = :deadline, 
          updated_at = NOW()
      WHERE deleted_at is NULL AND id = :id
      RETURNING * 
    SQL

    def update_task_by_id(input)
      record = db.fetch(UPDATE_TASK_BY_ID, input).first

      return if record.nil?

      Todo::Entities::Task.new record
    end
    

    private

    attr_reader :db
  end
end
