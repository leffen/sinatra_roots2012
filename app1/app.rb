require 'sinatra'
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'json'


class Todo 
  include DataMapper::Resource
  
  property :id, Serial
  property :text, String, length: 100, required: true
  property :done, Boolean, default: false
  property :deleted, Boolean, default: false
  
  def to_json(*a)
   {id: @id, text: @text, done: @done}.to_json(*a)
  end
    
end

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/app1.db")
DataMapper.auto_upgrade!

get '/' do
  "Hallaien ROOTS!"
end

get '/todos' do
  Todo.all(deleted: false).to_json
end  

get '/todos/:id' do
  Todo.get(params[:id]).to_json
end  


post '/todos' do
  text = params[:text]
  todo = Todo.create(text: text)
  if todo.save!
    todo.to_json 
  else
    puts "Feil opprettelse av todoitem"
    status 400
  end
end

put '/todos/:id' do
  done = params[:done]
  todo = Todo.get(params[:id])
  
  halt 400,"Ugyldig todo item spesifisert #{params[:id]}" unless todo
  
  todo.done = done
  if todo.save!
    todo.to_json
  else
    puts "Feil oppdatering av todoitem #{todo.id}"
    status 400
  end
  
end

delete '/todos/:id' do
  todo = Todo.get(params[:id])
  
  halt 400,"Ugyldig todo item spesifisert #{params[:id]}" unless todo
  todo.deleted = true

  unless todo.save!
    puts "Feil oppdatering av todoitem #{todo.id}"
    status 400
  end
end  
