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
	
	var _i = -1
	
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
			_i += 1
			
			# stat name,
			_label.append([])
			_label[_i] = Label.new()
			_label[_i].text = Variables.s[str(_s)]
			_label[_i].autowrap = true
			_label[_i].align = HALIGN_RIGHT
			_grid.add_child(_label[_i])
			
			_grid_child.append([])
			_grid_child[_i] = HBoxContainer.new()
			_grid_child[_i].rect_min_size.x = 750
			_grid_child[_i].rect_size.y = 32
			_grid.add_child(_grid_child[_i])
			
			# stat value.
			_spin_box.append([])
			_spin_box[_i] = SpinBox.new()
			_spin_box[_i].min_value = 0
			_spin_box[_i].max_value = 200
			_spin_box[_i].value = Builder._starting_statistics[Variables.s[str(_s)]][_p]
			_spin_box[_i].rect_size.x = 100
			_spin_box[_i].rect_min_size.x = 50
			_grid_child[_i].add_child(_spin_box[_i])
			
			# stat description.
			_description.append([])
			_description[_i] = Label.new()
			_description[_i].text = Variables.s_desc[str(_s)]
			_description[_i].autowrap = true
			_description[_i].rect_min_size.x = 545
			_description[_i].rect_size.y = 32
			_description[_i].align = HALIGN_LEFT
			_grid_child[_i].add_child(_description[_i])
			
			
			# mouse exited.
			if _spin_box[_i].is_connected("mouse_exited", self, "_on_mouse_exited"):
				_spin_box[_i].disconnect("mouse_exited", self, "_on_mouse_exited", [_s, _p, _i])
				
			# create the signal.
			var _y = _spin_box[_i].connect("mouse_exited", self, "_on_mouse_exited", [_s, _p, _i])
			
			#_draw_magic_values()
			
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


func _draw_magic_values():
	# at nodes to grid.
	_label			= []
	_empty			= []
	_grid_child 	= []
	_spin_box 		= []
	_description 	= []
	

func _on_mouse_exited(_s, _p, _i):
	Builder._starting_statistics[Variables.s[str(_s)]][_p] = _spin_box[_i].value
	
	
func _return_to_main_menu():
	var _s = get_tree().change_scene("res://2d/source/scenes/main_menu.tscn")


func _on_Node2D_tree_exiting():
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()
