require 'rubygems'
require 'sinatra'
require 'koala'
require 'hashie'
require 'yaml'

module Config
  # If a facebook.yml file exists, use the key, secret key, and bucket values from there.
  # Otherwise, pull them from the environment.
  if File.exists?("config/facebook.yml")
    fb_config = YAML.load_file("config/facebook.yml")
    APP_ID = fb_config['app_id']
    SECRET = fb_config['secret_key']
  else
    APP_ID = ENV['FB_APP_ID']
    SECRET = ENV['FB_SECRET']
  end
end

before do
  return redirect "/" unless logged_in? || request.path_info = '/'
end

helpers do
  def logged_in?
    facebook_user && set_graph
  end

  def facebook_user
    @facebook_user ||= if request.cookies['fbs_'+Config::APP_ID.to_s]
      Hashie::Mash.new(Koala::Facebook::OAuth.new(Config::APP_ID.to_s, Config::SECRET.to_s).get_user_info_from_cookies(request.cookies))
    end
  end

  def set_graph
    @graph = Koala::Facebook::GraphAPI.new(facebook_user.access_token)
  end
end

get '/' do
  erb :index
end

get '/likes' do
  @likes = Hashie::Mash.new({"data"=>@graph.get_connections('me', 'likes')}).data
  erb :likes
end

get '/friends' do
  @friends = Hashie::Mash.new({"data"=>@graph.get_connections('me','friends')}).data.sort_by {|friend| friend.name }
  erb :friends
end

get '/friends/:id' do
  @likes = Hashie::Mash.new({"data"=>@graph.get_connections(params[:id], 'likes')}).data
  erb :likes
end

get '/friends/:id/compare' do
  @my_likes = Hashie::Mash.new({"data"=>@graph.get_connections('me', 'likes')}).data
  @friend_likes = Hashie::Mash.new({"data"=>@graph.get_connections(params[:id], 'likes')}).data
  
  intersection = @my_likes.collect { |like| like['id'] } & @friend_likes.collect { |like| like['id'] }
  @likes = (Hashie::Mash.new({"data"=>@graph.get_objects(intersection)}).data unless intersection.empty?) || []
  erb :compare
end