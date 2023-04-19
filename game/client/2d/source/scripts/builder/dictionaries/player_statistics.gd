"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node

onready var _grid = $Container/Grid

var _label 			= []
var _empty 			= []
var _grid_child 	= []
var _spin_box 		= []
var _description 	= []

# increments array elements.
var _e = -1

# the builder menu.
onready var _menu = null


func _ready():
	Variables._at_scene = Enum.Scene.Builder
	Variables._scene_title = "Builder: Starting Statistics."
	
	_draw_skill_values()
		

func _draw_skill_values():
	# at nodes to grid.
	_label			= []
	_empty			= []
	_grid_child 	= []
	_spin_box 		= []
	_description 	= []
	
	for _p in range (7): # player
		# empty.
		_empty.append([])
		_empty[_p] = Label.new()
		_empty[_p].text = ""
		_empty[_p].rect_size.y = 32
		_grid.add_child(_empty[_p])
		
		# player name
		_label.append([])
		_label[_p] = Label.new()
		_label[_p].text = P.character_name[str(_p)]
		_label[_p].autowrap = true
		_label[_p].add_color_override("font_color", Color("#0054ff")) # blue 
		_grid.add_child(_label[_p])
		
		for _s in range (10): # stats.
			_e += 1
			
			# stat name,
			_label.append([])
			_label[_e] = Label.new()
			_label[_e].text = Variables.s[str(_s)]
			_label[_e].autowrap = true
			_label[_e].align = HALIGN_RIGHT
			_grid.add_child(_label[_e])
			
			_grid_child.append([])
			_grid_child[_e] = HBoxContainer.new()
			_grid_child[_e].rect_min_size.x = 750
			_grid_child[_e].rect_size.y = 32
			_grid.add_child(_grid_child[_e])
			
			# stat value.
			_spin_box.append([])
			_spin_box[_e] = SpinBox.new()
			_spin_box[_e].min_value = 0
			_spin_box[_e].max_value = 200
			_spin_box[_e].value = Builder._starting_skills[Variables.s[str(_s)]][_p]
			_spin_box[_e].rect_size.x = 100
			_spin_box[_e].rect_min_size.x = 50
			_grid_child[_e].add_child(_spin_box[_e])
			
			# stat description.
			_description.append([])
			_description[_e] = Label.new()
			_description[_e].text = Variables.s_desc[str(_s)]
			_description[_e].autowrap = true
			_description[_e].rect_min_size.x = 545
			_description[_e].rect_size.y = 32
			_description[_e].align = HALIGN_LEFT
			_grid_child[_e].add_child(_description[_e])
			
			
			# remove the signal..
			if _spin_box[_e].is_connected("mouse_exited", self, "_on_mouse_exited"):
				_spin_box[_e].disconnect("mouse_exited", self, "_on_stats_mouse_exited", [_s, _p, _e])
				
			# create the signal.
			var _y = _spin_box[_e].connect("mouse_exited", self, "_on_stats_mouse_exited", [_s, _p, _e])
			
		
		_draw_value("HP_max", _p)
		_draw_value("HP", _p)
		_draw_value("MP_max", _p)
		_draw_value("MP", _p)
		
		#used as a padding between player character names.
		# empty.
		_empty.append([])
		_empty[_p] = Label.new()
		_empty[_p].text = ""
		_empty[_p].rect_size.y = 32
		_grid.add_child(_empty[_p])
		
		# empty.
		_empty.append([])
		_empty[_p] = Label.new()
		_empty[_p].text = ""
		_empty[_p].rect_size.y = 32
		_grid.add_child(_empty[_p])


func _draw_value(_str:String, _p: int):
	_e += 1
	
	# stat name,
	_label.append([])
	_label[_e] = Label.new()
	_label[_e].text = _str.replace("_", " ")
	_label[_e].autowrap = true
	_label[_e].align = HALIGN_RIGHT
	_grid.add_child(_label[_e])
	
	_grid_child.append([])
	_grid_child[_e] = HBoxContainer.new()
	_grid_child[_e].rect_min_size.x = 750
	_grid_child[_e].rect_size.y = 32
	_grid.add_child(_grid_child[_e])
	
	# stat value.
	_spin_box.append([])
	_spin_box[_e] = SpinBox.new()
	
	if _str == "HP_max" || _str == "HP":
		_spin_box[_e].min_value = 10
	else:
		_spin_box[_e].min_value = 0
		
	_spin_box[_e].max_value = 100
	_spin_box[_e].value = Builder._starting_skills[_str][_p]
	_spin_box[_e].rect_size.x = 100
	_spin_box[_e].rect_min_size.x = 50
	_grid_child[_e].add_child(_spin_box[_e])
	
	# stat description.
	_description.append([])
	_description[_e] = Label.new()
	
	var _desc_text = ""
	
	match _str:
		"HP_max": _desc_text = "The maximum Hit Points this player can have?"
		"HP": _desc_text = "The current starting Hit Points this player has?"
		"MP_max": _desc_text = "The maximum Magic Points this player can have?"
		"MP": _desc_text = "The current starting Magic Points this player has?"
		
	_description[_e].text = _desc_text
	_description[_e].autowrap = true
	_description[_e].rect_min_size.x = 545
	_description[_e].rect_size.y = 32
	_description[_e].align = HALIGN_LEFT
	_grid_child[_e].add_child(_description[_e])
	
	# remove the signal..
	if _spin_box[_e].is_connected("mouse_exited", self, "_on_mouse_exited"):
		_spin_box[_e].disconnect("mouse_exited", self, "_on_mouse_exited", [_str, _p, _e])
		
	# create the signal.
	var _y = _spin_box[_e].connect("mouse_exited", self, "_on_mouse_exited", [_str, _p, _e])
	

# when existing the spin box, this func stores the value of the spin box into the builder var. When exiting this scene the builder data will be saved.
func _on_stats_mouse_exited(_s, _p, _i):
	Builder._starting_skills[Variables.s[str(_s)]][_p] = _spin_box[_i].value
	
	
func _on_mouse_exited(_str, _p, _i):
	Builder._starting_skills[_str][_p] = _spin_box[_i].value


func _return_to_main_menu():
	var _s = get_tree().change_scene("res://2d/source/scenes/main_menu.tscn")


func _on_Node2D_tree_exiting():
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()
