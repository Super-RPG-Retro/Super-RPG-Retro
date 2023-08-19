"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


var _sprite = []

# select a dictionary from the available list then click the add button to go to a different scene where you select the items to add to the inventory.
@onready var _item_list_select_dictionary := $Container/Grid/Grid4/ItemListSelectDictionary

# items selected from the item list node is placed into this node.
@onready var _item_list_add_these_to_inventory := $Container/Grid/Grid6/ItemListAddTheseToInventory

# the total amount of each item in the inventory. if you selected an apple and an orange to be added to the above list and this amount was set to 5 then you would have 5 apples and 5 oranges.
@onready var _stack_amount := $Container/Grid/Grid9/SpinboxAmount

@onready var _event_number := $Container/Grid/Grid8/EventSpinbox

@onready var _event_enabled := $Container/Grid/Grid10/EventEnabled

# the builder menu.
@onready var _menu = null


func _ready():
	Variables._at_scene = Enum.Scene.Builder
	Variables._scene_title = "Builder: Event Inventory."
	
	_event_number.value = Builder._event_inventory.data.event_number + 1
	_on_event_number_Spinbox_value_changed(_event_number.value)
	
	if _menu == null:
		_menu = load("res://2d/source/scenes/builder/menu.tscn").instantiate()
		add_child( _menu )

	_item_list_select_dictionary.select(Variables._dictionary_index, true)
	if _item_list_add_these_to_inventory.get_item_count() > 0:
		_item_list_add_these_to_inventory.select(1, true)
	
func _on_event_number_Spinbox_value_changed(value):
	Builder._event_inventory.data.event_number = value - 1
	
	# if there inventory items to display at ItemList...	
	for _r in range(20):
		if Builder._event_inventory.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number][_r].is_empty() == false:
			# loop thur those items...
			for _i in range (Builder._event_inventory.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number][_r].size()):
				# add the textures
				_sprite.append([])
				_sprite[_sprite.size() - 1] = Sprite2D.new()
				_sprite[_sprite.size() - 1].texture = Filesystem._load_external_image(Builder._event_inventory.data.image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number][_r][_i])
				_item_list_add_these_to_inventory.add_icon_item(_sprite[_sprite.size() - 1].texture, false)
				
				# add the items to the ItemList.
				_item_list_add_these_to_inventory.add_item(Builder._event_inventory.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number][_r][_i], null, true)
		
	# is this event enabled?
	if bool(Builder._event_inventory.data.event_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number]) == true:
		_event_enabled.button_pressed = true
	else:
		_event_enabled.button_pressed = false	
	
	_stack_amount.value = Builder._event_inventory.data.amount[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number]
	
	
func _on_amount_Spinbox_value_changed(value):
	# update the builder event_enabled data. 	
	Builder._event_inventory.data.amount[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number] = value
	

func _on_event_Enabled_toggled(button_pressed):
	# update the builder event_enabled data. 	
	Builder._event_inventory.data.event_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number] = button_pressed
	
	
func _on_accepting_Enabled_toggled(button_pressed):
	Builder._event_inventory.data.accepting_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number] = button_pressed
	
	
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
		3: Variables._dictionary_name = "food"
		4: Variables._dictionary_name = "gold"
		5: Variables._dictionary_name = "ring"
		6: Variables._dictionary_name = "scroll"
		7: Variables._dictionary_name = "wand"
		8: Variables._dictionary_name = "weapon"
	
	# these two files are needed before calling the below scene.
	Variables.select_json_dictionary_singly = false
	Variables.select_items_data_to_return = Enum.Select_items.Event_inventory
	
	var _scene = get_tree().change_scene_to_file("res://2d/source/scenes/builder/select_json_dictionary_as_items.tscn")
	

func _on_prize_item_list_remove_Button_pressed():
	var _i = 0
	
	# this code removes the selected item(s) from the ItemList node.
	
	# _i is increments here the bottom of this code block. increment _i until _i equals max items in list.
	while _i < _item_list_add_these_to_inventory.get_item_count():
		
		# get the text of the ItemList at row _i.
		var _text = _item_list_add_these_to_inventory.get_item_text(_i)
		
		# enter this code block if the _i row is selected.
		if _item_list_add_these_to_inventory.is_selected(_i):		
			# for every directory...
			for _r in range (20):
				# ... check if directory contents _text.
				if Builder._event_inventory.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number][_r].has(_text):
					# Searches the array for a value and returns its index or -1 if not found..
					var _found = Builder._event_inventory.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number][_r].find(_text)
					
					# remove the item from the ItemList.	
					_item_list_add_these_to_inventory.remove_item(_i)
					_item_list_add_these_to_inventory.remove_item(_i-1)
					
					# remove the item from builder vars.
					Builder._event_inventory.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number][_r].pop_at(_found)
					
					Builder._event_inventory.data.file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number][_r].pop_at(_found)
					
					Builder._event_inventory.data.image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number][_r].pop_at(_found)
					
					Builder._event_inventory.data.directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_inventory.data.event_number][_r].pop_at(_found)
		
		else:
			_i += 1
	
	
func _on_Node2D_tree_exiting():
	for _i in _sprite.size():
		_sprite[_i].free()
		
	queue_free()
