"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

func _ready():
	Variables._scene_title = "Credits."

func _input(event):	
	# listen for ESC to exit app
	if(event.is_pressed()):
		if (event.is_action_pressed("ui_escape", true)):
			var _s = get_tree().change_scene("res://2d/source/scenes/main_menu.tscn")


func _on_ButtonExit_pressed():
	var _s = get_tree().change_scene("res://2d/source/scenes/main_menu.tscn")
