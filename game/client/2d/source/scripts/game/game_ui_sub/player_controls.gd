"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D
class_name PlayerControls


func _input(_event):
	# player can move only if mobs or obstacles are not in current player's path.
	if Variables._keyboard_tab_pressed == false and Variables._at_library == false:
		if _event.is_action_pressed("ui_up", true):
			_player_coordinates(0, -1)
			
			# if this value if 3 then returning from _input_client by pressing the up keyboard key.
			if Variables._wait_a_turn == -3:
				Variables._wait_a_turn = -2
				return
			
			if Variables._at_library == false:
				Variables._player_stop_moving = true
		
		elif _event.is_action_pressed("ui_right", true):
			_player_coordinates(1, 0)
			
		
		elif _event.is_action_pressed("ui_down", true):
			_player_coordinates(0, 1)
			
			if Variables._at_library == false:
				Variables._player_stop_moving = true
				
		elif _event.is_action_pressed("ui_left", true):
			_player_coordinates(-1, 0)
			

# move the player one unit to this position.
func _player_coordinates(_position_x : int, _position_y : int):
	if Variables._keyboard_tab_pressed == false and Variables._at_library == false:
		Variables._wait_a_turn = -1
		
		# hide the rune casting locations.
		if Variables._rune_currently_selected != -1:
			Variables._rune_currently_selected = -1
			get_tree().call_group("rune_casting", "rune_position_hide")
			
		get_tree().call_group("game_world", "try_move", _position_x, _position_y)
		get_tree().call_group("rune_casting", "rune_turns")
		get_tree().call_group("game_ui", "hide_cursor")
		get_tree().call_group("game_ui", "hide_tile_summary")


func _on_arrow_up_pressed():
	_player_coordinates(0, -1)


func _on_arrow_right_pressed():
	_player_coordinates(1, 0)


func _on_arrow_down_pressed():
	_player_coordinates(0, 1)


func _on_arrow_left_pressed():
	_player_coordinates(-1, 0)
	
	
	
	
	
	
	
