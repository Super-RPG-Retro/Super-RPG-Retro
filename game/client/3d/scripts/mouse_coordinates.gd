"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# this file is from main2.tscn
extends Node2D


func _ready():
	get_tree().call_group("button_selected", "hide")
	
	get_tree().call_group("button_normal", "show")
	get_tree().call_group("button_hover", "hide")
	
		
func _process(_delta):
	Variables._mouse_cursor_position.x = get_global_mouse_position().x - 32 * 4    
	Variables._mouse_cursor_position.y = get_global_mouse_position().y - 32 * 4

func _input(event):
	# first dungeon. first level.
	# button_normal
	if Variables._dungeon_coordinates == "3,6" && Variables._compass == "E":
		# button_selected		
		if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.is_action_released("ui_left_mouse_click"):
			get_tree().call_group("button", "hide")
			
			Variables._compass_last_known_for_3d = Variables._compass
			Variables._child_scene_open = false
			Variables._at_library = false				
			Variables._game_over = false
			
			get_parent().get_node("Sound").play()
			get_tree().call_group("game_ui", "scene_2d")
			
		else:
			get_tree().call_group("button", "show")
