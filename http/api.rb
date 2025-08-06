require 'sinatra/base'
require_relative 'authenticator'
require_relative '../lib/todo'

class Api < Sinatra::Base

  attr_writer :todo

  set :enviroment, :production
  set :default_content_type, :json
  disable :dump_error, :raise_errors

  use Authenticator 
  
  before do
    @body = {}

    if request.content_type != 'application/json' && !request.content_type.nil?
      error_response(400, 'Invalid Content-Type')
    end

    begin
      body_content = request.body.read
      @body = JSON.parse body_content, symbolize_names:true unless body_content.empty?
    rescue JSON::ParserError => e
      error_response(400, "Error while processing JSON: #{e.message}")
    end
  end

  error do
    e = env['sinatra.error']

    [500, { error: "#{e.message}" }.to_json]
  end

  error JSON::ParserError do
    [500, { error: { message: e.message } }.to_json]
  end

  error Todo::InvalidUsernameError do
    [400, { error: { message: e.message } }.to_json]
  end

  post '/users/:username' do
    Todo.new(params[:username], force:true).user.to_json
  end
  
  get '/tasks' do

    done, tittle, start_deadline, end_deadline = params.values_at(
      :done,
      :tittle,
      :start_deadline,
      :end_deadline
    )
    
    done = done_parser(done)
    
    start_deadline = validate_epoch(start_deadline)

    end_deadline = validate_epoch(end_deadline)
    
    tasks = todo.list({
      tittle: tittle,
      done: done,
      start_deadline: start_deadline,
      end_deadline: end_deadline
    })
  
    tasks.to_json

  end

  get '/task/:id' do
    
    validate_uuid(params[:id])

    task = todo.find(params[:id])

    error_response(404, "Task not found") if task.nil?

    task.to_json

  end

  delete '/task/:id' do
    
    validate_uuid(params[:id])

    deleted_task = todo.delete(params[:id])

    error_response(404, "Task not found") if deleted_task.nil?

    deleted_task.to_json

  end

  put '/task/:id' do
    
    validate_uuid(params[:id])

    done = done_parser(@body[:done])

    deadline = validate_epoch(@body[:deadline])
    
    task_to_edit = todo.find(params[:id])
    
    error_response(404, "Task not found") if task_to_edit.nil?

    error_response(428, "Title is required") if @body[:title].nil? || @body[:title] == ""

    new_params = ({
      tittle: @body[:title],
      description: @body[:description],
      deadline: deadline,
      done: done
    })

    new_params.delete(:done) if new_params[:done].nil?

    new_params.delete(:deadline) if new_params[:deadline].nil?

    new_params.delete(:description) if new_params[:description].nil?
    
    todo.update(params[:id], new_params[:tittle], **new_params).to_json

  end

  post '/tasks' do

    done = done_parser(@body[:done])
    
    error_response(428, "Title is required") if @body[:title].nil? || @body[:title] == ""

    new_params = ({
      tittle: @body[:title],
      description: @body[:description],
      deadline: @body[:deadline],
      done: done
    })

    new_params.delete(:done) if new_params[:done].nil?

    todo.create(new_params[:tittle], **new_params).to_json

  rescue JSON::ParserError
    [400, { error: 'JSON malformed' }.to_json]
    
  end
  
  private

  def todo
    @todo ||= raise "Todo instance should be already provided"
  end

  def error_response(status_code, message)
    halt status_code, { error: { message: message } }.to_json
  end

  def parse_epoch(epoch)
    epoch = Integer(epoch)
    Time.at(epoch)
  rescue ArgumentError
    nil
  end

  def validate_epoch(epoch)
    unless epoch.nil?
      epoch_message = epoch
      epoch = parse_epoch(epoch)
      raise error_response(406, "Invalid date format, expected a valid epoch: #{epoch_message}") if epoch.nil? 
    end
    epoch
  end

  def validate_uuid(uuid)
    error_response(400, 'Invalid UUID format') unless uuid.to_s.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
  end

  def done_parser(done)

    return if done.nil?
  
    case done
    when 'true', 't', '1' then true
    when 'false', 'f', '0' then false
    else
      raise error_response(406, "Invalid done parameter value: #{done}. Expected: true, false")
    end

  end

end
