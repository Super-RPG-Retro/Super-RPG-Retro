"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# Builder._starting_skills holds both the misc keys and skill keys. misc key is used as the title name displayed to the left side of that key value (spinbox) and at the right side is the key description.

extends Node


@onready var _grid = $Container/Grid

# name of HP Max, MP, Player's level etc.
var _title_misc := []
# name of Strength, Luck etc 
var _title_skills := []
# grid cosmetic changes to layout, such as, adding padding between players' data.
var _empty_row := []
var _empty_column := []
# HBoxContainer
var _grid_child_misc := []
var _grid_child_skill := []

# a spinbox holding a value for every players' statistic.
var _spin_box_misc := []
var _spin_box_skill := []
# a brief description of the statistic.
var _description_misc := []
var _description_skill := []

# increments array elements.
var _index_num_misc := -1
var _index_num_skill := -1

# the builder menu.
@onready var _menu := $HeaderMenu
@onready var _all_children


func _init():
	# at nodes to grid.
	_title_misc				= []
	_title_skills			= []
	_empty_row				= []
	_empty_column			= []
	_grid_child_misc 		= []
	_grid_child_skill	 	= []
	_description_misc 		= []
	_description_skill	 	= []
	
	_spin_box_skill.clear()
	
	# create the array elements.
	for _i in range (0, 7):
		_spin_box_misc.append([])
		_spin_box_skill.append([])
	
	
func _ready():
	Variables._at_scene = Enum.Scene.Builder
	Variables._scene_title = "Builder: Starting Statistics."
	
	for _p in range (0, 7): # all players
		_draw_misc_title(_p)
		# draw the stats data for this player _p.
		_draw_misc("HP_max", _p)
		_draw_misc("HP", _p)
		_draw_misc("MP_max", _p)
		_draw_misc("MP", _p)		
		_draw_player_level(_p)
		_draw_skills(_p)		
		_draw_empty_rows(_p)
		
		_index_num_misc = -1
		_index_num_skill = -1
		
	call_deferred("_get_all_childrem")
	
	
func _get_all_childrem():
	_all_children = _get_all_children(get_node("."))
		

func _get_all_children(in_node, arr: = []):
	arr.push_back(in_node)

	for _c in in_node.get_children():
		if _c.get_class() == "SpinBox":
			_c.focus_mode = Control.FOCUS_ALL
			_c.mouse_filter = Control.MOUSE_FILTER_PASS
			
			_c.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
			_c.connect("value_changed", Callable(self, "_on_gui_input"), _c.value)
			
			
		arr = _get_all_children(_c, arr)

	return arr


# this registers a keypress in case the user is at a spinbox and editing that spinbox value using the keyboard. The problem is that without this code, changing the value without pressing enter key would not save that new value when exiting that scene.

# if editing the checkbox then simulate an enter key press, so that updated data can be later saved to the builder var.
func _on_mouse_exited():
	Common._parse_input_event()
	_clamp_hp_and_mp_spinbox_values()
	

func _on_gui_input(_value):
	Common._parse_input_event()
	_clamp_hp_and_mp_spinbox_values()
	
	
# HP and MP values must not be greater then HP_max and MP_max values.
func _clamp_hp_and_mp_spinbox_values():
	for _i in range (0, 7):
		# HP. 
		if _spin_box_misc[_i][0].value < _spin_box_misc[_i][1].value:
			_spin_box_misc[_i][1].value = _spin_box_misc[_i][0].value
		
		# MP...
		if _spin_box_misc[_i][2].value < _spin_box_misc[_i][3].value:
			_spin_box_misc[_i][3].value = _spin_box_misc[_i][2].value


func _draw_misc_title(_p: int):
	_empty_column.append([])
	_empty_column[_p] = Label.new()
	_empty_column[_p].text = ""
	_empty_column[_p].size.y = 32
	_grid.add_child(_empty_column[_p])
	
	# title of a player name.
	_title_misc.append([])
	_title_misc[_p] = Label.new()
	_title_misc[_p].text = P.character_name[str(_p)]
	_title_misc[_p].set_autowrap_mode(true)
	_title_misc[_p].add_theme_color_override("font_color", Color("#0054ff")) # blue 
	_grid.add_child(_title_misc[_p])


func _draw_misc(_str:String, _p: int):
	_index_num_misc += 1
	
	# title of a misc key. it is displayed at the left side of the spinbox.
	_title_misc.append([])
	_title_misc[_index_num_misc] = Label.new()
	_title_misc[_index_num_misc].text = _str.replace("_", " ")
	_title_misc[_index_num_misc].set_autowrap_mode(true)
	_title_misc[_index_num_misc].set_horizontal_alignment(HORIZONTAL_ALIGNMENT_RIGHT)
	_grid.add_child(_title_misc[_index_num_misc])
	
	_grid_child_misc.append([])
	_grid_child_misc[_index_num_misc] = HBoxContainer.new()
	_grid_child_misc[_index_num_misc].custom_minimum_size.x = 750
	_grid_child_misc[_index_num_misc].size.y = 32
	_grid.add_child(_grid_child_misc[_index_num_misc])
	
	# stat value.
	_spin_box_misc[_p].append([])
	_spin_box_misc[_p][_index_num_misc] = SpinBox.new()
	
	if _str == "HP_max" || _str == "HP":
		_spin_box_misc[_p][_index_num_misc].min_value = 1
	else:
		_spin_box_misc[_p][_index_num_misc].min_value = 0
		
	_spin_box_misc[_p][_index_num_misc].max_value = 100
	_spin_box_misc[_p][_index_num_misc].value = Builder._starting_skills[_str][_p]
	_spin_box_misc[_p][_index_num_misc].size.x = 100
	_spin_box_misc[_p][_index_num_misc].custom_minimum_size.x = 50
	_grid_child_misc[_index_num_misc].add_child(_spin_box_misc[_p][_index_num_misc])
	
	# stat description.
	_description_misc.append([])
	_description_misc[_index_num_misc] = Label.new()
	
	var _desc_text = ""
	
	match _str:
		"HP_max": _desc_text = "The maximum Hit Points this player can have?"
		"HP": _desc_text = "The current starting Hit Points this player has?"
		"MP_max": _desc_text = "The maximum Magic Points this player can have?"
		"MP": _desc_text = "The current starting Magic Points this player has?"
		
	_description_misc[_index_num_misc].text = _desc_text
	_description_misc[_index_num_misc].set_autowrap_mode(true)
	_description_misc[_index_num_misc].custom_minimum_size.x = 545
	_description_misc[_index_num_misc].size.y = 32
	_description_misc[_index_num_misc].set_horizontal_alignment(HORIZONTAL_ALIGNMENT_LEFT)
	_grid_child_misc[_index_num_misc].add_child(_description_misc[_index_num_misc])
	

func _draw_player_level(_p: int):
	_index_num_misc += 1
	
	# level label,
	_title_misc.append([])
	_title_misc[_index_num_misc] = Label.new()
	_title_misc[_index_num_misc].text = "Player Level"
	_title_misc[_index_num_misc].set_autowrap_mode(true)
	_title_misc[_index_num_misc].set_horizontal_alignment(HORIZONTAL_ALIGNMENT_RIGHT)
	_grid.add_child(_title_misc[_index_num_misc])
	
	_grid_child_misc.append([])
	_grid_child_misc[_index_num_misc] = HBoxContainer.new()
	_grid_child_misc[_index_num_misc].custom_minimum_size.x = 750
	_grid_child_misc[_index_num_misc].size.y = 32
	_grid.add_child(_grid_child_misc[_index_num_misc])
	
	# level spinbox.
	_spin_box_misc[_p].append([])
	_spin_box_misc[_p][_index_num_misc] = SpinBox.new()
	
	_spin_box_misc[_p][_index_num_misc].min_value = 1
		
	_spin_box_misc[_p][_index_num_misc].max_value = 100
	_spin_box_misc[_p][_index_num_misc].value = Builder._starting_skills["Level"][_p]
	_spin_box_misc[_p][_index_num_misc].size.x = 100
	_spin_box_misc[_p][_index_num_misc].custom_minimum_size.x = 50
	_grid_child_misc[_index_num_misc].add_child(_spin_box_misc[_p][_index_num_misc])
	
	# level description.
	_description_misc.append([])
	_description_misc[_index_num_misc] = Label.new()
	
	var _desc_text = ""
	
	_description_misc[_index_num_misc].text = "Current level of the player."
	_description_misc[_index_num_misc].set_autowrap_mode(true)
	_description_misc[_index_num_misc].custom_minimum_size.x = 545
	_description_misc[_index_num_misc].size.y = 32
	_description_misc[_index_num_misc].set_horizontal_alignment(HORIZONTAL_ALIGNMENT_LEFT)
	_grid_child_misc[_index_num_misc].add_child(_description_misc[_index_num_misc])
	
	
func _draw_skills(_p:int):
	for _s in range (0, 10): # skills.
		_index_num_misc += 1
		_index_num_skill += 1
		
		# stills name,
		_title_skills.append([])
		_title_skills[_index_num_skill] = Label.new()
		_title_skills[_index_num_skill].text = Variables.s[str(_s)]
		_title_skills[_index_num_skill].set_autowrap_mode(true)
		_title_skills[_index_num_skill].set_horizontal_alignment(HORIZONTAL_ALIGNMENT_RIGHT)
		_grid.add_child(_title_skills[_index_num_skill])
		
		_grid_child_skill.append([])
		_grid_child_skill[_index_num_skill] = HBoxContainer.new()
		_grid_child_skill[_index_num_skill].custom_minimum_size.x = 750
		_grid_child_skill[_index_num_skill].size.y = 32
		_grid.add_child(_grid_child_skill[_index_num_skill])
		
		# skills value.
		_spin_box_skill[_p].append([])
		_spin_box_skill[_p][_index_num_skill] = SpinBox.new()
		_spin_box_skill[_p][_index_num_skill].min_value = 0
		_spin_box_skill[_p][_index_num_skill].max_value = 200
		_spin_box_skill[_p][_index_num_skill].value = Builder._starting_skills[Variables.s[str(_s)]][_p]
		_spin_box_skill[_p][_index_num_skill].size.x = 100
		_spin_box_skill[_p][_index_num_skill].custom_minimum_size.x = 50
		_grid_child_skill[_index_num_skill].add_child(_spin_box_skill[_p][_index_num_skill])
		
		# skills description.
		_description_skill.append([])
		_description_skill[_index_num_skill] = Label.new()
		_description_skill[_index_num_skill].text = Variables.s_desc[str(_s)]
		_description_skill[_index_num_skill].set_autowrap_mode(true)
		_description_skill[_index_num_skill].custom_minimum_size.x = 545
		_description_skill[_index_num_skill].size.y = 32
		_description_skill[_index_num_skill].set_horizontal_alignment(HORIZONTAL_ALIGNMENT_LEFT)
		_grid_child_skill[_index_num_skill].add_child(_description_skill[_index_num_skill])

	
func _draw_empty_rows(_p: int):
	#used as an empty row between player character names.
	_empty_row.append([])
	_empty_row[_p] = Label.new()
	_empty_row[_p].text = ""
	_empty_row[_p].size.y = 32
	_grid.add_child(_empty_row[_p])
	
	# another empty row is needed here.
	_empty_row.append([])
	_empty_row[_p] = Label.new()
	_empty_row[_p].text = ""
	_empty_row[_p].size.y = 32
	_grid.add_child(_empty_row[_p])


func _return_to_main_menu():
	call_deferred("_prepare_save_data")
	
	var _s = get_tree().change_scene_to_file("res://3d/scenes/gridmap.tscn")


# save data when ending task or when clicking the "x" button at top-right corner of app.
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST || what == NOTIFICATION_WM_GO_BACK_REQUEST:
		call_deferred("_prepare_save_data")


func _on_Node2D_tree_exiting():
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()


# populate the Builder._starting_skills dictionary with spinbox values from this scene.
func _prepare_save_data():
	_clamp_hp_and_mp_spinbox_values()
	call_deferred("_save_data")

	
func _save_data():
	if _spin_box_skill.size() == 7 && _spin_box_skill[6].size() == 10:
		for _p in range (0, 7):
			for _i in range (0, 5):
				# Variables.s[str(0) is the dictionary key named Charisma.
				# player HP_max, HP, MP_max and MP
				Builder._starting_skills[Variables.s[str((_i + 10))]][_p] = _spin_box_misc[_p][_i].value
			
			# player level.
			Builder._starting_skills["Level"][_p] = _spin_box_misc[_p][4].value
			
			# player skills.
			for _i in range (0, 10):
				Builder._starting_skills[Variables.s[str(_i)]][_p] = _spin_box_skill[_p][_i].value
			
		Filesystem.builder_save_data()
			
