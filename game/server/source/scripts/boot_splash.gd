"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


onready var _sprite = $Sprite

# this modulates the "press start" text.
var _pressed_start_modulate:float = 1


func _ready():		
	OS.set_window_maximized(true)
	OS.set_window_fullscreen(false)
		

func _process(_delta):
	if _pressed_start_modulate > 0:
		_pressed_start_modulate -= 0.1
		
	if _pressed_start_modulate <= 0:
		_pressed_start_modulate = 1
		
	$PressStart.modulate = Color(1, 1, 1, _pressed_start_modulate)
	
	
func _input(event):	
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.is_action_pressed("ui_left_mouse_click") || event.is_action_pressed("ui_accept", true):
		$PressStart.modulate = Color(1, 1, 1, 1)
			
		var _s = get_tree().change_scene("res://source/scenes/server.tscn")

