"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# the selected json dictionary item, if any, is send to this sub_select_dictionaries.gd scene. this scene can be opened in multi item select or single item select mode.

# if coping this file for use at game_world,
extends Node2D

# _column_d is the dictionary column that was selected using the sort button.
var _d_column
	
# do not delete this node. it is needed for buying disabled message and for incrementing/decrements item purchase amount.
onready var _label_buy_disabled_message = $LabelBuyDisabledMessage

# select a column that you would like to sort...
onready var _item_list = $ItemList
# then press this button to sort all items from least to greatest.
onready var _button_sort = $ButtonSort

# this is the large button that highlights a grid row.
onready var _select_button = $SelectButton
onready var _button_buy = $ButtonBuy
onready var _dialog_buy = $DialogBuy
onready var _dialog_bought = $DialogBought
onready var _spinbox_amount = $SpinBoxAmount
onready var _gold_total = $LabelGold
# this is the total price of the item amount selected.
onready var _total_price = $LabelTotalPrice

onready var _grid_dynamic = $Panel/EventContainerItemsDynamic/Grid
onready var _scroll = $Panel/EventContainerItemsStatic
onready var _scroll2 = $Panel/EventContainerItemsDynamic

var _item_name = []
var _image = []
var _check_button = []
var _category = []

# the name of the item currently selected.
var _selected_rune_name = ""

var _stack_amount = [] # how many of the current selected item.
var _mp = []
var _group = []
var _gold = []
var _level = []
var _range = []
var _location = []
var _defense = []
var _strength = []

var _data_file_name = [] 
var _data_file_path_json = []
var _data_image_texture = []
var _data_directory_name = []

# this is the number of the checkbox selected. the other var that also refer to this number is _i which is used in a loop at ready func and also as _on_focus_entered() parameter
var _num:int = -1

# this var does not get reset back to -1. it is used to save the pressed state of the checkbox.
var _num_current = -1

var _item_list_current_index = 0

# this is used to loop thur the file_names searching for an item incrementing in order, an item that is visible. once found this value will be set to true.
# this var is used to checkmark the first visible item in the list.
var _found_first_item:bool = false

# this var stops the adding of a node to scene when it has already been added to scene.
var _nodes_added_to_scene:bool = false

var _mouse_clicked:bool = false


func _ready():
	Variables._dictionary_name = "weapon"
	Variables.select_json_dictionary_singly = true
	
	_scroll.get_h_scrollbar().modulate = Color(0, 0, 0, 0)
	_item_list.select(0) # select the first index in the list.
	
	_gold_total.text = str(Hud._loaded.Gold)	
	_total_price.text = "0"
	
	_on_ButtonSort_pressed()

	
func _process(_delta):	
	if Variables._at_scene != Enum.Scene.Rune_buying:
		return
		
	if Variables._child_scene_open == false:
		return
	
	_scroll.scroll_horizontal = _scroll2.scroll_horizontal
	
	
	if Variables._mouse_cursor_position.y > 442: # bottom of screen.
		# this is the button that follows the cursor.
		_select_button.rect_position.y = 442 + 41 + 41 + 32
		
	elif Variables._mouse_cursor_position.y >= 81: # current starting location.
		_select_button.rect_position.y = Variables._mouse_cursor_position.y + 41 + 41 + 32
	else:
		_select_button.rect_position.y = 194
	
	
	if Variables._num_first_rune_selected == -1 && _found_first_item == true:
		Variables._num_first_rune_selected = 0
		_num = 0
		
		_button_sort.grab_focus()
				
func _input(event):	
	if Variables._at_scene != Enum.Scene.Rune_buying:
		return
		
	if Variables._child_scene_open == false:
		return
	
	if event.is_action_pressed("ui_escape", true):
		Variables._child_scene_open = false
		visible = false
		event.scancode = 0 # don't trigger the esc from elsewhere.
		
	
	# this stops setting more than one radio button to active simultaneously.
	if event is InputEventKey && event.pressed && Variables.select_json_dictionary_singly == true:
		if event.scancode == KEY_SPACE || event.scancode == KEY_ENTER || event.is_action_pressed("ui_left", true) || event.is_action_pressed("ui_right", true):		
			var _i = -1
			for _key in Json._magic.keys():	
				_i += 1
				if _num != _i:
					_check_button[_i].pressed = false
				else:					
					_check_button[_i].pressed = true
					_num = _i
					_check_button[_i].grab_focus()
					
					# changes the price of the item to the current selected item.
					_selected_rune_name = _key
					_on_SpinBoxAmount_value_changed(_spinbox_amount.value)
					
				if _check_button[_i].pressed == true && _button_buy.has_focus() == false && _item_list.has_focus() == false && _button_sort.has_focus() == false:
						_num_current = _i
								
	if event is InputEventMouseButton && event.is_action_released("ui_left_mouse_click") && Variables._mouse_cursor_position.x <= 868 && Variables._mouse_cursor_position.y >= 61 && Variables._mouse_cursor_position.y <= 460:
		# clear all other CheckBox if using singly item mode.
		if Variables.select_json_dictionary_singly == true:
			#looping through the group node children and uncheck every one except the sender checkbox
			for _i in _check_button.size():
				_check_button[_i].pressed = false
		
		var _i = -1
		
		for _key in Json._magic.keys():
			_i += 1
			if _i == _num:
				_selected_rune_name = _key
				_on_SpinBoxAmount_value_changed(_spinbox_amount.value)
				break
				
			# 41 is the offset value between SelectButton at the first CheckBox. 32 is the width of the SelectButton.
			if Variables._mouse_cursor_position.y >= 61:
				if Variables._mouse_cursor_position.y - 41 - 32 + _scroll2.scroll_vertical <= _check_button[_i].rect_position.y:
					_selected_rune_name = _key
				
					if Variables.select_json_dictionary_singly == false:
						_check_button[_i].pressed = !_check_button[_i].pressed
						_num = _i
						_check_button[_i].grab_focus()	
					
					else:
						_check_button[_i].pressed = true
						_num = _i
						_check_button[_i].grab_focus()	
						
					break
				
	if _selected_rune_name != "" && _button_buy.has_focus() == false && _item_list.has_focus() == false && _button_sort.has_focus() == false:
		if event.is_action_pressed("ui_left", true):
			_spinbox_amount.value -= 1
		
		if event.is_action_pressed("ui_right", true):
			_spinbox_amount.value += 1
		
			
func _set_focus_to_nodes():
	var _i = Variables._num_first_rune_selected
	
	_check_button[_i].grab_focus()
	_check_button[_i].name = "CheckButton-01"
				
	_check_button[_i].focus_previous = NodePath("../../../../ButtonSort")
	
	_check_button[_i].focus_neighbour_top = NodePath("../../../../ButtonSort")
	
	
	_button_sort.focus_previous = NodePath("../ItemList")
	
	_button_sort.focus_neighbour_left = NodePath("../ItemList")
	
	
	_button_sort.focus_next = NodePath("../Panel/EventContainerItemsDynamic/Grid/CheckButton-01")
	
	_button_sort.focus_neighbour_right = NodePath("../Panel/EventContainerItemsDynamic/Grid/CheckButton-01")
	
	_button_sort.focus_neighbour_bottom = NodePath("../Panel/EventContainerItemsDynamic/Grid/CheckButton-01")
	

	_item_list.focus_previous = NodePath("../ButtonBuy")
		
	_item_list.focus_neighbour_left = NodePath("../ButtonBuy")
		
	_item_list.focus_next = NodePath("../ButtonSort")
	
	_item_list.focus_neighbour_right = NodePath("../ButtonSort")



	_button_buy.focus_previous = NodePath("../SpinBoxAmount")
		
	_button_buy.focus_neighbour_left = NodePath("../SpinBoxAmount")
		
	_button_buy.focus_next = NodePath("../ItemList")
	
	_button_buy.focus_neighbour_right = NodePath("../ItemList")

	
# add the text/image of the selected dictionary to the columns and rows of the grid nodes.	
func _draw_dictionary_items(_key, _r:int):		
	if _r == 0:
		_check_button.clear()
		
	_check_button.append([])
	_check_button[_r] = CheckBox.new()
	_check_button[_r].pressed = false
	_check_button[_r].add_to_group("grid_container") 
	
	if Variables.select_json_dictionary_singly == true:		
		_check_button[_r].group = ButtonGroup.new()
	
	if _found_first_item == false:
		_found_first_item = true
				
		_num = _r
		
	_grid_dynamic.add_child(_check_button[_r])
	
	
	if _check_button[_r].is_connected("focus_entered", self, "_on_focus_entered"):
		_check_button[_r].disconnect("focus_entered", self, "_on_focus_entered", [_r])
		
	# create the signals for the mouse entering /exiting the nodes.
	var _x = _check_button[_r].connect("focus_entered", self, "_on_focus_entered", [_r])
	
	if _check_button[_r].is_connected("focus_exited", self, "_on_focus_exited"):
		_check_button[_r].disconnect("focus_exited", self, "_on_focus_exited")

	var _y = _check_button[_r].connect("focus_exited", self, "_on_focus_exited")
			

	if _r == 0:
		_image.clear()
		
	_image.append([])
	_image[_r] = TextureRect.new()
	_image[_r].add_to_group("grid_container")
	
	# set the image textures to the nodes used to display the runes. those nodes are TextureRect. so to get the mouse entering and mouse exiting those nodes.
	_image[_r].texture = load("res://bundles/assets/images/magic/" + _key
+ ".png")
	
	_grid_dynamic.add_child(_image[_r])
	
	
	if _r == 0:
		_item_name.clear()
		
	_item_name.append([])
	_item_name[_r] = Label.new()
	# do not display long file names. instead add "..." to the end of long file names.
	if _key.length() >= 21:
		_key = _key.substr(0, 21) + "..."
	
	_item_name[_r].text = _key
	_item_name[_r].add_to_group("grid_container")
	
	if _selected_rune_name == "":
		_selected_rune_name = _item_name[_r].text
		_num = _r
	_grid_dynamic.add_child(_item_name[_r])
	
	
	if _r == 0:
		_stack_amount.clear()
			
	_stack_amount.append([])
	_stack_amount[_r] = Label.new()
	_stack_amount[_r].add_to_group("grid_container")
	_stack_amount[_r].text = str(Json._magic[_key]["Stack_amount"]).pad_zeros(3)	
	_grid_dynamic.add_child(_stack_amount[_r])
	
	
	if _r == 0:
		_mp.clear()
		
	_mp.append([])
	_mp[_r] = Label.new()
	_mp[_r].add_to_group("grid_container")
	_mp[_r].text = str(Json._magic[_key]["MP"]).pad_zeros(3)	
	_grid_dynamic.add_child(_mp[_r])
	
	
	if _r == 0:
		_group.clear()
		
	_group.append([])
	_group[_r] = Label.new()
	_group[_r].add_to_group("grid_container")
	_group[_r].text = str(Json._magic[_key]["Group"]).pad_zeros(3)	
	_grid_dynamic.add_child(_group[_r])
	
	
	if _r == 0:
		_gold.clear()
		
	_gold.append([])
	_gold[_r] = Label.new()
	_gold[_r].add_to_group("grid_container")
	_gold[_r].text = str(Json._magic[_key]["Gold"]).pad_zeros(3)	
	_grid_dynamic.add_child(_gold[_r])
	
	
	if _r == 0:
		_level.clear()
		
	_level.append([])
	_level[_r] = Label.new()
	_level[_r].add_to_group("grid_container")
	_level[_r].text = str(Json._magic[_key]["Level"]).pad_zeros(3)	
	_grid_dynamic.add_child(_level[_r])
	
	
	if _r == 0:
		_range.clear()
		
	_range.append([])
	_range[_r] = Label.new()
	_range[_r].add_to_group("grid_container")
	_range[_r].text = str(Json._magic[_key]["Range"]).pad_zeros(3)	
	_grid_dynamic.add_child(_range[_r])
	
	
	if _r == 0:
		_location.clear()
		
	_location.append([])
	_location[_r] = Label.new()
	_location[_r].add_to_group("grid_container")
	_location[_r].text = str(Json._magic[_key]["Location"]).pad_zeros(3)	
	_grid_dynamic.add_child(_location[_r])
	
	
	if _r == 0:
		_defense.clear()
		
	_defense.append([])
	_defense[_r] = Label.new()
	_defense[_r].add_to_group("grid_container")
	_defense[_r].text = str(Json._magic[_key]["Defense"]).pad_zeros(3)	
	_grid_dynamic.add_child(_defense[_r])
	
	
	if _r == 0:
		_strength.clear()
		
	_strength.append([])
	_strength[_r] = Label.new()
	_strength[_r].add_to_group("grid_container")
	_strength[_r].text = str(Json._magic[_key]["Strength"]).pad_zeros(3)	
	_grid_dynamic.add_child(_strength[_r])
	

func _on_Buy_pressed():
	_select_button.focus_mode = _select_button.FOCUS_NONE
	_select_button.visible = false
	
	if _spinbox_amount.value == 0:
		return
	
	set_physics_process(false)
	set_process_input(false)

	var _str2 = _selected_rune_name.replace("_", " ")
		
	_dialog_buy.dialog_text = "Buy " + str(_spinbox_amount.value) + " " + _str2 + "."

	_dialog_buy.popup_centered()
	
		
func _on_DialogBuy_confirmed():
	_select_button.focus_mode = _select_button.FOCUS_NONE
	_select_button.visible = false
	
	set_physics_process(false)
	set_process_input(false)
	
	_dialog_buy.visible = false
		
	P._gold -= _spinbox_amount.value * Json._magic[_selected_rune_name]["Gold"]
	Json._magic[_selected_rune_name]["Stack_amount"] += _spinbox_amount.value
	
	Filesystem.save_dictionary_json3("user://saved_data/builder_magic.txt", Json._magic)
	
	_stack_amount[_num_current].text = str(clamp(Json._magic[_selected_rune_name]["Stack_amount"], 0, 999))
	
	_stack_amount[_num_current].text = str(Json._magic[_selected_rune_name]["Stack_amount"]).pad_zeros(3)
	
	_gold_total.text = str(P._gold)
	
	var _str = _selected_rune_name.replace("_", " ")
			
	_dialog_bought.popup_centered()
	_dialog_bought.dialog_text = "Bought " + str(_spinbox_amount.value) + " " + _str + "."


func _on_ButtonExit_pressed():
	for _i in _check_button.size():
		_check_button[_i].pressed = false
			
	Variables._child_scene_open = false
	self.visible = false


func _on_SpinBoxAmount_value_changed(value):
	# value var was plus 1 in total because in this code there is no longer enought gold for a purchase. therefore, minus 1 from value because user does not have enough gold. 
	if _spinbox_amount.value * Json._magic[_selected_rune_name]["Gold"] > P._gold && Json._magic[_selected_rune_name]["Stack_amount"] < 999:
		_spinbox_amount.max_value = value - 1
			
		return
			
	else:
		_spinbox_amount.max_value = 999 - Json._magic[_selected_rune_name]["Stack_amount"]
		
		# keep here to avold a stack overflow.
		_spinbox_amount.value = value
	
	_total_price.text = str(_spinbox_amount.value * Json._magic[_selected_rune_name]["Gold"])


func _on_ButtonSort_pressed():
	if Variables._child_scene_open == false:
		return
	
	# Variables._item_list_current_index holds the state of the item list node. this gets the current name from the item list node.
	var _current_item_selected = _item_list.get_selected_items()
	
	# 0 = item name must not be used here or else the program will crash. we can only literate using it as only the name of the dictionary not the dictionary["name"]. 
	if _current_item_selected[0] > 0:
		_d_column = Common._sort(Json._magic, _item_list.get_item_text(_current_item_selected[0]), _current_item_selected[0])
	
	# remove all data in grid container.
	for _c in _grid_dynamic.get_children():
		if _c.is_in_group("grid_container"):
			_grid_dynamic.remove_child(_c)
			_c.queue_free()
			
	# the first loop holds the total number of indexes. only when the var _ii in the second loop matches the value of _d_column[_i][0] then the item will draw to screen.
	var _i = -1
	var _ii = -1
	
	_found_first_item = false
	
	# this is the default item order. sorted by dictionary name.	
	if _current_item_selected[0] == 0:
		for _key in Json._magic.keys():
			_i += 1
			
			_draw_dictionary_items(_key, _i)
			
			# set first item in this var so that it can be set in focus.
			if _found_first_item == true && Variables._num_first_rune_selected == -1:
				Variables._num_first_rune_selected = _i	
			
			if _i == 0:
				_selected_rune_name = _key
			
			if _i >= Json._magic.size():
				break
	
	# draw the directory, sorted from the users selection at ItemList 
	else:
		for _key in Json._magic.keys():
			_i += 1
			_ii = -1
			
			for _key2 in Json._magic.keys():
				_ii += 1
				
				# modified dictionary key from sort. it the row number matches the value of _ii then  draw to screen.
				if _d_column[_i][0] == _ii:
					if _ii == 0:
						_selected_rune_name = _key2
					
					if _ii >= Json._magic.size():
						break	
					
					# this draws the items, such as, str text and def text to the scene.
					_draw_dictionary_items(_key2, _i)
					
					# set first item in this var so that it can be set in focus.
					if _found_first_item == true && Variables._num_first_rune_selected == -1:
						Variables._num_first_rune_selected = _i	
						
				if _ii >= Json._magic.size():
					break
			if _i >= Json._magic.size():
				break
	
	_set_focus_to_nodes()
	

# _i refers to the checkbox node.
func _on_focus_entered(_i:int = 0):
	_num = _i


func _on_focus_exited():
	_num = -1


func _on_DialogBuy_hide():
	_select_button.focus_mode = _select_button.FOCUS_ALL
	_select_button.visible = true
	
	set_physics_process(true)
	set_process_input(true)


func _on_DialogBought_hide():
	_select_button.focus_mode = _select_button.FOCUS_ALL
	_select_button.visible = true
		
	set_physics_process(true)
	set_process_input(true)

	_set_focus_to_nodes()
