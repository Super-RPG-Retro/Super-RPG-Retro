"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


var _row := 0

func _ready():
	Variables._at_scene = Enum.Scene.High_scores
	Variables._scene_title = "High Score."
	
	# load high scores
	Filesystem.load_array_high_scores()
	
	for _i in range (10):
		get_node("Name" + str(_i + 1)).text = Variables._high_score_names[_i]
	
	for _i in range (10):
		get_node("Score" + str(_i + 1)).text = str(Variables._high_score_scores[_i])
		
	for _i in range (10):
		get_node("Turns" + str(_i + 1)).text = str(Variables._high_score_turns[_i])
	
func _input(event):
	# listen for ESC to exit app
	if(event.is_pressed()):
		if (event.is_action_pressed("ui_escape", true)):
			var _s = get_tree().change_scene_to_file("res://2d/source/scenes/main_menu/main_menu.tscn")
		
	if event is InputEventMouseMotion:
		for _i in range (10):
			# this highlights the row that the mouse is located at.
			if get_global_mouse_position().y >= 224 + (32 * _i) and get_global_mouse_position().y <= 224 + 32 + (_i * 32):
				$SelectButton.position.y = 224 + (_i * 32)
				
				_row = _i
				
	elif event.is_action_pressed("ui_down", true):
		_row += 1
		
		if _row < 10:
				$SelectButton.position.y = 224 + (_row * 32)
			
		else:
			_row -= 1
			
	elif event.is_action_pressed("ui_up", true):
		_row -= 1
		
		if _row > -1:
				$SelectButton.position.y = 224 + (_row * 32)
			
		else:
			_row += 1
			
			
func _return_to_main_menu():
	var _s = get_tree().change_scene_to_file("res://2d/source/scenes/main_menu/main_menu.tscn")

