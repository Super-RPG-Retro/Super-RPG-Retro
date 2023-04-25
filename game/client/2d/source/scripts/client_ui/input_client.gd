"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends LineEdit

onready var _client = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Client")

onready var _room_commands = get_parent().get_parent().get_node("HBoxContainer/RoomCommands")
onready var _room_public = get_parent().get_parent().get_node("HBoxContainer/RoomPublic")

func _clear_focus():
	Variables._bypass_wait_a_turn = false
	Variables._keyboard_tab_pressed = false 
	self.focus_mode = FOCUS_NONE
	Variables._wait_a_turn = -3
	
	
func _input(event):
	if Variables._child_scene_open == true:
		_clear_focus()
				
	if event is InputEventMouseButton && event.is_action_pressed("ui_left_mouse_click") && Input.get_current_cursor_shape() == CURSOR_ARROW:
		_clear_focus()
		
	if Variables._child_scene_open == true:
		_clear_focus()
	
	if self.focus_mode == FOCUS_ALL && event.is_action_pressed("ui_up", true):
		_clear_focus()
		

func _on_mouse_entered():
	if Variables._child_scene_open == true:
		return
	
	Variables._bypass_wait_a_turn = true
	Variables._keyboard_tab_pressed = true 
	Variables._wait_a_turn = -2
	
	self.focus_mode = FOCUS_ALL
	self.grab_focus()


func _on_text_entered(_text):
	if Variables._child_scene_open == true:
		return
	
	get_tree().call_group("magic_panel", "rune_summary_visible_false")
	
	Variables._bypass_wait_a_turn = true
	Variables._keyboard_tab_pressed = true 
	Variables._wait_a_turn = -2
	
	# Do not change any code if the text is empty and the enter key is pressed. Also, do not change any code if not connected to the server and no help command was given.
	# return if not connected to server or no help command was given.

	if text == "" || _client.get_node("Panel/VBoxContainer/Send/ButtonPanel/ListenButton").icon == load("res://2d/assets/images/host/host_connect.png") && text.substr(0, 1) != "/":
		return
	
	# Help commands...
	# connect / disconnect to host.
	if text == "/h":
		Variables._trigger_commands = Enum.Trigger_commands.Host_connect_disconnect
		Variables._trigger_listen_button = true
	
	# display a panel that has all the command keys that can be used.
	elif text == "/?":
		Variables._child_scene_open = true
		Variables._at_scene = Enum.Scene.Game_help
		Variables._scene_title = "Game Help." 
		Variables._trigger_commands = Enum.Trigger_commands.Game_help
		_room_commands.text +=  "\n" + '-> Quick Help.'
	
	
	elif text == "/p0" || text == "/p1" || text == "/p2" || text == "/p3":
		# this sets the size of the player stats panel by showing/hiding magic/inventory panel.
		Settings._system.player_stats_panel_size = int(text[2])
		
		_room_commands.text += "\n" + '-> Player Stats Panel Size.'
	
		get_tree().call_group("stats_loaded", "player_stats_panel_size")
		get_tree().call_group("magic_panel", "player_stats_panel_size")
		get_tree().call_group("inventory_panel", "player_stats_panel_size")
	
	# decrement the rune group number.
	elif text == "/r-": 
		Variables._rune_current_group_selected -= 1
		Variables._rune_current_group_selected = clamp(Variables._rune_current_group_selected, 1, Variables._rune_group_total)
			
		_room_commands.text += "\n" + '-> Rune Change Group.'
		
		get_tree().call_group("magic_panel", "draw_rune_icons", Variables._rune_current_group_selected)
		
	# increment the rune group number.
	elif text == "/r+": 
		Variables._rune_current_group_selected += 1
		Variables._rune_current_group_selected = clamp(Variables._rune_current_group_selected, 1, Variables._rune_group_total)
		
		_room_commands.text += "\n" + '-> Rune Change Group.'
		
		get_tree().call_group("magic_panel", "draw_rune_icons", Variables._rune_current_group_selected)
		
	
	# rune
	elif text[0] == "/" && text.length() == 2 && text[1] == "r":
		_room_commands.text += "\n" + 'Unknown command, ' + text
		
		text = ""
	
	# rune select for casting.
	elif text[0] == "/" && text.length() == 4 && text[1] == "r" && text[2] == "c": 
		Variables._scene_title = "Rune Cast."
		var _num = text[3]
		
		if Variables._at_library == true:
			_client._accept_dialog.dialog_text = "Rune casting works only at the dungeon."
			_client._accept_dialog.popup_centered()
			return	
			
		var _found:bool = false
		
		# search every letter of the alphabet.
		var _enum = -1
		for _key in Enum.ALPHABET:
			_enum += 1
			
			# but stop search if value is found. enum holds this last letter that was found.
			if _key == _num:
				_found = true
				break	
		
		if _found == true:
			# search every letter but by its value.
			var _enum_value = -1
			for _key in Enum.ALPHABET.values():
				_enum_value += 1
				
				# if the key value is the same as the key letter then we have the correct value of the letter that was typed in at the client chat.
				if _enum_value == _enum:
					_num = _enum
				
			if _num != -1:
				get_tree().call_group("magic_panel", "_on_mouse_entered", _num)

				Variables._rune_currently_selected = _num
				get_tree().call_group("magic_panel", "rune_select", _num)
				get_tree().call_group("magic_panel", "rune_select_timer")
				get_tree().call_group("magic_panel", "rune_panel_title", _num)
				
				# rune guides.
				get_tree().call_group("rune_casting", "rune_position_show")
		
		else:
			_room_commands.text += "\n" + 'Unknown command, ' + text
			
	# rune help.
	elif text[0] == "/" && text.length() > 2 && text.length() < 6 && text[1] == "r" && text[2] == "h": 
		Variables._child_scene_open = true
		Variables._rune_help.visible = true
		Variables._scene_title = "Rune Help."
		
		# only accept numbers...
		var regex = RegEx.new()
		regex.compile("^[0-9]*$")
				
		# ...after the /r command.
		var result = regex.search(text.substr(3, 2))
		
		if result:
			# the rune number that will be passed to the rune scene.
			var _num = 1
			
			# this holds the rune dictionary keys. for example, key[0] is the first rune. 
			var _list_rune = []
			
			for _key in Json._magic.keys():
				_list_rune.push_back(_key)
			
				# make sure that a high value inserted in to this input_client cannot crash the program from the result of an invalid array..
				if int(result.get_string(0)) - 1 < _list_rune.size():
					_num = int(result.get_string(0))	
			
			# if typed "/r0", the value will default to the first rune.
			if _num == 0:
				_num = 1
			
			# jump to the rune scene at the overview func, passing the name of the array using the _num var as the index.
			get_tree().call_group("rune_help", "overview", _list_rune[ _num - 1], int(_num - 1))
				
		else:
			var _int = 0
			
			# check if user is typing a rune abbreviation in the format of "/r" for rune, then any two letters after that.
			for _key in Json._magic.keys():
				if text.substr(2, 2) == Json._magic[_key]["Abbreviation"]:
					
					# _key is the name of the rune in the dictionary. _int is the rune number in the dictionary.
					get_tree().call_group("rune_help", "overview", _key, _int)
					
				_int += 1
		
		_room_commands.text += "\n" + '-> Rune Help.'
		
	# rune buying
	elif text[0] == "/" && text.length() > 2 && text.length() < 6 && text[1] == "r" && text[2] == "b": 
		
		Variables._at_scene = Enum.Scene.Rune_buying
		Variables._scene_title = "Rune Buying."
		Variables._child_scene_open = true		
		Variables._rune_buying.visible = true
			
		get_tree().call_group("rune_buying", "_set_focus_to_nodes")
		
		_room_commands.text += "\n" + '-> Rune Buying.'
		
	
	elif text == "/m" && text.length() == 2:
		Settings._system.music = !Settings._system.music
		
		if Settings._system.music == true && Variables._last_known_music_id == 6:
			get_tree().call_group("game_ui", "play_library_music")
		
		elif Settings._system.music == true:
			get_tree().call_group("game_ui", "play_game_ui_music")
		
		else:
			get_tree().call_group("game_ui", "_music_stop")
		
		_room_commands.text += "\n" + '-> Music: ' + str(Settings._system.music)
	
	# toggle sound.
	elif text == "/s":
		Settings._system.sound = !Settings._system.sound
		if Settings._system.sound == true:
			get_tree().call_group("game_ui", "play_sound")
		else:
			get_tree().call_group("game_ui", "stop_sound")
		
		_room_commands.text += "\n" + '-> Sound: ' + str(Settings._system.sound)
	
	# toggle ambient	
	elif text == "/a":
		Settings._system.ambient = !Settings._system.ambient
		
		if Settings._system.ambient == true:
			get_tree().call_group("game_audio", "play_ambient")
		else:
			get_tree().call_group("game_audio", "stop_ambient")
			
		_room_commands.text += "\n" + '-> Ambient: ' + str(Settings._system.ambient)
	
	# clock.
	elif text == "/t":
		if Variables._at_library == true:
			_client._accept_dialog.dialog_text = "Clock is only shown the dungeon."
			_client._accept_dialog.popup_centered()
			return	
			
		Settings._game.clock = !Settings._game.clock
		
		get_tree().call_group("game_ui", "clock")
		get_tree().call_group("hud", "clock")
			
		_room_commands.text += "\n" + '-> Clock: ' + str(Settings._game.clock)
		
	# toggle the size of the client panel, which will also change the size of the main map by 64 app pixels in height.	
	elif text == "/c":
		Variables._trigger_commands = Enum.Trigger_commands.Client_panel_toggle_size
		
		_room_commands.text += "\n" + '-> Normal Client Size: ' + str(Settings._system.small_client_panel)
		
	# connect / disconnect to host.
	elif text == "/d":
		Variables._trigger_commands = Enum.Trigger_commands.Debug
		_room_commands.text += "\n" + '-> debug '
			
	# wait a turn.
	elif text == "/w" && text.length() == 2:
		Variables._trigger_commands = Enum.Trigger_commands.Wait_a_turn
		Variables._wait_a_turn = 1
		
		_client._timer_wait_turn.start()
		
		_room_commands.text += "\n" + '-> Wait Turn.'
	
	
	# get a max of 99 wait turns
	elif text[0] == "/" && text.length() > 2 && text[1] == "w":
		Variables._trigger_commands = Enum.Trigger_commands.Wait_a_turn
		Variables._wait_a_turn = int(text.substr(2, 2))
		
		_client._timer_wait_turn.start()
		
		_room_commands.text += "\n" + '-> Wait Turns: ' + str(Variables._wait_a_turn)
			
	elif text[0] == "/":
		_room_commands.text += "\n" + 'Unknown command, ' + text
		
		text = ""
	
	else:	
		_room_public.text += "\n" + P.character_stats[str(P._number)]["_loaded"].Username + ": " + text
				
		# name of user that is sending the text.
		Json._client_text["sender"] = P._name
		Json._client_text["text"] = text
		
		# send general data to host at the client_events.gd send_data function.
		_client._client_events.send_data(Json._client_text)
		
	text = ""

