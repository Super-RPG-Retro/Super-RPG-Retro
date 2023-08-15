"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


var _extra_room_size := 0

# total available levels for each dungeon. this var is passed to Builder._data.level_number
@onready var _level_number := $Container/Grid/Grid1/LevelSpinbox

# starting level for player at each dungeon. this var is passed to Builder._data.starting_level which is an array.
@onready var _starting_level := $Container/Grid/Grid3/StartingLevel2

# Minimum random value of a level size in tiles.
@onready var _level_size := $Container/Grid/Grid2/LevelSizeSpinbox
@onready var _previous_level_size := 0

# how many rooms in a dungeon.
@onready var _room_total := $Container/Grid/Grid4/RoomTotalSpinbox
@onready var _previous_room_total := 0

# size of a room in the dungeon in tiles. size includes the one wall on each side of the room. so a five tile room will have a player walkable floor width of 3 tiles.
@onready var _room_size_max := $Container/Grid/Grid5/RoomSizeMaxSpinbox
@onready var _previous_room_size_max := 0

@onready var _room_size_min := $Container/Grid/Grid6/RoomSizeMinSpinbox
@onready var _previous_room_size_min := 0

@onready var _mobs_total := $Container/Grid/Grid7/MobsTotalSpinbox
@onready var _item_total := $Container/Grid/Grid8/ItemTotalSpinbox

# for this feature to work, Set hide_stone_walls to true. Hide a corridor from room one and a random room. Only a random value from 0 to 3 is used. When creating the corridors, The last preset room is excluded since that room is used to create the corridors.
@onready var _hide_random_corridor := $Container/Grid/Grid13/CheckButtonHideRandomCorridor

#Is the store that sells only items enabled?
@onready var _store_items_enabled := $Container/Grid/Grid9/CheckButtonStoreItems

#Is the store that sells only armor enabled?
@onready var _store_armor_enabled := $Container/Grid/Grid10/CheckButtonStoreArmor

#Is the store that sells only weapons enabled?
@onready var _store_weapons_enabled := $Container/Grid/Grid11/CheckButtonStoreWeapons

# Should a save point be enabled for this level.
@onready var _save_point_enabled := $Container/Grid/Grid12/CheckButtonSavePoint

@onready var _menu = null

# when this is false some code will not be read.
var _read_code := true


func _ready():
	Variables._at_scene = Enum.Scene.Builder
	# used at title_bar/ see HeaderMenu node.
	Variables._scene_title = "Builder: Project Levels."
	
	# set the level spinbox from the loaded data.	
	_level_number.value = Builder._data.level_number + 1
	_on_LevelSpinbox_value_changed(_level_number.value)
		
	if _menu == null:
		_menu = load("res://2d/source/scenes/builder/menu.tscn").instantiate()
		add_child( _menu )


	var _work_but_this_var_is_not_yet_used = dimensions()

	if _extra_room_size == 0:
		_level_size.value += 1
	
	
func _process(_delta):
	if Builder._data.starting_level == _level_number.value:
		_starting_level.button_pressed = true
		# disabling this var forces it to always be enabled to at least one level. it can only be set to true after changing to a level where this var has a value of false.
		_starting_level.disabled = true 
	else:
		_starting_level.button_pressed = false	
		_starting_level.disabled = false
		

# this is triggered when a value is changed at the level spinbox	
func _on_LevelSpinbox_value_changed(value):
	# store the current value in to the builder var.
	Builder._config.level_number = value
	Builder._data.level_number = value - 1
	
	_level_size.value = Builder._data.level_size[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number]
	
	_room_total.value = Builder._data.room_total[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number]
		
	_room_size_max.value = Builder._data.room_size_max[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number]
	
	_room_size_min.value = Builder._data.room_size_min[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number]	

	_mobs_total.value = Builder._data.mobs_total[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number]
	
	_item_total.value = Builder._data.item_total[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number]
	
	if Builder._data.hide_random_corridor[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] == 1:
		_hide_random_corridor.button_pressed = true
	else:
		_hide_random_corridor.button_pressed = false
	
	if Builder._data.store_items_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] == 1:
		_store_items_enabled.button_pressed = true
	else:
		_store_items_enabled.button_pressed = false
		
	if Builder._data.store_armor_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] == 1:
		_store_armor_enabled.button_pressed = true
	else:
		_store_armor_enabled.button_pressed = false
		
	if Builder._data.store_weapons_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] == 1:
		_store_weapons_enabled.button_pressed = true
	else:
		_store_weapons_enabled.button_pressed = false
		
	if Builder._data.save_point_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] == 1:
		_save_point_enabled.button_pressed = true
	else:
		_save_point_enabled.button_pressed = false
	
	# If the value of a room does not go beyond the level size or a level size is not too small for the total rooms, then those values are updated. else, changing a room size or room total will not work.
	update_values()
		

func _on_StartingLevel_toggled(button_pressed):
	# update the builder starting_level data. 	
	if button_pressed == false && Builder._data.starting_level == _level_number.value:
		Builder._data.starting_level = 0
	
	elif button_pressed == true:
		if Builder._data.starting_level == 0 || Builder._data.starting_level != _level_number.value:
			Builder._data.starting_level = _level_number.value

	
func _on_LevelSizeSpinbox_value_changed(value):
	if _read_code == true:
		var _room_size_valid = dimensions()
		if _room_size_valid == false:
			_level_size.value = value + 1
			return
			
	if value > _previous_level_size:
		_level_size.value = value
		update_values() 
	
	# store the current value in to the builder var.
	Builder._data.level_size[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = value
	
	
func _on_RoomTotalSpinbox_value_changed(value):
	if value < _previous_room_total:
		_room_total.value = value
		update_values()
		
	var _room_size_valid = dimensions()
	if _room_size_valid == false:
		_room_total.value =_previous_room_total 
			
	# store the current value in to the builder var.
	Builder._data.room_total[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = value
	

func _on_RoomSizeMaxSpinbox_value_changed(value):
	if _room_size_min.value > value:
		_room_size_min.value = value
	
	if value < _previous_room_size_max:
		_room_size_max.value = value
		update_values()
		
	var _room_size_valid = dimensions()
	if _room_size_valid == false:
		_room_size_max.value =_previous_room_size_max
				
	# store the current value in to the builder var.
	Builder._data.room_size_max[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = value
		
	
func _on_RoomSizeMinSpinbox_value_changed(value):
	if value >= _room_size_max.value:
		_room_size_min.value = _room_size_max.value
	
	if value < _previous_room_size_min:
		_room_size_min.value = value
		update_values()
	
	var _room_size_valid = dimensions()
	if _room_size_valid == false:
		_room_size_min.value =_previous_room_size_min
		return
		
	# store the current value in to the builder var.
	Builder._data.room_size_min[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = value
		
	
# If the value of a room does not go beyond the level size or a level size is not too small for the total rooms, then those values are updated. else, changing a room size or room total will not work.
func update_values():
	_previous_level_size		= _level_size.value
	_previous_room_total		= _room_total.value
	_previous_room_size_min		= _room_size_min.value
	_previous_room_size_max		= _room_size_max.value
	
	
func dimensions() -> bool:
	var _room_size_valid = true
	var _tiles
	
	# this is the math formula used to create the size of the room. this math formula is the width of the max room size squared.
	# Dont set SpinBox value greater than 12 because the calculations will round to the same value. the greater the value of the spinbox, the less of an increase to the value it will be. therefore, 12 is the max value for room total. room size should remain at 10.
	var _math = float("0." + str(_room_total.value))
	if _room_total.value >= 10:
		_math = float(str(_room_total.value / 10))
	
	# the size of the event room added to the calculations.
	if Builder._data.event_room_size[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] > 0:
		_extra_room_size = 3.4  - int(_room_size_max.value / 10)
	
	# this is the main calculations so keep the room evenly space between the corridors. when the room total increases, _math will have a greater value the lesser the value of the room total. the reason is that when the room is small, an increase to the room size will need to be great so that 1 extra room can be placed on the map. whereas, when the map is big, a minor increase of the map will create enought regions for many rooms to be placed on the map. therefore, _math is used to adjust the map based on the size of its total map in tiles.
	_tiles = int(((_room_size_max.value * _room_total.value) * (3.3 - _math)) + _extra_room_size * Settings._system.corridor_length_between_rooms)
	
		
	# is there enought tiles for the requested level dimensions?
	if _level_size.value <= _tiles:
		_room_size_valid = false
	
		# level_size might need updating because at general_events, room size might have changed.
		_read_code = false
		
		# this + 1 is needed. without this code, spinbox could decrease level size to a value below its minimum value.
		_level_size.value = _tiles + 1
		
		_on_LevelSizeSpinbox_value_changed(_tiles)
		_read_code = true
		
	else:
		_room_size_valid = true
		update_values()
		
	return _room_size_valid


func _on_StatusBar_tree_exiting():
	
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()


func _return_to_main_menu():
	var _s = get_tree().change_scene_to_file("res://3d/scenes/Gridmap.tscn")


func _on_mobs_total_spinbox_value_changed(value):
	Builder._data.mobs_total[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = value
	

func _on_item_total_Spinbox_value_changed(value):
	Builder._data.item_total[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = value
	
	
func _on_Hide_Random_Corridor_toggled(button_pressed):
	if button_pressed == false:
		Builder._data.hide_random_corridor[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = 0
	
	if button_pressed == true:
		Builder._data.hide_random_corridor[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = 1


func _on_CheckButtonStoreItems_toggled(button_pressed):
	if button_pressed == false:
		Builder._data.store_items_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = 0
	
	if button_pressed == true:
		Builder._data.store_items_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = 1
	

func _on_CheckButtonStoreArmor_toggled(button_pressed):
	if button_pressed == false:
		Builder._data.store_armor_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = 0
	
	if button_pressed == true:
		Builder._data.store_armor_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = 1


func _on_CheckButtonStoreWeapons_toggled(button_pressed):
	if button_pressed == false:
		Builder._data.store_weapons_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = 0
	
	if button_pressed == true:
		Builder._data.store_weapons_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = 1


func _on_CheckButtonSavePoint_toggled(button_pressed):
	if button_pressed == false:
		Builder._data.save_point_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = 0
	
	if button_pressed == true:
		Builder._data.save_point_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] = 1


