Dir["#{File.expand_path(File.dirname(__FILE__))}/vendor/*/lib"].each { |path| $:.unshift path }

require 'app'

run Sinatra::Application
