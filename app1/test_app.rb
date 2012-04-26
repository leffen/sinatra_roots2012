require 'test/unit'
require 'rack/test'
require 'json'
require './app'


class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
  
  def test_default
    get '/'
    assert last_response.ok?
    assert last_response.body.include?('Hallaien')
  end
  
  def test_todo_get
    get '/todos'
    assert last_response.ok?
    data = JSON.parse(last_response.body)
    assert data, 'Her burde vi ha hatt noe data'
  end
  
  def test_todo_post
    todo_text = "Dette er en test #{Time.now}" 
    
    post '/todos', text: todo_text
    assert last_response.ok?
    data = JSON.parse(last_response.body)
    assert last_response.body.include?(todo_text),"Responsen boer innholde teksten vaar #{last_response.body}"
  end
  
  def test_todo_put
    todo_text = "Dette er en PUT test #{Time.now}" 
    
    # Oppretter test todo
    post '/todos', text: todo_text
    assert last_response.ok?
    data = JSON.parse(last_response.body)
    todo_id = data["id"]

    # Oppdaterer test todo med at den er utfort
    put "/todos/#{todo_id}", done: true
    assert last_response.ok?
    data = JSON.parse(last_response.body)
    todo_id_2 = data["id"]
    done = data["done"]
    
    assert_equal todo_id,todo_id_2, "Hark, kremt, urk. Gammel og ny id stemmer ikke overens #{todo_id} <> #{todo_id_2}"
    assert done, "Dette todo itemet burde vart satt til utfort"

  end
  
  def test_delete
    todo_text = "Dette er en PUT test #{Time.now}" 
    
    # Oppretter test todo
    post '/todos', text: todo_text
    assert last_response.ok?
    data = JSON.parse(last_response.body)
    todo_id = data["id"]

    # Sletter og sjekker returkode
    delete "/todos/#{todo_id}"
    assert last_response.ok?
     
  end  
  
  def test_todo_oppdatering_av_ugyldig_post
    put "/todos/haha"
    assert_equal 400, last_response.status,'Her burde vi ha faatt en 400 feil!!!'
  end
  
end