require File.dirname(__FILE__) + '/spec_helper'

describe "FB Likes" do
  include Rack::Test::Methods
  def app
    @app ||= Sinatra::Application
  end

  it "should respond to /" do
    get '/'
    last_response.should be_ok
  end

  it "should respond to /likes" do
    get '/likes'
    last_response.should be_ok
  end

  it "should respond to /friends" do
    get '/friends'
    last_response.should be_ok
  end

  it "should respond to /friends/:id" do
    get '/friends/1'
    last_response.should be_ok
  end

  it "should respond to /friends/:id/compare" do
    get '/friends/1/compare'
    last_response.should be_ok
  end

  describe "while logged out" do
    it "should prompt for a login" do
      get '/'
      last_response.body.should include 'Please log in'
    end
  end
  
end