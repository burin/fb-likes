require 'rubygems'
require 'sinatra'
require 'koala'
require 'hashie'

$app_id = '117628591626737'
$app_secret = '2f84d6ec45ca373b26d8994e743d6b0e'

before do
  return redirect "/" unless logged_in? || request.path_info = '/'
end

helpers do
  def logged_in?
    facebook_user && set_graph
  end

  def facebook_user
    @facebook_user ||= if request.cookies['fbs_'+$app_id]
      Hashie::Mash.new(Koala::Facebook::OAuth.new($app_id, $app_secret).get_user_info_from_cookies(request.cookies))
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
  @friends = Hashie::Mash.new({"data"=>@graph.get_connections('me','friends')}).data.sort {|k,v| a.name <=> b.name }
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