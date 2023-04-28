"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

onready var _menu_project = $MenuProject

func _ready():
	_menu_project.grab_focus()

func _input(event):
	if $MenuProject.has_focus() == true || $MenuDictionaries.has_focus() == true || $MenuEvents.has_focus() == true || $MenuAudio.has_focus() == true || $MenuLibrary.has_focus() == true:
		Variables.a.scancode = 0
		
	else:
		# this registers a keypress in case the user is at a spinbox and editing that spinbox value using the keyboard. The problem is that without this code, changing the value without pressing enter key would not save that new value when exiting that scene.
		if Variables._scene_title != "Builder: Audio Music.":
			Common._scancode_if_pressed_enter(event)
		
		
	if(event.is_pressed()) && Variables._child_scene_open == false:
		if (event.is_action_pressed("ui_escape", true)):
			
			Filesystem.populate_json_dictionaries()
			
			var _s = get_tree().change_scene("res://2d/source/scenes/main_menu.tscn")
	

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
	Filesystem.builder_save_data()
	
	call_deferred("remove_child", _menu_project)
	call_deferred("queue_free", _menu_project)
	
	queue_free()

