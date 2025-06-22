require './app'

# Configure the app to be accessible on the network
set :bind, '0.0.0.0'
set :port, 4567

run Sinatra::Application
