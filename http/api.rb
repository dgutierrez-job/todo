require 'sinatra/base'
require_relative '../lib/todo'

class Api < Sinatra::Base
  set :enviroment, :production
  set :default_content_type, :json
  disable :dump_error, :raise_errors
  
  before do
    @body = {}
    unless request.content_type == 'application/json'
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

    [500, { error: 'something went wrong' }.to_json]
  end
  
  get '/tasks' do
    done, tittle, start_deadline, end_deadline = params.values_at(
      :done,
      :tittle,
      :start_deadline,
      :end_deadline
    )
    
    done = done_parser(done)

    unless start_deadline.nil?
      start_epoch = start_deadline
      start_deadline = parse_epoch(start_deadline)
      raise "Invalid start_deadline, expected a valid epoch: #{start_epoch}" if start_deadline.nil?
    end

    unless end_deadline.nil?
      end_epoch = end_deadline
      end_deadline = parse_epoch(end_epoch)
      raise "Invalid end_deadline, expected a valid epoch: #{end_epoch}" if end_deadline.nil? 
    end 
    
    tasks = todo.list({
      tittle: tittle,
      done: done,
      start_deadline: start_deadline,
      end_deadline: end_deadline
    })

    tasks.to_json

  end

  get '/task/:id' do

    task = todo.find(params[:id])

    return if task.nil?

    task.to_json

  end

  delete '/task/:id' do

    deleted_task = todo.delete(params[:id])

    return if deleted_task.nil?

    deleted_task.to_json

  end

  put '/task/:id' do
     
    done = done_parser(@body[:done])

    deadline = validate_epoch(@body[:deadline])

    new_params = ({
      tittle: @body[:title],
      description: @body[:description],
      deadline: deadline,
      done: done
    })

    new_params.delete(:done) if new_params[:done].nil?

    new_params.delete(:deadline) if new_params[:deadline].nil?

    new_params.delete(:description) if new_params[:description].nil?
    
    task_to_edit = todo.find(params[:id])

    return if task_to_edit.nil?

    todo.update(params[:id], new_params[:tittle], **new_params).to_json

  end

  post '/tasks' do
    body = JSON.parse request.body.read

    done = body['done']

    done = done_parser(done)

    new_params = ({
      tittle: body['title'],
      description: body['description'],
      deadline: body['deadline'],
      done: done
    })

    new_params.delete(:done) if new_params[:done].nil?

    todo.create(new_params[:tittle], **new_params).to_json

  rescue JSON::ParserError
    [400, { error: 'JSON malformed' }.to_json]
  end
  
  private

  def todo
    @todo ||= Todo.new('david')
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
      raise "Invalid date format, expected a valid epoch: #{epoch_message}" if epoch.nil? 
    end
    epoch
  end

  def done_parser(done)

    return if done.nil?
  
    case done
    when 'true', 't', '1' then true
    when 'false', 'f', '0' then false
    else
      raise "Invalid done parameter value: #{done}. Expected: true, false"
    end

  end

end
