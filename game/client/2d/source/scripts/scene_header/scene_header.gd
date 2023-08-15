"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


@onready var _label := $Label


func _process(_delta):
	_label.text = Variables._scene_title

# this func is triggered when the exit button at the top right corner ot scene is mouse clicked.
func _on_ButtonExit_pressed():
	Variables._item_list_current_index = 0
	
	if Variables._at_scene == Enum.Scene.Game_UI:
		# tile summary overview()
		if Variables._trigger_commands == Enum.Trigger_commands.Unit_description:
			get_tree().call_group("game_ui", "tile_summary_overview")			
			return
					
	if Variables._at_scene == Enum.Scene.Settings_system:
		get_tree().call_group("settings_system", "_return_to_main_menu")
		return
		
	if Variables._at_scene == Enum.Scene.High_scores:
		get_tree().call_group("high_scores", "_return_to_main_menu")
		return
		
	if Variables._at_scene == Enum.Scene.Settings_game:
		get_tree().call_group("settings_game", "_return_to_main_menu")	
		return
		
	if Variables._at_scene == Enum.Scene.Builder:
		Filesystem.populate_json_dictionaries()
		
		get_tree().call_group("builder", "_return_to_main_menu")	
		return
		
	if Variables._at_scene == Enum.Scene.Main_Menu:
		get_tree().call_group("main_menu", "_quit")
		return
		
		
	if Variables._at_scene == Enum.Scene.Game_help:
		get_tree().call_group("game_help", "_exit_scene")	
		return
	
		
func _on_SceneHeader_tree_exiting():
	call_deferred("remove_child", _label)
	call_deferred("queue_free", _label)
	
	queue_free()
