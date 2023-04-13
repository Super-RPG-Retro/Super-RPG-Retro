"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Control

var _tab_pressed = false

onready var _accept_dialog = $AcceptDialog

onready var _listen_button = $Panel/VBoxContainer/Send/ButtonPanel/ListenButton
# this button, when clicked, shows the public room.
onready var _button_public = $Panel/VBoxContainer/Send/ButtonPanel/ButtonPublic
onready var _button_private = $Panel/VBoxContainer/Send/ButtonPanel/ButtonPrivate
onready var _button_commands = $Panel/VBoxContainer/Send/ButtonPanel/ButtonCommands
onready var _button_game = $Panel/VBoxContainer/Send/ButtonPanel/ButtonGame

# only you see this room.
onready var _room_private = $Panel/VBoxContainer/HBoxContainer/RoomPrivate
onready var _room_public = $Panel/VBoxContainer/HBoxContainer/RoomPublic

# this room is used when doing a system command.
onready var _room_commands = $Panel/VBoxContainer/HBoxContainer/RoomCommands

# while playing the game, text about the battle or event is placed here.
onready var _room_game = $Panel/VBoxContainer/HBoxContainer/RoomGame

# events such as send or connect.
onready var _client_events = $ClientEvents

# this is the node used to type text at the client.
onready var _input_client = $Panel/VBoxContainer/Send/InputClient

# this is the address needed to connect to the server.
onready var _host_address = $Panel/VBoxContainer/Send/ButtonPanel/HostAddress

# used to delay the wait a turn feature.
onready var _timer_wait_turn = $TimerGameTurn

onready var _hide_tile_top = get_parent().get_parent().get_parent().get_node("PanelTileHideTop")

onready var _hide_tile_bottom = get_parent().get_parent().get_parent().get_node("PanelTileHideButtom")


func _ready():
	if Settings._system.hide_chat_features == true:
		_room_public.visible = false
		_room_private.visible = false
		_listen_button.visible = false
		_button_public.visible = false
		_button_private.visible = false
		
	if Variables._host_is_connected == true:
		_listen_button.icon = load("res://2d/assets/images/host/host_disconnect.png")
		_listen_button.icon = load("res://2d/assets/images/host/host_disconnect.png")
	else:
		_accept_dialog.popup_centered()
		_accept_dialog.visible = false
		
		_host_address.focus_mode = FOCUS_CLICK
		
	if Variables._child_scene_open == true:
		_input_client.focus_mode = FOCUS_NONE
		_input_client.set_editable(false)


func _input(event):	
	# if child scene is not open and there is a keyboard key pressed...
	if event is InputEventKey and event.pressed && Variables._child_scene_open == false && _input_client.has_focus() == false:
		if event.scancode == KEY_SLASH:
			Variables._bypass_wait_a_turn = true
			Variables._keyboard_tab_pressed = true 
			Variables._wait_a_turn = -2
			
			_focus_none()
			_input_client.focus_mode = FOCUS_ALL
			_input_client.grab_focus()
			
		if event.scancode == KEY_UP && _input_client.has_focus() == true:
			_input_client.focus_mode = FOCUS_NONE 
			Variables._keyboard_tab_pressed = false	
		
		
	# this will close the accept dialog, which display a general message.
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.is_action_pressed("ui_left_mouse_click") || event.is_action_pressed("ui_accept", true):
		_accept_dialog.visible = false
	
	if Variables._game_over == true:
		return
	
	if Variables._child_scene_open == true:
		return
		
	if Variables._child_scene_open == false:
		_input_client.set_editable(true)
	
	if event.is_action_released("ui_focus_next"):
		if Variables._keyboard_tab_pressed == true:
			Variables._keyboard_tab_pressed = false
			
			_focus_none()
			_tab_pressed = false
			
		else:
			Variables._keyboard_tab_pressed = true
			
			_tab_pressed = true
			
			_focus_none()
							
			if Settings._system.hide_chat_features == false:
				_listen_button.focus_mode = FOCUS_ALL
				_listen_button.grab_focus()
			else:
				_button_commands.focus_mode = FOCUS_ALL
				_button_commands.grab_focus()
	
	# when trying to move the player, focus will be for that movement instead of for the _input_client node.
	if	Variables._keyboard_tab_pressed == true && event.is_action_released("ui_right") == true:
		if _listen_button.focus_mode == FOCUS_ALL:
			_listen_button.focus_mode = FOCUS_NONE
			_button_public.focus_mode = FOCUS_ALL
			_button_public.grab_focus()
			
		elif _button_public.focus_mode == FOCUS_ALL:
			_button_public.focus_mode = FOCUS_NONE
			_button_private.focus_mode = FOCUS_ALL
			_button_private.grab_focus()
			
		elif _button_private.focus_mode == FOCUS_ALL:
			_button_private.focus_mode = FOCUS_NONE
			_button_commands.focus_mode = FOCUS_ALL
			_button_commands.grab_focus()
			
		elif _button_commands.focus_mode == FOCUS_ALL:
			_button_commands.focus_mode = FOCUS_NONE
			_button_game.focus_mode = FOCUS_ALL
			_button_game.grab_focus()
		
		elif _button_game.focus_mode == FOCUS_ALL:
			_focus_none()
			_input_client.focus_mode = FOCUS_ALL
			_input_client.grab_focus()
				
	if Variables._keyboard_tab_pressed == true && event.is_action_released("ui_up") == true:
		_tab_pressed = false
		Variables._keyboard_tab_pressed = false
		_focus_none()
	
	if Variables._keyboard_tab_pressed == true && event.is_action_pressed("ui_left") == true:
		if _input_client.has_focus() && _input_client.caret_position == 0:
			_tab_pressed = true
			
			_focus_none()
			_button_game.focus_mode = FOCUS_ALL
			_button_game.grab_focus()
			
		elif _button_game.focus_mode == FOCUS_ALL:
			_button_game.focus_mode = FOCUS_NONE
			_button_commands.focus_mode = FOCUS_ALL
			_button_commands.grab_focus()
		
		elif Settings._system.hide_chat_features == false:	
			if _button_commands.focus_mode == FOCUS_ALL:
				_button_commands.focus_mode = FOCUS_NONE
				_button_private.focus_mode = FOCUS_ALL
				_button_private.grab_focus()
				
			elif _button_private.focus_mode == FOCUS_ALL:
				_button_private.focus_mode = FOCUS_NONE
				_button_public.focus_mode = FOCUS_ALL
				_button_public.grab_focus()
			
			elif _button_public.focus_mode == FOCUS_ALL:
				_button_public.focus_mode = FOCUS_NONE
				_listen_button.focus_mode = FOCUS_ALL
				_listen_button.grab_focus()
				
		else:
			_focus_none()
			_input_client.focus_mode = FOCUS_ALL
			_input_client.grab_focus()
			
			if _input_client.caret_position == 0:
				_tab_pressed = false
			
	# /c (trigger server connect/disconnect button)
	if Variables._trigger_listen_button == true:
		Variables._trigger_listen_button = false
		_on_listen_button_pressed()
		_input_client.text = ""
		return


func should_hide_tile_panel_be_visible():
	_hide_tile_top.visible = false
	_hide_tile_bottom.visible = false
	
	if Settings._system.small_client_panel == false:
		if Settings._system.use_large_tiles == false:
			_hide_tile_top.visible = true
			_hide_tile_bottom.visible = true
	

func _focus_none():
	_listen_button.focus_mode = FOCUS_NONE
	_input_client.focus_mode = FOCUS_NONE
	_button_public.focus_mode = FOCUS_NONE
	_button_private.focus_mode = FOCUS_NONE
	_button_commands.focus_mode = FOCUS_NONE
	_button_game.focus_mode = FOCUS_NONE
	_host_address.focus_mode = FOCUS_NONE


func accept_dialog(_text):
	_accept_dialog.dialog_text = _text
	_accept_dialog.visible = true

func _on_Mode_item_selected(_id):
	_client_events.set_write_mode(1)


func _on_listen_button_pressed():
	if _listen_button.icon == load("res://2d/assets/images/host/host_connect.png"):
		_listen_button.set_pressed_no_signal(false)
		Variables._host_is_connected = false
		
	if _listen_button.icon == load("res://2d/assets/images/host/host_disconnect.png"):
		_listen_button.set_pressed_no_signal(true)
				
	if _listen_button.icon == load("res://2d/assets/images/host/host_connect.png"):
		if _host_address.text != "":
			_room_public.text += "\n" + "Connecting to host: " + _host_address.text
			var protocols = PoolStringArray(["binary"])
			_client_events.connect_to_url(_host_address.text, protocols)
			Variables._host_is_connected = true
			
	else:
		_client_events.disconnect_from_host()

# at client _input_client, text "/w" was typed in to that field. Timer was started and at its timeout, this func is called.
func _on_TimerGameTurn_timeout():
	get_tree().call_group("game_ui", "wait_turn")
	
	if Variables._bypass_wait_a_turn == false:
		Variables._wait_a_turn -= 1
		
	# if true then there is another wait turn to complete.
	if Variables._wait_a_turn > 0:
		_timer_wait_turn.start()
		Variables._bypass_wait_a_turn = false
	else:
		_timer_wait_turn.stop()	

# hide all rich text nodes. at least one rich text node will be visible after this func is called.
func hide_all_room_nodes():
	_room_public.visible = false
	_room_private.visible = false
	_room_commands.visible = false
	_room_game.visible = false
	pass


func reset_all_button_nodes():
	_button_public.pressed = false
	_button_private.pressed = false
	_button_commands.pressed = false
	_button_game.pressed = false
	

func _on_button_public_pressed():
	hide_all_room_nodes()
	reset_all_button_nodes()
	
	_room_public.visible = true
	_button_public.pressed = true
	
	
func _on_button_private_pressed():
	hide_all_room_nodes()
	reset_all_button_nodes()
	
	_room_private.visible = true
	_button_private.pressed = true
	

func _on_button_commands_pressed():
	hide_all_room_nodes()
	reset_all_button_nodes()
	
	_room_commands.visible = true
	_button_commands.pressed = true
		

func _on_button_game_pressed():
	hide_all_room_nodes()
	reset_all_button_nodes()
	
	_room_game.visible = true
	_button_game.pressed = true
	
