class ChatManager
  
  def initialize
    @users = []
  end
  
  def new_message(data,socket,dispatcher)
    dispatcher.trigger('new_message',data)
  end
  
  def new_user(data,socket,dispatcher)
    store_user_socket(data,socket)
    send_user_list(dispatcher)
  end
  
  def store_user_socket(new_user,socket)
    new_user['socket'] = socket
    @users << new_user
  end
  
  def send_user_list(dispatcher)
    dispatcher.trigger('user_list',@users)
  end
  
  def change_user_name(new_user,socket,dispatcher)
    delete_user_for_socket(socket)
    store_user_socket(new_user,socket)
    send_user_list(dispatcher)
  end
  
  def delete_user_for_socket(socket)
    @users.delete_if {|u| u['socket'] == socket}
  end
end