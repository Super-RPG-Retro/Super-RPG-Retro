"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


@onready var _grid := $Container/Grid

var _image	:= []

# increments array elements.
var _e := 0

# cell button number
var _b := 0

# the builder menu.
@onready var _menu = null


func _ready():
	Variables._at_scene = Enum.Scene.Builder
	# used at title_bar. see HeaderMenu node.
	Variables._scene_title = "Builder: Event Story."

	_draw_cells()
	
	
# this draws the cells when the scene is first created.
func _draw_cells():
	for _y in range (100):
		for _x in range (100):
			if _e >= 10000:
				break
			
			# image representing to mesh library cell.
			_image.append(Vector3(_x, _y, 0))
			_image[_e] = Button.new()
			_image[_e].icon = load("res://3d/assets/images/cells/"+ str(Builder._library_cell.data.cell_item[_e]) +".png")
			_grid.add_child(_image[_e])
			
			# remove the signal..
			if _image[_e].is_connected("pressed", Callable(self, "_on_pressed")):
				_image[_e].disconnect("pressed", self, "_on_pressed", [_e])
				
			# create the signal.
			var _z = _image[_e].connect("pressed", Callable(self, "_on_pressed").bind(_e))
	
			_e += 1
			
			
func _on_pressed(_e_current):
	_e = 0
	
	# only 1 player allowed on map. clear map of all player image before placing player image on map.
	for _y in range (100):
		for _x in range (100):
			_e += 1
			if _e >= 10000:
				break
			
			if _b >= 96 && _b <= 99 && Builder._library_cell.data.cell_item[_e] >= 96 && Builder._library_cell.data.cell_item[_e] <= 99:
				Builder._library_cell.data.cell_item[_e] = 0
				_image[_e].icon = load("res://3d/assets/images/cells/0.png")
			
	_image[_e_current].icon = load("res://3d/assets/images/cells/"+ str(_b) +".png")
	Builder._library_cell.data.cell_item[_e_current] = _b
	

func _on_StatusBar_tree_exiting():
	
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()


func _return_to_main_menu():
	var _s = get_tree().change_scene_to_file("res://3d/scenes/Gridmap.tscn")


func _on_CellButton1_pressed():
	_b = 0


func _on_CellButton2_pressed():
	_b = 1
	

func _on_CellButton3_pressed():
	_b = 2


# location of player. player's starting position standing normal.
func _on_CellButton_player_96_pressed():
	_b = 96
	

# location of player. player's starting position rotated 270 degrees.
func _on_CellButton_player_97_pressed():
	_b = 99
	

# location of player. player's starting position rotated 180 degrees.
func _on_CellButton_player_98_pressed():
	_b = 98
	

# location of player. player's starting position rotated 90 degrees.
func _on_CellButton_player_99_pressed():
	_b = 97

