Dispatcher.describe_events do |e|
  e.subscribe :new_message, to: ChatManager, with: :new_message
  e.subscribe :new_user, to: ChatManager, with: :new_user
  e.subscribe :change_username, to: ChatManager, with: :change_user_name
  e.subscribe :close_socket, to: ChatManager, with: :delete_user_for_socket
end