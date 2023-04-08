"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node

# this refers to the dungeon number. a value of 0 means that dungeon is the first dungeon which may not be the starting dungeon.
onready var _dungeon_number = $Container/Grid/Grid2/SpinboxDungeonNumber

# enabled: dungeon is active and can be entered from the library. disabled: dungeon is not at the library and dungeon cannot be entered. all features disabled,
onready var _dungeon_enabled = $Container/Grid/Grid3/DungeonEnabled

# builder nenu.
onready var _menu = null

func _ready():
	# this is needed so when clicking the red button at the top right corner of sceme, the code will jump to the correct scene.
	Variables._at_scene = Enum.Scene.Builder
	
	# this is the title of the scene.
	Variables._scene_title = "Builder: Project Dungeons."
	
	# set the level spinbox from the loaded data.	
	_dungeon_number.value = Builder._config.dungeon_number
	_on_spinbox_dungeon_number_value_changed(_dungeon_number.value)
	
	_dungeon_enabled.pressed = bool(Builder._config.dungeon_enabled[Builder._config.game_id][_dungeon_number.value - 1])
	_on_DungeonEnabled_toggled(_dungeon_enabled.pressed)
	
	if _menu == null:
		_menu = load("res://2d/source/scenes/builder/menu.tscn").instance()
		add_child( _menu )


func _on_spinbox_dungeon_number_value_changed(value):
	Builder._config.dungeon_number = value
	Builder._data.dungeon_number = value - 1
	
	_dungeon_enabled.pressed = Builder._config.dungeon_enabled[Builder._config.game_id][value - 1]

	
func _on_spinbox_dungeon_number_mouse_exited():
	var a = InputEventKey.new()
	a.scancode = KEY_ENTER
	a.pressed = true
	Input.parse_input_event(a)
	
	Builder._data.dungeon_number = _dungeon_number.value - 1


func _on_spinbox_dungeon_number_focus_exited():
	var a = InputEventKey.new()
	a.scancode = KEY_ENTER
	a.pressed = true # change to false to simulate a key release
	Input.parse_input_event(a)
	
	Builder._data.dungeon_number = _dungeon_number.value - 1
	

func _on_DungeonEnabled_toggled(button_pressed):
	Builder._config.dungeon_enabled[Builder._config.game_id][Builder._data.dungeon_number] = int(button_pressed)
	

func _on_Node2D_tree_exiting():
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()


func _return_to_main_menu():
	var _s = get_tree().change_scene("res://2d/source/scenes/main_menu.tscn")
