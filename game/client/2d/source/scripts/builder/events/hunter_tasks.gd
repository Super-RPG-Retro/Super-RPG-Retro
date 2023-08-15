"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


var _sprite = Sprite2D.new()

@onready var _item_list_select_dictionary := $Container/Grid/Grid4/ItemListSelectDictionary

# this is the target for the event.
@onready var _item_list_do_this_task := $Container/Grid/Grid6/ItemListDoThisTask

@onready var _event_number := $Container/Grid/Grid9/EventSpinbox

@onready var _event_enabled := $Container/Grid/Grid11/EventEnabled

# the builder menu.
@onready var _menu = null


func _ready():
	Variables._at_scene = Enum.Scene.Builder
	# used at title_bar. see HeaderMenu node.
	Variables._scene_title = "Builder: Event Hunting Tasks."
	
	_event_number.value = Builder._event_tasks.data.event_number + 1
	_on_event_number_Spinbox_value_changed(_event_number.value)
	
	if _menu == null:
		_menu = load("res://2d/source/scenes/builder/menu.tscn").instantiate()
		add_child( _menu )

	_item_list_select_dictionary.select(Variables._dictionary_index, true)
	
	if _item_list_do_this_task.get_item_count() > 0:
		_item_list_do_this_task.select(1, true)


func _on_event_number_Spinbox_value_changed(value):
	Builder._event_tasks.data.event_number = value - 1
	
	_item_list_do_this_task.clear()
			
	# add the task to the ItemList.
	# the task could be any object.
	for _r in range (20):
		for _i in range (Builder._event_tasks.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number][_r].size()):
			
			# add the textures
			_sprite.texture = Filesystem._load_external_image(Builder._event_tasks.data.image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number][_r][_i])
			_item_list_do_this_task.add_icon_item(_sprite.texture, false)
			
			# ItemList task.
			_item_list_do_this_task.add_item(Builder._event_tasks.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number][_r][_i], null, true)
		
			
	if bool(Builder._event_tasks.data.event_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number]) == true:
		_event_enabled.button_pressed = true
	else:
		_event_enabled.button_pressed = false	
	

func _on_EventEnabled_toggled(button_pressed):
	# update the builder event_enabled data. 	
	Builder._event_tasks.data.event_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number] = button_pressed
	
	
func _on_StatusBar_tree_exiting():
	
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()


func _return_to_main_menu():
	var _s = get_tree().change_scene_to_file("res://3d/scenes/Gridmap.tscn")


func _on_dictionary_ItemList_item_selected(index):
	Variables._dictionary_index = index

	
func _on_prize_item_list_add_Button_pressed():
	match Variables._dictionary_index:
		0: Variables._dictionary_name = "mobs1"
		1: Variables._dictionary_name = "mobs2"
	
	# these two files are needed before calling the below scene.
	Variables.select_json_dictionary_singly = true
	Variables.select_items_data_to_return = Enum.Select_items.Event_hunting_tasks	
	
	var _scene = get_tree().change_scene_to_file("res://2d/source/scenes/builder/select_json_dictionary_as_items.tscn")
	
	
func _on_prize_item_list_remove_Button_pressed():
	var _i = 0
	
	# this code removes the selected item(s) from the ItemList node.
	
	# _i is increments here the bottom of this code block. increment _i until _i equals max items in list.
	while _i < _item_list_do_this_task.get_item_count():
		
		# get the text of the ItemList at row _i.
		var _text = _item_list_do_this_task.get_item_text(_i)
		
		# enter this code block if the _i row is selected.
		if _item_list_do_this_task.is_selected(_i):		
			# for every directory...
			for _r in range (20):
				# ... check if directory contents _text.
				if Builder._event_tasks.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number][_r].has(_text):
					# Searches the array for a value and returns its index or -1 if not found..
					var _found = Builder._event_tasks.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number][_r].find(_text)
					
					# remove the item from the ItemList.	
					_item_list_do_this_task.remove_item(_i)
					_item_list_do_this_task.remove_item(_i-1)
					
					# remove the item from builder vars.
					Builder._event_tasks.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number][_r].pop_at(_found)
					
					Builder._event_tasks.data.file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number][_r].pop_at(_found)
					
					Builder._event_tasks.data.image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number][_r].pop_at(_found)
					
					Builder._event_tasks.data.directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number][_r].pop_at(_found)
					

		else:
			_i += 1
	

func _on_Node2D_tree_exiting():
	_sprite.free()
		
	queue_free()
