jQuery(function() {
	$("#send").unbind()
	
	if(!("WebSocket" in window)) {
	  alert("Sorry, the build of your browser does not support WebSockets. Please use latest Chrome or Webkit nightly");
	  return;
	}
//	$('#edit-user-info').modal()
	current_user = {user_name: "Guest", full_name: "Guest User"}
	$("#user-name").val(current_user.user_name)
	$("#full-name").val(current_user.full_name)
	dispatcher = new ServerEventsDispatcher()
	
	dispatcher.bind('new_message', function(message) {
		var template = $("<div class='message' style='display:none'><label class='label label-info'>"+message.user_name+" "+message.received+"</label> "+message.msg_body+"</div>");
		if($('#chat div.message').size() > 15) {
      $('#chat div.message:first').slideDown(100, function() {
        $(this).remove();
      });
    }
    $('#chat').append(template);
    template.slideDown(140);
	})
	
	dispatcher.bind('user_list', function(user_list) {
		var user_html = ""
		for(i = 0; i < user_list.length; i++) {
			user_html = user_html + "<li>"+user_list[i].user_name+"</li>"
		}
		var template = $(user_html)
		$('#user-list').empty()
		$('#user-list').append(template)
		template.slideDown(140)
	})
	

	$("#send").on('click',function() {
		var msg = $("#message").val()
		dispatcher.trigger('new_message',{user_name: current_user.user_name, msg_body: msg})
		$("#message").val('')
	});
	$("#message").keypress(function(e) {
		if(e.keyCode == 13) {
    	$("#send").click()
    }
	});
	
	$("#save-user-info").unbind()
	$("#save-user-info").on('click',function() {
		current_user.user_name = $("#user-name").val()
		current_user.full_name = $("#full-name").val()
		$("#username").html(current_user.user_name)
		$("#close-user-info").click()
		dispatcher.trigger('change_username',current_user)
	})
})
function send_message(socket) {
	var msg = $("#message").val()
	socket.send(msg)
	$("#message").val('')
}

var ServerEventsDispatcher = function(){
	var conn = new WebSocket("ws://localhost:9080")
	
	var callbacks = {}
	
	this.bind = function(event_name, callback) {
		callbacks[event_name] = callbacks[event_name] || [];
		callbacks[event_name].push(callback)
	}
	
	this.trigger = function(event_name, data) {
		var payload = JSON.stringify([event_name,data])
		conn.send( payload )
		return this;
	}
	
	conn.onopen = function(evt) {
		dispatcher.trigger('new_user',current_user)
	}
	
	conn.onmessage = function(evt) {
		var data = JSON.parse(evt.data),
			event_name = data[0],
			message = data[1];
		console.log(data)
		dispatch(event_name, message)
	}
	
	conn.onclose = function(evt) {
		dispatch('connection_closed', '')
	}
	
	var dispatch = function(event_name, message) {
		var chain = callbacks[event_name]
		if (typeof chain == 'undefined') return;
		for(var i = 0; i < chain.length; i++) {
			chain[i]( message )
		}
	}
	
	
}