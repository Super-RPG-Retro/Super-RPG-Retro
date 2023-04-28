"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends MenuButton


var _menu_rooms
var _menu_rooms_sub = PopupMenu.new()
var _menu_rooms_sub2 = PopupMenu.new()


func _ready():
	_menu_rooms = get_popup()
	
	_menu_rooms_sub.set_name("New" 		+ Variables._menu_padding)
	_menu_rooms_sub.add_item("Mobs 1" 	+ Variables._menu_padding)
	_menu_rooms_sub.add_item("Mobs 2" 	+ Variables._menu_padding)
	
	_menu_rooms_sub.add_item("Amulet" 	+ Variables._menu_padding)
	_menu_rooms_sub.add_item("Armor" 	+ Variables._menu_padding)
	_menu_rooms_sub.add_item("Book" 	+ Variables._menu_padding)
	_menu_rooms_sub.add_item("Food" 	+ Variables._menu_padding)
	_menu_rooms_sub.add_item("Gold" 	+ Variables._menu_padding)
	_menu_rooms_sub.add_item("Ring" 	+ Variables._menu_padding)
	_menu_rooms_sub.add_item("Scroll" 	+ Variables._menu_padding)
	_menu_rooms_sub.add_item("Wand" 	+ Variables._menu_padding)
	_menu_rooms_sub.add_item("Weapon" 	+ Variables._menu_padding)
	
	
	_menu_rooms.add_child(_menu_rooms_sub)
	_menu_rooms.add_submenu_item("Objects New", "New" + Variables._menu_padding)
	
	_menu_rooms_sub2.set_name("Edit"	+ Variables._menu_padding)
	_menu_rooms_sub2.add_item("Mobs 1" 	+ Variables._menu_padding)
	_menu_rooms_sub2.add_item("Mobs 2" 	+ Variables._menu_padding)
	
	_menu_rooms_sub2.add_item("Amulet" 	+ Variables._menu_padding)
	_menu_rooms_sub2.add_item("Armor" 	+ Variables._menu_padding)
	_menu_rooms_sub2.add_item("Book" 	+ Variables._menu_padding)
	_menu_rooms_sub2.add_item("Food" 	+ Variables._menu_padding)
	_menu_rooms_sub2.add_item("Gold" 	+ Variables._menu_padding)
	_menu_rooms_sub2.add_item("Ring" 	+ Variables._menu_padding)
	_menu_rooms_sub2.add_item("Scroll" 	+ Variables._menu_padding)
	_menu_rooms_sub2.add_item("Wand" 	+ Variables._menu_padding)
	_menu_rooms_sub2.add_item("Weapon" 	+ Variables._menu_padding)
	
	_menu_rooms.add_child(_menu_rooms_sub2)
	_menu_rooms.add_submenu_item("Objects Edit", "Edit" + Variables._menu_padding)
	
	_menu_rooms.add_item("Artifacts" 	+ Variables._menu_padding)
	_menu_rooms.add_item("Starting Statistics" 	+ Variables._menu_padding)
	
	_menu_rooms_sub.connect("id_pressed", self, "_on_menu_rooms_sub_item_pressed1")
	_menu_rooms_sub2.connect("id_pressed", self, "_on_menu_rooms_sub_item_pressed2")
		
	_menu_rooms.connect("id_pressed", self, "_on_menu_rooms_item_pressed")


# hide the artifact menu if no artifacts are enabled.
func _process(_delta):
	if Builder._dictionary_artifacts.data.file_name[0] == "":
		_menu_rooms.set_item_disabled(2, true)
	else:
		_menu_rooms.set_item_disabled(2, false)


func _input(event):
	if _menu_rooms.has_focus() == true || _menu_rooms_sub.has_focus() == true || _menu_rooms_sub2.has_focus() == true:
		Variables.a.scancode = 0
		

func _on_menu_rooms_sub_item_pressed1(ID):
	Common.directory_names(ID)
			
	var _scene = get_tree().change_scene("res://2d/source/scenes/builder/dictionary/objects_new.tscn")
		

func _on_menu_rooms_sub_item_pressed2(ID):
	Common.directory_names(ID)
		
	var _scene = get_tree().change_scene("res://2d/source/scenes/builder/dictionary/objects_edit.tscn")

	
func _on_menu_rooms_item_pressed(ID):
	match ID:
		2:		
			var _scene = get_tree().change_scene("res://2d/source/scenes/builder/dictionary/artifacts.tscn")
	
		3:		
			var _scene = get_tree().change_scene("res://2d/source/scenes/builder/dictionary/starting_statistics.tscn")
	
	
func _on_exiting_tree(_node):
	call_deferred("remove_child", _menu_rooms)
	call_deferred("queue_free", _menu_rooms)
	
	call_deferred("remove_child", _menu_rooms_sub)
	call_deferred("queue_free", _menu_rooms_sub)
		
	queue_free()
