"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends MenuButton


var _menu_rooms

func _ready():
	_menu_rooms = get_popup()	
	
	_menu_rooms.set_name("Events" + Variables._menu_padding)
	
	_menu_rooms.add_item("Parent" + Variables._menu_padding)
	_menu_rooms.add_item("Story" + Variables._menu_padding)
	_menu_rooms.add_item("Locked Doors" + Variables._menu_padding)
	_menu_rooms.add_item("Puzzles" + Variables._menu_padding)
	_menu_rooms.add_item("Hunting Tasks" + Variables._menu_padding)
	_menu_rooms.add_item("Inventory" + Variables._menu_padding)
		
	_menu_rooms.connect("id_pressed", self, "_on_menu_rooms_item_pressed")
		
	
func _process(_delta):
	if Builder._config.dungeon_enabled[Builder._config.game_id][Builder._config.dungeon_number - 1] == 0:
		_menu_rooms.set_item_disabled(0, false) #"Edit:
		_menu_rooms.set_item_disabled(1, false) 
		_menu_rooms.set_item_disabled(2, false) 
		_menu_rooms.set_item_disabled(3, false) 
		_menu_rooms.set_item_disabled(4, false) 
		

func _input(_event):
	if _menu_rooms.has_focus() == true:
		Variables.a.scancode = 0

		
func _on_menu_rooms_item_pressed(ID):
	match ID:
		0:
			var _scene = get_tree().change_scene("res://2d/source/scenes/builder/events/parent.tscn")
		
		1:
			var _scene = get_tree().change_scene("res://2d/source/scenes/builder/events/story.tscn")
		
		2:
			var _scene = get_tree().change_scene("res://2d/source/scenes/builder/events/locked_doors.tscn")
		
		3:
			var _scene = get_tree().change_scene("res://2d/source/scenes/builder/events/puzzles.tscn")
		
		4:
			var _scene = get_tree().change_scene("res://2d/source/scenes/builder/events/hunting_tasks.tscn")
		
		5:
			var _scene = get_tree().change_scene("res://2d/source/scenes/builder/events/inventory.tscn")


func _on_exiting_tree(_node):
	call_deferred("remove_child", _menu_rooms)
	call_deferred("queue_free", _menu_rooms)
	
	queue_free()
