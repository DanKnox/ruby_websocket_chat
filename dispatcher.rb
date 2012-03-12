class Dispatcher
  require 'json'
  
  attr_reader :sockets
  @@events  = Hash.new {|h,k| h[k] = Array.new}
  @@classes = Hash.new
  
  def initialize
    @sockets = []
    @users = []
  end
  
  def receive(enc_message,socket)
    message = JSON.parse( enc_message )
    event_name = message.first
    data = message.last
    data['received'] = Time.now.strftime("%I:%M:%p")
    dispatch( event_name, data, socket )
  end
  
  def trigger(event_name,data)
    @sockets.each do |s|
      s.send encoded_message( event_name, data )
    end
  end
  
  def dispatch(event_name,data,socket)
    puts "#{event_name} has #{@@events[event_name.to_sym].inspect}\n\n"
    @@events[event_name.to_sym].each do |event|
      handler = event.first
      klass   = @@classes[handler]
      method  = event.last
      klass.send( method, data, socket, self )
    end
  end  
  
  def close_socket(socket)
    @@events[]
    @sockets.delete( socket )
  end
  
  def encoded_message(event_name,data)
    [event_name, data].to_json
  end
  
  def self.subscribe(event_name,options)
    @@classes[options[:to]] ||= options[:to].new
    @@events[event_name] << [options[:to],options[:with]]
  end
  
  def self.describe_events(&block)
    block.call(self)
  end
end