"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node

# this is used to send updated item_list data to all clients.
var _ticks = 0

onready var _port = $VBoxContainer/HBoxContainer/Port
onready var _server_message = $VBoxContainer/HBoxContainer/ServerMessage
onready var _rich_text_messages = $VBoxContainer/GridContainer/RichTextMessages
onready var _item_list = $VBoxContainer/GridContainer/ItemList
onready var _listen_button = $VBoxContainer/HBoxContainer/ListenButton


var _server = WebSocketServer.new()
var _protocol = PoolStringArray(["protocol", "binary"])


func _init():
	OS.set_window_maximized(true)

	_server.connect("client_connected", self, "_client_connected")
	_server.connect("client_disconnected", self, "_client_disconnected")
	_server.connect("client_close_request", self, "_client_close_request")
	_server.connect("data_received", self, "_data_received")

	_server.connect("peer_packet", self, "_data_received")
	_server.connect("peer_connected", self, "_client_connected")
	_server.connect("peer_disconnected", self, "_client_disconnected")
	

func _ready():
	_on_Listen_button_toggled(true)
	
	_server_message.grab_focus()
	

func _process(_delta):
	if _server.is_listening():
		_server.poll()
	
	_ticks += 1
	
	# send item_list data to all clients.
	if _ticks == 300: # 5 seconds.
		_ticks = 0
		_process_server_data()


# connect/disconnect: server.
func _on_Listen_button_toggled(_pressed):
	if _pressed:
		if _server.listen(_port.value, _protocol, true) == OK:
			_rich_text_messages.text +=  "Listening on port " + str(_port.value) + ". Maximum Connections: " + str(Variables._connections_maximum) + ".\n"
			
			_listen_button.icon = load("res://assets/images/host/host_disconnect.png")
			_listen_button.pressed = true
			
		else:
			_rich_text_messages.text +=  "Error listening on port " + str(_port.value) + "\n"
			_listen_button.pressed = false
			
	else:
		_rich_text_messages.text +=  "Server stopped" + "\n"
		_server.stop()
		
		_listen_button.icon = load("res://assets/images/host/host_connect.png")
		_listen_button.pressed = false
		
	
func _on_server_message_text_entered(_text):
	if _text == "":
		return
		
	_process_server_data()
	
	if Json._client_text["text"] != "":
		_rich_text_messages.text +=  "Server: " + str(Json._client_text["text"]) + "\n"
		
	_server_message.text = ""
	
			
func _process_server_data():	
	Json._client_text["sender"] = "server"
	Json._client_text["text"] = _server_message.text
	
	# store ebery logged in user into a string. each name is separated by a comma.
	Json._client_text["item_list"] = ""
	for _i in range (_item_list.get_item_count()):
		var _text = _item_list.get_item_text(_i)
		_text.replace(" ", "")
		Json._client_text["item_list"] += _text + ","
	
	send_data(Json._client_text)
	

func _client_close_request(_id, _code, _reason):
	# find the name of the user from user's id.
	var _name = _get_name_of_user(_id)
	
	_rich_text_messages.text +=  _name + ", close code: " + str(_code) + ", reason: " + str(_reason) + "\n"


# client just connected.	
func _client_connected(_id):
	Variables._connections_current += 1;	
	
	if Variables._connections_current >= Variables._connections_maximum:
		_client_disconnected(_id)
		

func _client_disconnected(_id, _was_clean_close = true):
	var _name = _get_name_of_user(_id)
			
	_rich_text_messages.text +=  _name + " disconnection was clean: " + str(_was_clean_close) + "\n"
		
	if Variables._connections_current >= Variables._connections_maximum:
		_server.disconnect_peer(_id, 1000, "Server is too busy. Try again later.")
	
	for _i in range (_item_list.get_item_count()):
		var _text = _item_list.get_item_text(_i)
		
		if _text == " " + _name:
			_item_list.remove_item(_i)
	
	if Variables._clients_id.has(_id):
		Variables._clients_id.erase(_id)
		Variables._clients_name.erase(_id)

	Variables._connections_current -= 1;

# find the name of the user from user's id.
func _get_name_of_user(_id:int) -> String:
	var _name:String = ""
	
	for _i in range (Variables._clients_id.size()):
		if _id == Variables._clients_id[_i]:
			_name = Variables._clients_name[_i]
			
			Variables._clients_id.erase(_i)
			Variables._clients_name.erase(_i)
	
	return _name


# send data to all users or to 1 user.
func _data_received(_id):
	# get data from server.
	var _data = bytes2var(_server.get_packet())
	Json._client_text = _data
	
	# store server data into json.
	var _sender = str(Json._client_text["sender"])
	var _text = str(Json._client_text["text"])
	
	if _text == "":
		# add username to ItemList.
		_item_list.add_item(" " + _sender, null, true)
		
		# print user connected message here at RichTextMessages.
		_rich_text_messages.text +=  _sender + " connected." + "\n"
		
		# store the id and name of the new logged in user, so that the user's name can be found by using the id of that user.
		Variables._clients_id.append(_id)
		Variables._clients_name.append(_sender)
	
	# is user is already logged in then output the message here at RichTextMessages.
	else:
		_rich_text_messages.text +=  _sender + ": " + _text + "\n"


# server sends data to all clients.
# see sever_ui.gd _on_Send_button_pressed()
func send_data(data):
	var _data = var2bytes(data)
	_server.put_packet(_data)
	

func _exit_tree():
	Variables._clients_id.clear()
	Variables._clients_name.clear()
	
	_server.stop()
