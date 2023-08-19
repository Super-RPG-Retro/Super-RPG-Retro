"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


@onready var _group_item_list_add := $Container/Grid/Grid4/ItemListAdd

@onready var _group_item_list_remove := $Container/Grid/Grid6/ItemListRemove

@onready var _event_number := $Container/Grid/Grid8/EventSpinbox

@onready var _dungeon_number := $Container/Grid/Grid10/DungeonNumberSpinbox

@onready var _level_number := $Container/Grid/Grid1/LevelNumberSpinbox

@onready var _event_enabled := $Container/Grid/Grid5/EventEnabled

#Ask if player will accept to do this event? Otherwise, event is cancelled.
@onready var _accepting_enabled := $Container/Grid/Grid12/AcceptingEnabled

# this is the text asking if player accepts this event.
@onready var _accepting_question := $Container/Grid/Grid11/AcceptQuestionTextEdit

# the builder menu.
@onready var _menu = null


func _ready():
	Variables._at_scene = Enum.Scene.Builder
	Variables._scene_title = "Builder: Event Parent."
	
	_event_number.value = Builder._event_parent.event_number + 1
	_on_event_number_Spinbox_value_changed(_event_number.value)
	
	if _menu == null:
		_menu = load("res://2d/source/scenes/builder/menu.tscn").instantiate()
		add_child( _menu )

	_group_item_list_add.select(Variables._dictionary_index, true)
	
	if _group_item_list_remove.get_item_count() > 0:
		_group_item_list_remove.select(1, true)
	
func _on_event_number_Spinbox_value_changed(value):
	Builder._event_parent.event_number = value - 1
	
	_group_item_list_remove.clear()
	
	# dictionaries..	
	for _r in range(20):
		# add the current prize rewards.
		if Builder._event_parent.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][_r].is_empty() == false:
			for _i in range (Builder._event_parent.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][_r].size()):
				# add the textures
				var _image = TextureRect.new()
				_image.texture = Filesystem._load_external_image(Builder._event_parent.image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][_r][_i])
				_group_item_list_remove.add_icon_item(_image.texture, false)
				
				_group_item_list_remove.add_item(Builder._event_parent.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][_r][_i], null, true)
		
	# is this event enabled?
	if bool(Builder._event_parent.event_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number]) == true:
		_event_enabled.button_pressed = true
	else:
		_event_enabled.button_pressed = false	
		
	if bool(Builder._event_parent.accepting_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number]) == true:
		_accepting_enabled.button_pressed = true
	else:
		_accepting_enabled.button_pressed = false	
		
	_dungeon_number.value = Builder._event_parent.dungeon_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number] + 1
	
	_level_number.value = Builder._event_parent.level_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number] + 1
	
	_accepting_question.text = Builder._event_parent.accepting_text[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number]
	

func _on_event_Enabled_toggled(button_pressed):
	Builder._event_parent.event_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number] = button_pressed
	

func _on_accepting_Enabled_toggled(button_pressed):
	Builder._event_parent.accepting_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number] = button_pressed
	
	
func _on_dungeon_number_Spinbox_value_changed(value):
	# store the current value in to the builder var.
	Builder._event_parent.dungeon_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number]  = value - 1
	

func _on_level_number_Spinbox_value_changed(value):
	Builder._event_parent.level_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number] = value - 1
	
	
func _on_StatusBar_tree_exiting():
	
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()


func _return_to_main_menu():
	var _s = get_tree().change_scene_to_file("res://3d/scenes/gridmap.tscn")


func _on_dictionary_ItemList_item_selected(index):
	Variables._dictionary_index = index
	

func _on_prize_item_list_add_Button_pressed():
	match Variables._dictionary_index:
		0: Variables._dictionary_name = "amulet"
		1: Variables._dictionary_name = "armor"
		2: Variables._dictionary_name = "book"
		3: Variables._dictionary_name = "mobs1"
		4: Variables._dictionary_name = "mobs2"
		5: Variables._dictionary_name = "food"
		6: Variables._dictionary_name = "gold"
		7: Variables._dictionary_name = "ring"
		8: Variables._dictionary_name = "scroll"
		9: Variables._dictionary_name = "wand"
		10: Variables._dictionary_name = "weapon"
	
	# these two files are needed before calling the below scene.
	Variables.select_json_dictionary_singly = false
	Variables.select_items_data_to_return = Enum.Select_items.Event_prize	
	
	var _scene = get_tree().change_scene_to_file("res://2d/source/scenes/builder/select_json_dictionary_as_items.tscn")
	

func _on_prize_item_list_remove_Button_pressed():
	var _i = 0
	
	# this code removes the selected item(s) from the ItemList node.
	
	# _i is increments here the bottom of this code block. increment _i until _i equals max items in list.
	while _i < _group_item_list_remove.get_item_count():
		
		# get the text of the ItemList at row _i.
		var _text = _group_item_list_remove.get_item_text(_i)
		
		# enter this code block if the _i row is selected.
		if _group_item_list_remove.is_selected(_i):		
			# for every directory...
			for _r in range (20):
				# ... check if directory contents _text.
				if Builder._event_parent.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][_r].has(_text):
					# Searches the array for a value and returns its index or -1 if not found..
					var _found = Builder._event_parent.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][_r].find(_text)
					
					# remove the item from the ItemList.	
					_group_item_list_remove.remove_item(_i)
					_group_item_list_remove.remove_item(_i-1)
					
					# remove the item from builder vars.
					Builder._event_parent.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][_r].pop_at(_found)
					
					Builder._event_parent.file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][_r].pop_at(_found)
					
					Builder._event_parent.image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][_r].pop_at(_found)
					
					Builder._event_parent.directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][_r].pop_at(_found)
		
		else:
			_i += 1
	

func _on_accepting_question_TextEdit_text_changed():
	Builder._event_parent.accepting_text[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number] = _accepting_question.text
	
