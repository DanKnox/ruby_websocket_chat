#require 'vendor/gems/environment'
require 'rubygems'
require 'em-websocket'
require './chat_manager'
require './dispatcher'
require './events'


dispatcher = Dispatcher.new
EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 9080) do |ws|
  ws.onopen do
    dispatcher.sockets << ws
    puts "WebSocket opened\n #{dispatcher.inspect}\n"
  end
  
  ws.onmessage do |msg|
    puts "Received message #{msg}\n"
    dispatcher.receive( msg, ws )
  end
  
  ws.onclose do
    dispatcher.close_socket( ws )
  end
end
