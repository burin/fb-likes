Dir["#{File.expand_path(File.dirname(__FILE__))}/vendor/*/lib"].each { |path| $:.unshift path }

require 'app'

set :environment, :development

run Sinatra::Application
