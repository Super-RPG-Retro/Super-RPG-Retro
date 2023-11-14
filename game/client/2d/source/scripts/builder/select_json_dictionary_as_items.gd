"""
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# the selected json dictionary item, if any, is send to this sub_select_dictionaries.gd scene. this scene can be opened in multi item select or single item select mode.

# if coping this file for use at game_world, remember to replace Builder var with Builder_playing var.
extends Node2D


# _column_d is the dictionary column that was selected using the sort button.
var _d_column
	
# select a column that you would like to sort...
@onready var _item_list := $ItemList
# then press this button to sort all items from least to greatest.
@onready var _button_sort := $ButtonSort

# this is the large button that highlights a grid row.
@onready var _select_button := $SelectButton

@onready var _grid_dynamic := $Panel/EventContainerItemsDynamic/Grid
@onready var _scroll := $Panel/EventContainerItemsStatic
@onready var _scroll2 := $Panel/EventContainerItemsDynamic

var _item_name		:= []
var _image 			:= []
var _check_button 	:= []
var _category 		:= []

# the name of the item currently selected.
var _selected_item_name := ""

var _cha := []
var _con := []
var _def := []
var _dex := []
var _int := []
var _luc := []
var _per := []
var _str := []
var _wis := []
var _wil := []

var _data_file_name 		:= []
var _data_file_path_json 	:= []
var _data_image_texture 	:= []
var _data_directory_name 	:= []

# this is the number of the checkbox selected. the other var that also refer to this number is _i which is used in a loop at ready func and also as _on_focus_entered() parameter
var _num := -1
# this var does not get reset back to -1. it is used to save the pressed state of the checkbox to builder.
var _num_current := -1

var _item_list_current_index := 0

# this is used to loop thur the file_names searching for an item incrementing in order, an item that is visible. once found this value will be set to true.
# this var is used to checkmark the first visible item in the list.
var _found_first_item := false

# this var stops the adding of a node to scene when it has already been added to scene.
var _nodes_added_to_scene := false

var _mouse_clicked := false


func _ready():
	# select the first index in the list.
	_item_list.select(Variables._item_list_current_index)
	
	_item_list_current_index = Variables._item_list_current_index
	
	_item_list.get_v_scroll_bar().value = Variables._item_list_current_scroll_value
		
	_scroll.get_h_scroll_bar().modulate = Color(0, 0, 0, 0)
	
	_populate_data_vars()
	
	Variables._at_scene = Enum.Scene.Builder
	Variables._scene_title = "Builder: Events Dictionaries."
	
	_sort()
	
	
func _process(_delta):
	_scroll.scroll_horizontal = _scroll2.scroll_horizontal
	
	# current position of the mouse cursor.
	Variables._mouse_cursor_position.x = get_global_mouse_position().x
	Variables._mouse_cursor_position.y = get_global_mouse_position().y
	
	if Variables._mouse_cursor_position.y > 570: # bottom of screen.
		# this is the button that follows the cursor.
		_select_button.position.y = 556
		
	elif Variables._mouse_cursor_position.y >= 209: # current starting location.
		_select_button.position.y = Variables._mouse_cursor_position.y + 242
	else:
		_select_button.position.y = 194
		

func _input(event):
	if(event.is_pressed()):
		if event.is_action_pressed("ui_escape", true):
			_on_ButtonExit_pressed()
	
	# this stops setting more than one radio button to active simultaneously.
	if event is InputEventKey and event.pressed and Variables.select_json_dictionary_singly == true:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			for _i in _check_button.size():
				_check_button[_i].button_pressed = false
					
	if event is InputEventMouseButton and event.released and event.button_index == MOUSE_BUTTON_LEFT and Variables._mouse_cursor_position.x <= 996 and Variables._mouse_cursor_position.y >= 189 and Variables._mouse_cursor_position.y <= 588:
		_mouse_clicked = true
		
		# clear all other CheckBox if using singly item mode.
		if Variables.select_json_dictionary_singly == true:
			#looping through the group node children and uncheck every one except the sender checkbox
			for _i in _check_button.size():
				_check_button[_i].button_pressed = false
				
		var _i = -1
		
		for _fn in Variables._file_names:
			var _split = _fn.split("/")
			_i += 1
				
			# if code reached the end index of the array, break out of the loop to avoid a null array crash.
			if _i >= Variables._file_names.size():
				break
								
			# 41 is the offset value between SelectButton at the first CheckBox. 32 is the width of the SelectButton.
			if Variables._mouse_cursor_position.y >= 189:
				if Variables._mouse_cursor_position.y + 55 + _scroll2.scroll_vertical <= _check_button[_i].position.y:
					_selected_item_name = _split[1]
					
					if Variables.select_json_dictionary_singly == false:
						_check_button[_i].button_pressed = !_check_button[_i].button_pressed
						_num = _i
						_save_builder_data()
						
					else:
						_check_button[_i].button_pressed = true
						_num = _i
						_save_builder_data()
						
					_check_button[_i].grab_focus()
					
					break

	_num = -1
	Variables._item_list_current_scroll_value = _item_list.get_v_scroll_bar().value

func _sort():
	# Variables._item_list_current_index holds the state of the item list node. this gets the current name from the item list node.
	var _current_item_selected = _item_list.get_item_text(Variables._item_list_current_index)
		
	_data_file_name.clear()
	_data_file_path_json.clear()
	_data_image_texture.clear()
	_data_directory_name.clear()
	
	Json.make_directories()
	Json.refresh_dictionaries(Variables._project_path + "/builder/objects/data/" + str(Builder._config.game_id + 1) + "/" + Variables._dictionary_name + "/")
	
	# create the array indexes.
	# id
	for w in range (Variables._total_builder_data_directories):
		_data_file_name.append([])
		_data_file_path_json.append([])
		_data_image_texture.append([])
		_data_directory_name.append([])
		
		# dungeon number
		for x in range (8):
			_data_file_name[w].append([])
			_data_file_path_json[w].append([])
			_data_image_texture[w].append([])
			_data_directory_name[w].append([])
			
			# ebent number
			for y in range (100):
				_data_file_name[w][x].append([])
				_data_file_path_json[w][x].append([])
				_data_image_texture[w][x].append([])
				_data_directory_name[w][x].append([])
				
				# directory index
				for _z in range (20):
					_data_file_name[w][x][y].append([])
					_data_file_path_json[w][x][y].append([])
					_data_image_texture[w][x][y].append([])
					_data_directory_name[w][x][y].append([])
	
	# Variables._dictionary_name is the mobs folder, weapon folder, etc.
	
	# If deep is true, a deep copy is performed: all nested arrays and dictionaries are duplicated and will not be shared with the original array. If false, a shallow copy is made and references to the original nested arrays and dictionaries are kept, so that modifying a sub-array or dictionary in the copy will also impact those referenced in the source array.
	Variables._image_textures = Variables._file_paths.duplicate(true)
	
	
	_d_column = Common._sort(Json._directory_number[str(Builder._config.game_id)][Variables._dictionary_name], _current_item_selected, _item_list_current_index)
	
	var _do_once = true
			
	# this refers to the row number of the grid or the number of the current file name in a list.
	var _i = -1
	var _uncheck_first_item = 0
	
	_found_first_item = false
	
	for _key in Variables._file_names:
		_i += 1
		# if code reached the end index of the array, break out of the loop to avoid a null array crash.
		if _i >= Variables._file_names.size():
			break
				
		_draw_dictionary_items(_key, _i)
		
		# this code is needed so that the first item in the list, which might not have a value of 0, is set to focused.
		if _found_first_item == true and _do_once == true:
			_do_once = false
			
			_set_focus_to_nodes()
			
			# when this scene first loads, no item should be in a pressed state. in doing so, items will not display correctly when returning to scene.
			_uncheck_first_item = _i
			_num = _i
			_save_builder_data()
			
	_check_button[_uncheck_first_item].button_pressed = false
	_nodes_added_to_scene = true
	
	_save_builder_data()
	
	_scroll2.scroll_vertical = 0
	_num = -1
	
	Variables._file_names_default = Variables._file_names.duplicate()
	Variables._image_textures_default = Variables._image_textures.duplicate()


# add the text/image of the selected dictionary to the columns and rows of the grid nodes.	
func _draw_dictionary_items(_key, _i:int):
	# the name of the dictionary, such as bear or small bow. get just the name of the directory file so that it can be displayed in a grid.
	var _file_name
	
	
	_file_name = Variables._file_names[_i].split("/")
	
	var _index = _file_name[0]
	var _key_temp = _key.split("/")
	_key = _key_temp[1]
			
	# _event is used to show items in the grid list. an item will be displayed if _event has a value of 0.
	var _event:int
	
	if _nodes_added_to_scene == false:
		if Variables.select_items_data_to_return == Enum.Select_items.Event_prize:
			# since the event_number will not be modified and more than one sceme uses this scene, set the general _event_number of this scene to use the scene's event_number that called this scene. 
			Builder._data.event_number = Builder._event_parent.event_number
			
			_event = 0
			
			var _find = Builder._event_parent.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].find(_file_name[1])
			
			# set this to true then item has already been added to the scene that called this scene. set _event var to 1 so that this grid row can be hidden.
			if _find != -1:
				_event = 1
				
		
		# if this is event tasks then search every dictionary file name in this var. if found then that means the file is in use at hunting task scene.
		if Variables.select_items_data_to_return == Enum.Select_items.Event_hunting_tasks:
			Builder._data.event_number = Builder._event_tasks.data.event_number
			
			_event = 0
		
			var _find = Builder._event_tasks.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].find(_file_name[1])
				
			if _find != -1:
				_event = 1
				
				
		if Variables.select_items_data_to_return == Enum.Select_items.Event_inventory:
			Builder._data.event_number = Builder._event_inventory.data.event_number
			
			_event = 0
			
			var _find = Builder._event_inventory.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].find(_file_name[1])
				
			if _find != -1:
				_event = 1
		
		
		if Variables.select_items_data_to_return == Enum.Select_items.Event_story:
			Builder._data.event_number = Builder._event_story.data.event_number
			
			_event = 0
		
			var _find = Builder._event_story.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].find(_file_name[1])
				
			if _find != -1:
				_event = 1
		
			
	# Replaces occurrences of a case-sensitive substring with the given one inside the string.
	Variables._image_textures[_i] = Variables._image_textures[_i].replace(".json", "/1.png")
	Variables._image_textures[_i] = Variables._image_textures[_i].replace("/builder/objects/data/", "/builder/objects/images/dictionaries/")
	
	
	if _nodes_added_to_scene == false:
		_check_button.append([])
		_check_button[_i] = CheckBox.new()
		_check_button[_i].add_to_group("grid_container")
		_grid_dynamic.add_child(_check_button[_i])
		_check_button[_i].button_pressed = false
		
		# here are the signals for all checkbox, these signals will capture the entering and exiting of any checkbox and will then go to the respective func. The toggle signal will go to a toggle func when the mouse or space/enter key is pressed.
		if _check_button[_i].is_connected("focus_entered", Callable(self, "_on_focus_entered")):
			_check_button[_i].disconnect("focus_entered", self, "_on_focus_entered", [_i])
			
		# create the signals for the mouse entering /exiting the nodes.
		var _x = _check_button[_i].connect("focus_entered", Callable(self, "_on_focus_entered").bind(_i))
		
		if _check_button[_i].is_connected("focus_exited", Callable(self, "_on_focus_exited")):
			_check_button[_i].disconnect("focus_exited", Callable(self, "_on_focus_exited"))

		var _y = _check_button[_i].connect("focus_exited", Callable(self, "_on_focus_exited"))
				
		if _check_button[_i].is_connected("toggled", Callable(self, "_on_item_toggled")):
			_check_button[_i].disconnect("toggled", Callable(self, "_on_item_toggled"))

		var _z = _check_button[_i].connect("toggled", Callable(self, "_on_item_toggled"))
			
			
		# check the first CheckBox. User can then change focus using the arrow keys. 
		if _event == 1:
			_check_button[_i].button_pressed = true
			_check_button[_i].visible = false
			
			_save_builder_data()
			_num = _i
						
		elif _found_first_item == false:
			_found_first_item = true
			
			_check_button[_i].button_pressed = true
			_num = _i
		
		if _nodes_added_to_scene == false:
			if Variables.select_json_dictionary_singly == true:
				_check_button[_i].button_group = ButtonGroup.new()
		
			
	if _nodes_added_to_scene == false:
		_image.append([])
		_image[_i] = TextureRect.new()
		_grid_dynamic.add_child(_image[_i])
		_image[_i].add_to_group("grid_container")
		if _event == 1:
			_image[_i].visible = false
	_image[_i].texture = Filesystem._load_external_image(Variables._image_textures[_i])
	
		
	if _nodes_added_to_scene == false:
		_item_name.append([])
		_item_name[_i] = Label.new()
		_item_name[_i].add_to_group("grid_container")
		_grid_dynamic.add_child(_item_name[_i])
		if _event == 1:
			_item_name[_i].visible = false
	
	# do not display long file names. instead add "..." to the end of long file names.
	if _file_name[1].length() >= 21:
		_item_name[_i].text = _file_name[1].substr(0, 21) + "..."
	else:
		_item_name[_i].text = _file_name[1]
	
	if _selected_item_name == "":
		_selected_item_name = _item_name[_i].text
		_num = _i
		
	
	if _nodes_added_to_scene == false:
		_category.append([])
		# display the category.
		_category[_i] = Label.new()
		_category[_i].add_to_group("grid_container")
		_grid_dynamic.add_child(_category[_i])
		if _event == 1:
			_category[_i].visible = false
	
	_category[_i].text = _index
	

	if _nodes_added_to_scene == false:
		_cha.append([])
		_cha[_i] = Label.new()
		_cha[_i].add_to_group("grid_container")
		_grid_dynamic.add_child(_cha[_i])
		if _event == 1:
			_cha[_i].visible = false
	_cha[_i].text = str(Json._directory_number[str(Builder._config.game_id)][Variables._dictionary_name][_key].Charisma).pad_zeros(2)
	
	
	if _nodes_added_to_scene == false:
		_con.append([])
		_con[_i] = Label.new()
		_con[_i].add_to_group("grid_container")
		_grid_dynamic.add_child(_con[_i])
		if _event == 1:
			_con[_i].visible = false
	_con[_i].text = str(Json._directory_number[str(Builder._config.game_id)][Variables._dictionary_name][_key].Constitution).pad_zeros(2)
	
	
	if _nodes_added_to_scene == false:
		_def.append([])
		_def[_i] = Label.new()
		_def[_i].add_to_group("grid_container")
		_grid_dynamic.add_child(_def[_i])
		if _event == 1:
			_def[_i].visible = false
	_def[_i].text = str(Json._directory_number[str(Builder._config.game_id)][Variables._dictionary_name][_key].Defense).pad_zeros(2)
	

	if _nodes_added_to_scene == false:
		_dex.append([])
		_dex[_i] = Label.new()
		_dex[_i].add_to_group("grid_container")
		_grid_dynamic.add_child(_dex[_i])
		if _event == 1:
			_dex[_i].visible = false
	_dex[_i].text = str(Json._directory_number[str(Builder._config.game_id)][Variables._dictionary_name][_key].Dexterity).pad_zeros(2)
	

	if _nodes_added_to_scene == false:
		_int.append([])
		_int[_i] = Label.new()
		_int[_i].add_to_group("grid_container")
		_grid_dynamic.add_child(_int[_i])
		if _event == 1:
			_int[_i].visible = false
	_int[_i].text = str(Json._directory_number[str(Builder._config.game_id)][Variables._dictionary_name][_key].Intelligence).pad_zeros(2)
	

	if _nodes_added_to_scene == false:
		_luc.append([])
		_luc[_i] = Label.new()
		_luc[_i].add_to_group("grid_container")
		_grid_dynamic.add_child(_luc[_i])
		if _event == 1:
			_luc[_i].visible = false
	_luc[_i].text = str(Json._directory_number[str(Builder._config.game_id)][Variables._dictionary_name][_key].Luck).pad_zeros(2)
	

	if _nodes_added_to_scene == false:
		_per.append([])
		_per[_i] = Label.new()
		_per[_i].add_to_group("grid_container")
		_grid_dynamic.add_child(_per[_i])
		if _event == 1:
			_per[_i].visible = false
	_per[_i].text = str(Json._directory_number[str(Builder._config.game_id)][Variables._dictionary_name][_key].Perception).pad_zeros(2)
		

	if _nodes_added_to_scene == false:
		_str.append([])
		_str[_i] = Label.new()
		_str[_i].add_to_group("grid_container")
		_grid_dynamic.add_child(_str[_i])
		if _event == 1:
			_str[_i].visible = false
	_str[_i].text = str(Json._directory_number[str(Builder._config.game_id)][Variables._dictionary_name][_key].Strength).pad_zeros(2)
	

	if _nodes_added_to_scene == false:
		_wis.append([])
		_wis[_i] = Label.new()
		_wis[_i].add_to_group("grid_container")
		_grid_dynamic.add_child(_wis[_i])
		if _event == 1:
			_wis[_i].visible = false
	_wis[_i].text = str(Json._directory_number[str(Builder._config.game_id)][Variables._dictionary_name][_key].Wisdom).pad_zeros(2)
	

	if _nodes_added_to_scene == false:
		_wil.append([])
		_wil[_i] = Label.new()
		_wil[_i].add_to_group("grid_container")
		_grid_dynamic.add_child(_wil[_i])
		if _event == 1:
			_wil[_i].visible = false
	_wil[_i].text = str(Json._directory_number[str(Builder._config.game_id)][Variables._dictionary_name][_key].Willpower).pad_zeros(2)
	
	
	if _event == 0:
		var _found = _data_file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].find(_file_name[1])
		
		# if -1 then data not found, clear the list because this item has aready been added to the scene that called this scene.
		if _found != - 1:
			_data_file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].erase(_file_name[1])
			_data_file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].erase(Variables._file_paths[_i])
			_data_image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].erase(Variables._image_textures[_i])
			_data_directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].erase(Variables._dictionary_name)


func _set_focus_to_nodes():
	var _i = Variables._num_first_rune_selected
	
	_check_button[_i].grab_focus()
	_check_button[_i].name = "CheckButton-01"
				
	_check_button[_i].focus_previous = NodePath("../../../../ButtonSort")
	
	_check_button[_i].focus_neighbor_top = NodePath("../../../../ButtonSort")
	
	
	_button_sort.focus_previous = NodePath("../ItemList")
	
	_button_sort.focus_neighbor_left = NodePath("../ItemList")
	
	
	_button_sort.focus_next = NodePath("../Panel/EventContainerItemsDynamic/Grid/CheckButton-01")
	
	_button_sort.focus_neighbor_right = NodePath("../Panel/EventContainerItemsDynamic/Grid/CheckButton-01")
	
	_button_sort.focus_neighbor_bottom = NodePath("../Panel/EventContainerItemsDynamic/Grid/CheckButton-01")
	

	_item_list.focus_previous = NodePath("../ButtonBuy")
		
	_item_list.focus_neighbor_left = NodePath("../ButtonBuy")
		
	_item_list.focus_next = NodePath("../ButtonSort")
	
	_item_list.focus_neighbor_right = NodePath("../ButtonSort")

	
func _save_builder_data():
	if Variables.select_json_dictionary_singly == true:
		# clear the list so that any item will not have more than one listed of its type when returning to the scene that called this scene.
		_data_file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].clear()
		_data_file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].clear()
		_data_image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].clear()
		_data_directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].clear()
	
	
	var _file_name = Variables._file_names[_num].split("/")
	_modify_builder_list(_file_name[1])

	Filesystem.save("user://saved_data/builder_data_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._data)
	
	Filesystem.save("user://saved_data/builder_event_tasks_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_tasks.data)
	
	Filesystem.save("user://saved_data/builder_event_parent_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_parent)
	
	Filesystem.save("user://saved_data/builder_event_inventory_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_inventory.data)
	
	Filesystem.save("user://saved_data/builder_event_story_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_story.data)
	
# modify builder event vars. either add to the list or remove the item depending if the checkbox is checked or not.
func _modify_builder_list(_file_name):
	var _found = _data_file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].find(_file_name)
	
	# if -1 then data not found, so add it to the list.
	if _found == - 1:
		_data_file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].push_back(_file_name)
		_data_file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].push_back(Variables._file_paths[_num])
		_data_image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].push_back(Variables._image_textures[_num])
		_data_directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].push_back(Variables._dictionary_name)
	
	else:
		_data_file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].erase(_file_name)
		_data_file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].erase(Variables._file_paths[_num])
		_data_image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].erase(Variables._image_textures[_num])
		_data_directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].erase(Variables._dictionary_name)


# when this scene first opens, a call to this func is made, this scene's _data vars, which hold the list of items at grid node.
func _populate_data_vars():
	match (Variables.select_items_data_to_return):
		0:
			_data_file_name = Builder._event_parent.file_name.duplicate(true)
			_data_file_path_json = Builder._event_parent.file_path_json.duplicate(true)
			_data_image_texture = Builder._event_parent.image_texture.duplicate(true)
			_data_directory_name = Builder._event_parent.directory_name.duplicate(true)

		1:
			_data_file_name = Builder._event_tasks.data.file_name.duplicate(true)
			_data_file_path_json = Builder._event_tasks.data.file_path_json.duplicate(true)
			_data_image_texture = Builder._event_tasks.data.image_texture.duplicate(true)
			_data_directory_name = Builder._event_tasks.data.directory_name.duplicate(true)
		
		2:
			_data_file_name = Builder._event_inventory.data.file_name.duplicate(true)
			_data_file_path_json = Builder._event_inventory.data.file_path_json.duplicate(true)
			_data_image_texture = Builder._event_inventory.data.image_texture.duplicate(true)
			_data_directory_name = Builder._event_inventory.data.directory_name.duplicate(true)
		
		3:
			_data_file_name = Builder._event_story.data.file_name.duplicate(true)
			_data_file_path_json = Builder._event_story.data.file_path_json.duplicate(true)
			_data_image_texture = Builder._event_story.data.image_texture.duplicate(true)
			_data_directory_name = Builder._event_story.data.directory_name.duplicate(true)
		

# just before exiting this scene, the builder vars are poplauted with data from the _data vars, so when this scene closes, the scene that called this scene will have the correct data.
func _on_ButtonExit_pressed():
	match (Variables.select_items_data_to_return):
		0:
			Builder._event_parent.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
			
			Builder._event_parent.file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
			
			Builder._event_parent.image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
			
			Builder._event_parent.directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
			
			# remember to save builder data.
			Filesystem.save("user://saved_data/builder_event_parent_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_parent)

			var _s = get_tree().change_scene_to_file("res://2d/source/scenes/builder/events/parent.tscn")
	
		1:
			if _check_button[_num_current].button_pressed == true:
				# clear previous task, so that the item will display when user is selecting an item at at this file.
				for _r in range (20):
					if _r != Variables._dictionary_index:
						Builder._event_tasks.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number][_r] = []
						Builder._event_tasks.data.file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number][_r] = []
						Builder._event_tasks.data.image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number][_r] = []
						Builder._event_tasks.data.directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_tasks.data.event_number][_r] = []
					

				Builder._event_tasks.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
				
				Builder._event_tasks.data.file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
				
				Builder._event_tasks.data.image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
				
				Builder._event_tasks.data.directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
				
				# remember to save builder data.
				Filesystem.save("user://saved_data/builder_event_tasks_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_tasks.data)

			
			var _s = 	get_tree().change_scene_to_file("res://2d/source/scenes/builder/events/hunting_tasks.tscn")
		
		2:
			Builder._event_inventory.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
			
			Builder._event_inventory.data.file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
			
			Builder._event_inventory.data.image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
			
			Builder._event_inventory.data.directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
			
			Filesystem.save("user://saved_data/builder_event_inventory_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_inventory.data)

			var _s = get_tree().change_scene_to_file("res://2d/source/scenes/builder/events/inventory.tscn")

		
		3:
			if _check_button[_num_current].button_pressed == true:
				# clear previous task, so that the item will display when user is selecting an item at at this file.
				for _r in range (20):
					if _r != Variables._dictionary_index:
						Builder._event_story.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_story.data.event_number][_r] = []
						Builder._event_story.data.file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_story.data.event_number][_r] = []
						Builder._event_story.data.image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_story.data.event_number][_r] = []
						Builder._event_story.data.directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_story.data.event_number][_r] = []
					

				Builder._event_story.data.file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
				
				Builder._event_story.data.file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
				
				Builder._event_story.data.image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
				
				Builder._event_story.data.directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index] = _data_directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].duplicate(true)
				
				# remember to save builder data.
				Filesystem.save("user://saved_data/builder_event_story_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_story.data)

			
			var _s = 	get_tree().change_scene_to_file("res://2d/source/scenes/builder/events/story.tscn")
		
		
func _on_ButtonSort_pressed():
	var _z = get_tree().reload_current_scene()
	

# this is entered when the item list index is changed.
func _on_ItemList_item_selected(index):
	Variables._item_list_current_index = index
	
	
# _i refers to the checkbox node.
func _on_focus_entered(_i:int = 0):
	_num = _i
	_num_current = _num
	#_save_builder_data()

		
func _on_focus_exited():
	_num = -1


# this is entered when the checkbox is toggled using the arrow keys.
func _on_item_toggled(_state):
	if _nodes_added_to_scene == false or _mouse_clicked == true:
		_mouse_clicked = false
		return
	
	
	_num = _num_current
	
	if _state == true:
		_save_builder_data()
	
	else:
		var _file_name = Variables._file_names[_num].split("/")
		
		# checkbox is in an unchecked state, so remove the item so that it will not be saved nor added to the scene that called this scene.		
		_data_file_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].erase(_file_name[1])
		_data_file_path_json[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].erase(Variables._file_paths[_num])
		_data_image_texture[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].erase(Variables._image_textures[_num])
		_data_directory_name[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.event_number][Variables._dictionary_index].erase(Variables._dictionary_name)
		

func _on_Node2d_tree_exiting():
	for _i in range (_item_name.size()):
		_item_name[_i].free()
		_item_name[_i] = null
	
	for _i in range (_check_button.size()):
		_check_button[_i].free()
		_check_button[_i] = null
	
	for _i in range (_category.size()):
		_category[_i].free()
		_category[_i] = null
	
	for _i in range (_cha.size()):
		_cha[_i].free()
		_cha[_i] = null
	
	for _i in range (_con.size()):
		_con[_i].free()
		_con[_i] = null
	
	for _i in range (_def.size()):
		_def[_i].free()
		_def[_i] = null
	
	for _i in range (_dex.size()):
		_dex[_i].free()
		_dex[_i] = null
	
	for _i in range (_int.size()):
		_int[_i].free()
		_int[_i] = null
	
	for _i in range (_luc.size()):
		_luc[_i].free()
		_luc[_i] = null
	
	for _i in range (_per.size()):
		_per[_i].free()
		_per[_i] = null
	
	for _i in range (_str.size()):
		_str[_i].free()
		_str[_i] = null
	
	for _i in range (_wis.size()):
		_wis[_i].free()
		_wis[_i] = null
	
	for _i in range (_wil.size()):
		_wil[_i].free()
		_wil[_i] = null
			
	queue_free()
	
	
