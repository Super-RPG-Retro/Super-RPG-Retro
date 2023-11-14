"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


@onready var _menu_project := $MenuProject

func _ready():
	_menu_project.grab_focus()


func _gui_input(event):
	if $SceneHeader/ButtonExit.has_focus() == true or $MenuProject.has_focus() == true or $MenuDictionaries.has_focus() == true or $MenuEvents.has_focus() == true or $MenuAudio.has_focus() == true or $MenuLibrary.has_focus() == true:
		Variables.a.keycode = 0
	
	
	if(event.is_pressed()):
		if (event.is_action_pressed("ui_escape", true)):
			
			Filesystem.populate_json_dictionaries()
			
			var _s = get_tree().change_scene_to_file("res://3d/scenes/gridmap.tscn")
	

func _process(_delta):
	if Builder._config.game_title[Builder._config.game_id] == "":
		$MenuDictionaries.disabled = true
		$MenuEvents.disabled = true
		
	else:
		$MenuDictionaries.disabled = false
		$MenuEvents.disabled = false
		
	if Builder._config.dungeon_enabled[Builder._config.game_id][Builder._config.dungeon_number - 1] == 0:
		$MenuDictionaries.disabled = true
		$MenuEvents.disabled = true
		
	else:
		$MenuDictionaries.disabled = false
		$MenuEvents.disabled = false
	
	if Settings._system.music == false:
		$MenuAudio.disabled = true
		
		
func _on_Node2D_tree_exiting():
	Common._parse_input_event()
	Filesystem.builder_save_data()
	
	call_deferred("remove_child", _menu_project)
	call_deferred("queue_free", _menu_project)
	
	queue_free()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		Common._parse_input_event()
		Filesystem.builder_save_data()
	

