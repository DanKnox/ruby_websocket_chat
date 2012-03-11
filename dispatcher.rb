class Dispatcher
  require 'json'
  
  attr_reader :sockets
  
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
  
  def dispatch(event_name,data,socket)
    case event_name.to_sym
    when :new_message
      trigger('new_message',data)
    when :new_user
      store_user_socket(data,socket)
      send_user_list
    when :change_username
      change_user_name(data,socket)
      send_user_list
    end
  end
  
  def store_user_socket(new_user,socket)
    new_user['socket'] = socket
    @users << new_user
  end
  
  def send_user_list
    trigger('user_list',@users)
  end
  
  def change_user_name(new_user,socket)
    delete_user_for_socket(socket)
    store_user_socket(new_user,socket)
  end
  
  def delete_user_for_socket(socket)
    @users.delete_if {|u| u['socket'] == socket}
  end  
  
  def trigger(event_name,data)
    @sockets.each do |s|
      s.send encoded_message(event_name, data)
    end
  end
  
  def close_socket(socket)
    delete_user_for_socket( socket )
    @sockets.delete( socket )
  end
  
  def encoded_message(event_name,data)
    [event_name, data].to_json
  end
  
end