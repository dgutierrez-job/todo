require_relative '../lib/todo'

class Authenticator
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    username = env['HTTP_USERNAME']
    
    path = env['REQUEST_URI']
    
    if path.to_s.match?(/\/users\/./)

      return app.call(env)

    else
    
      raise [400, { error: 'JSON malformed' }.to_json] if username.nil?

      app.todo = Todo.new username

      app.call env

    end

    rescue Todo::InvalidUsernameError => e
      raise error_response(400, "#{e.message}")

  end
  
end

