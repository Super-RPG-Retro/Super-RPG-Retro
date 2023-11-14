"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node
"""
@onready var _room_public = get_parent().get_node("Panel/VBoxContainer/HBoxContainer/RoomPublic")
@onready var _room_private = get_parent().get_node("Panel/VBoxContainer/HBoxContainer/RoomPrivate")
@onready var _room_commands = get_parent().get_node("Panel/VBoxContainer/HBoxContainer/RoomCommands")
@onready var _room_game = get_parent().get_node("Panel/VBoxContainer/HBoxContainer/RoomGame")

@onready var _item_list = get_parent().get_node("Panel/VBoxContainer/HBoxContainer/ItemList")
@onready var _listen_button = get_parent().get_node("Panel/VBoxContainer/Send/ButtonPanel/ListenButton")

var _client = WebSocketClient.new()


# client events
func _init():
	# Emitted when a connection attempt succeeds.
	_client.connect("connection_succeeded", self, "_client_connected", [1])
	
	# Emitted when the connection to the server fails.
	_client.connect("connection_error", self, "_client_disconnected")
	
	# Emitted when the connection to the server is closed.
	_client.connect("connection_closed", self, "_client_disconnected")
	
	# Emitted when the connection to the server is closed. 
	_client.connect("connection_failed", self, "_client_disconnected")
	
	# Emitted by clients when the server disconnects.
	_client.connect("server_disconnected", self, "_server_disconnected")
	
	# Emitted when the server requests a clean close.
	_client.connect("server_close_request", self, "_client_close_request")
	
	# Emitted when a WebSocket message is received.
	_client.connect("data_received", self, "_client_data_received")
	
	# Emitted when a packet is received from a peer.
	_client.connect("peer_packet", self, "_client_data_received")


func _ready():
	resize_item_list()
	

func resize_item_list():
	get_tree().call_group("client", "should_hide_tile_panel_be_visible")
			
	if Settings._system.small_main_map == false:
		_item_list.rect_min_size.y = 142
		_item_list.rect_size.y = 142
		
	else:
		_item_list.rect_min_size.y = 64
		_item_list.rect_size.y = 64
	
	_room_public.rect_min_size.y = _item_list.rect_size.y
	_room_private.rect_min_size.y = _item_list.rect_size.y
	_room_commands.rect_min_size.y = _item_list.rect_size.y
	_room_game.rect_min_size.y = _item_list.rect_size.y


func _client_close_request(code, reason):
	_room_public.text += "\n" + "Close code: " + str(code) + ", reason: " + str(reason)
	_listen_button.icon = load("res://2d/assets/images/host/host_connect.png")

	
func _exit_tree():
	_client.disconnect_from_host(1001, "Client disconnected.")
	_listen_button.icon = load("res://2d/assets/images/host/host_connect.png")


func _process(_delta):
	if _client.get_connection_status() == WebSocketClient.CONNECTION_DISCONNECTED:
		return

	_client.poll()


func _client_connected(WRITE_MODE_BINARY):
	_room_public.text += "\n" + "Client connected."
	_client.get_peer(1).set_write_mode(WRITE_MODE_BINARY)
	_listen_button.icon = load("res://2d/assets/images/host/host_disconnect.png")
	
	# name of user that is sending the text.
	Json._client_text["sender"] = PC._name
	# send an empty text to server, that a user can never send, so that the sender's name can get registered in an array. that array will be used to find the id of that user, so that server can send data from sender to any receiver.
	Json._client_text["text"] = "" 
	
	# send general data to host.
	send_data(Json._client_text)
	

func _client_disconnected(clean = true):
	_room_public.text += "\n" + "Client disconnected. Was clean: " + str(clean)
	_listen_button.icon = load("res://2d/assets/images/host/host_connect.png")


func _server_disconnected(clean = true):
	_room_public.text += "\n" + "Server disconnected. Was clean: " + str(clean)
	_listen_button.icon = load("res://2d/assets/images/host/host_connect.png")


# general message from the server.
func _client_data_received(_id = 1):
	var packet = _client.get_packet()
	var _d = bytes2var(packet, false)
	
	# updates the public room's user list.
	if str(_d["item_list"]) != "":
		var _arr = str(_d["item_list"]).split(",")
		
		_item_list.clear()
		
		for _i in range (_arr.size() - 1):
			_item_list.add_item(" " + _arr[_i], null, true)
	
	if str(_d["text"]) != "":
		_room_public.text += "\n" + str(_d["sender"]) + ": " + str(_d["text"])
	
	
# when going public, change localhost text in to the website address text at the HostAddress LineEdit at client_ui scene. 
func connect_to_url(host, protocols):
	return _client.connect_to_url(host, protocols, true)


func disconnect_from_host():
	# send host this message
	_client.disconnect_from_host(1000, "Client disconnected.")
	
	# now that client disconnected, change host button text back to "Connect"
	_listen_button.icon = load("res://2d/assets/images/host/host_connect.png")
	
# send general data.
func send_data(data):
	var _data = var2bytes(data)
	_client.put_packet(_data)
	
"""
