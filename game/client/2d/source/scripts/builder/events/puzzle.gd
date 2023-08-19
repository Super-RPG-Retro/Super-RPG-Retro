"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


var _group_item_list_index := 0
@onready var _group_item_list := $Container/Grid/Grid3/ItemList

@onready var _event_number := $Container/Grid/Grid8/EventSpinbox

@onready var _dungeon_number := $Container/Grid/Grid4/DungeonSpinbox

# total available levels for each dungeon. this var is passed to Builder._event_puzzles.data.event_number
@onready var _level_number := $Container/Grid/Grid1/LevelSpinbox

@onready var _event_enabled := $Container/Grid/Grid5/EventEnabled

# size of a room in the dungeon in tiles. size includes the one wall on each side of the room. so a five tile room will have a floor width of 3 tiles.
@onready var _event_room_size := $Container/Grid/KeepTheseNodesHidden/SpinboxEventRoomSize

# The amount of moves it takes to complete this puzzle.
@onready var _move_total := $Container/Grid/Grid2/MoveTotalSpinbox

# s: puzzle layout at the start of the level.
# e: puzzle layout at the end when the gift or prize is given.
	
# true if mouse is hovering over a puzzle blocked. this is needed so that if true and mouse is clicked then block can be displayed differently
var _is_mouse_selecting_block_s_location := false
var _is_mouse_selecting_block_e_location := false

# this is the selected block number refering to the block clicked, used to change the block's texture.
var _selected_block_number_s_location := - 1
var _selected_block_number_e_location := - 1

# this is the row and column coordinates refering to the location of the block that was selected. this is used to display a different texture for the block.
var _block_row_s_location := 0
var _block_row_e_location := 0

var _block_column_s_location := 0
var _block_column_e_location := 0

# the builder menu.
@onready var _menu = null


func _ready():
	Variables._at_scene = Enum.Scene.Builder
	# used at title_bar/ see HeaderMenu node.
	Variables._scene_title = "Builder: Event Puzzles."
	
	_event_number.value = Builder._event_puzzles.data.event_number + 1
	_on_event_number_Spinbox_value_changed(_event_number.value)
	
	_move_total.value = Builder._event_puzzles.data.move_total[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] + 1
	_on_move_total_Spinbox_value_changed(_move_total.value)
	
	if _menu == null:
		_menu = load("res://2d/source/scenes/builder/menu.tscn").instantiate()
		add_child( _menu )

	var value = Builder._event_puzzles.data.event_number + 1
	
	_display_puzzles(value)
	_did_mouse_select_block()
	
	_group_item_list.select(_group_item_list_index, true)
	
	_event_room_size.value = Builder._data.event_room_size[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number]
		
	_event_enabled.button_pressed = bool(Builder._event_puzzles.data.event_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number])
		
	# this needs to be near the bottom of this func, so to set _event_room_size to zero if this _event_enabled node equals zero because if this is disabled then the room size for the level needs to be smaller because the puzzle room size that uses the event would not need to be bigger.
	_on_EventEnabled_toggled(_event_enabled.button_pressed)

	
func _on_event_number_Spinbox_value_changed(value):
	_display_puzzles(value)
	
	Builder._event_puzzles.data.event_number = value - 1
	
	if bool(Builder._event_puzzles.data.event_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number]) == true:
		_event_enabled.button_pressed = true
	else:
		_event_enabled.button_pressed = false
		Builder._data.event_room_size[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] = 0
	
	_event_room_size.value = Builder._data.event_room_size[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] # not + 1
			
	_move_total.value = Builder._event_puzzles.data.move_total[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] + 1
	
	_group_item_list_index = Builder._event_puzzles.data.color_when_solved[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number]
	
	_group_item_list.select(_group_item_list_index, true)
	
	_dungeon_number.value = Builder._event_puzzles.data.dungeon_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] + 1
		
	_level_number.value = Builder._event_puzzles.data.level_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] + 1
		
	_update_coordinates_static()
	
		
func _input(event):
	# this changes the puzzle block appearence.
	if event is InputEventMouseButton && event.is_action_pressed("ui_left_mouse_click"):
		if _is_mouse_selecting_block_s_location == true:
			Builder._event_puzzles.data.coordinates_s_location[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number][_selected_block_number_s_location] += 1
			if Builder._event_puzzles.data.coordinates_s_location[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number][_selected_block_number_s_location] == 3:
				Builder._event_puzzles.data.coordinates_s_location[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number][_selected_block_number_s_location] = 0
			
			# display a different texture when mouse is clicked on a tile.
			get_node("Container/Grid/PuzzleStartSpritesRow" + str(_block_row_s_location) + "/Block" + str(_block_column_s_location)).texture = load("res://2d/assets/images/events/puzzles/builder_block" + str(Builder._event_puzzles.data.coordinates_s_location[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number][_selected_block_number_s_location]) + ".png")
			
			_update_coordinates_static()
			
	
	if event is InputEventMouseButton && event.is_action_pressed("ui_left_mouse_click"):
		if _is_mouse_selecting_block_e_location == true:
			Builder._event_puzzles.data.coordinates_e_location[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number][_selected_block_number_e_location] += 1
			if Builder._event_puzzles.data.coordinates_e_location[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number][_selected_block_number_e_location] == 3:
				Builder._event_puzzles.data.coordinates_e_location[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number][_selected_block_number_e_location] = 0
			
			# display a different texture when mouse is clicked on a tile.
			get_node("Container/Grid/PuzzleEndSpritesRow" + str(_block_row_e_location) + "/Block" + str(_block_column_e_location)).texture = load("res://2d/assets/images/events/puzzles/builder_block" + str(Builder._event_puzzles.data.coordinates_e_location[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number][_selected_block_number_e_location]) + ".png")
			
			_update_coordinates_static()

			
func _display_puzzles(value):
	_selected_block_number_s_location = - 1
	_selected_block_number_e_location = - 1
	
	for _r in range (1, 14):
		for _c in range (1, 14):
			_selected_block_number_s_location += 1
			
			get_node("Container/Grid/PuzzleStartSpritesRow" + str(_r) + "/Block" + str(_c)).texture = load("res://2d/assets/images/events/puzzles/builder_block" + str(Builder._event_puzzles.data.coordinates_s_location[Builder._config.game_id][Builder._data.dungeon_number][value - 1][_selected_block_number_s_location]) + ".png")
	
	_selected_block_number_s_location = - 1
	
	for _r in range (1, 14):
		for _c in range (1, 14):
			_selected_block_number_e_location += 1
					
			get_node("Container/Grid/PuzzleEndSpritesRow" + str(_r) + "/Block" + str(_c)).texture = load("res://2d/assets/images/events/puzzles/builder_block" + str(Builder._event_puzzles.data.coordinates_e_location[Builder._config.game_id][Builder._data.dungeon_number][value - 1][_selected_block_number_e_location]) + ".png")
	
	_selected_block_number_e_location = - 1
	
	
func _did_mouse_select_block():
	for _r in range (1, 14):
		for _i in range (1, 14):
			if get_node("Container/Grid/PuzzleStartSpritesRow" + str(_r) + "/Block" + str(_i)).is_connected("mouse_entered", Callable(self, "_on_mouse_s_entered")):
				get_node("Container/Grid/PuzzleStartSpritesRow" + str(_r) + "/Block" + str(_i)).disconnect("mouse_entered", Callable(self, "_on_mouse_s_entered"))
				
				get_node("Container/Grid/PuzzleStartSpritesRow" + str(_r) + "/Block" + str(_i)).disconnect("mouse_exited", Callable(self, "_on_mouse_s_exited"))
				
			# create the signals for the mosue entering/exiting the nodes.
			var _y = get_node("Container/Grid/PuzzleStartSpritesRow" + str(_r) + "/Block" + str(_i)).connect("mouse_entered", Callable(self, "_on_mouse_s_entered").bind(_r, _i, ((_r - 1) * 13) + _i))

			var _z = get_node("Container/Grid/PuzzleStartSpritesRow" + str(_r) + "/Block" + str(_i)).connect("mouse_exited", Callable(self, "_on_mouse_s_exited"))

	for _r in range (1, 14):
		for _i in range (1, 14):
			# disconnect any signals
			if get_node("Container/Grid/PuzzleEndSpritesRow" + str(_r) + "/Block" + str(_i)).is_connected("mouse_entered", Callable(self, "_on_mouse_e_entered")):
				get_node("Container/Grid/PuzzleEndSpritesRow" + str(_r) + "/Block" + str(_i)).disconnect("mouse_entered", Callable(self, "_on_mouse_e_entered"))
				
				get_node("Container/Grid/PuzzleEndSpritesRow" + str(_r) + "/Block" + str(_i)).disconnect("mouse_exited", Callable(self, "_on_mouse_e_exited"))
				
			# create the signals for the mosue entering/exiting the nodes.
			var _y = get_node("Container/Grid/PuzzleEndSpritesRow" + str(_r) + "/Block" + str(_i)).connect("mouse_entered", Callable(self, "_on_mouse_e_entered").bind(_r, _i, ((_r - 1) * 13) + _i))

			var _z = get_node("Container/Grid/PuzzleEndSpritesRow" + str(_r) + "/Block" + str(_i)).connect("mouse_exited", Callable(self, "_on_mouse_e_exited"))


func _on_mouse_s_entered(_row:int = 0, _column:int = 0, _num: int = 0):
	_selected_block_number_s_location = _num - 1
	_is_mouse_selecting_block_s_location = true
	_block_row_s_location = _row
	_block_column_s_location = _column	


func _on_mouse_e_entered(_row:int = 0, _column:int = 0, _num: int = 0):
	_selected_block_number_e_location = _num - 1
	_is_mouse_selecting_block_e_location = true
	_block_row_e_location = _row
	_block_column_e_location = _column	
	
		
func _on_mouse_s_exited():
	_is_mouse_selecting_block_s_location = false


func _on_mouse_e_exited():
	_is_mouse_selecting_block_e_location = false


func _on_ItemList_item_selected(index):
	_group_item_list_index = index
	_group_item_list.select(index, true)
	
	Builder._event_puzzles.data.color_when_solved[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] = _group_item_list_index
	
	_update_coordinates_static()
	

func _on_dungeon_number_Spinbox_value_changed(value):
	# store the current value in to the builder var.
	Builder._event_puzzles.data.dungeon_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] = value - 1
	
	_update_coordinates_static()


# this is triggered when a value is changed at the level spinbox	
func _on_level_Spinbox_value_changed(value):
	# store the current value in to the builder var.
	Builder._event_puzzles.data.level_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] = value - 1
	
	_update_coordinates_static()
	

func _on_move_total_Spinbox_value_changed(value):
	_move_total.value = value 
	
	# store the current value in to the builder var.
	Builder._event_puzzles.data.move_total[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] = value - 1	
	
	_update_coordinates_static()
	

func _on_EventEnabled_toggled(button_pressed):
	# update the builder event_enabled data. 	
	Builder._event_puzzles.data.event_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] = button_pressed
	
	if _event_enabled.button_pressed == false:	
		Builder._data.event_room_size[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] = 0
		_event_room_size.value = 0

	# using puzzle room if true.
	elif Builder._data.event_room_size[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] <= 0:
		Builder._data.event_room_size[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] = 15	
		
		# setup the vars to do the calculations because this room will be bigger than the rest of the rooms and because so that, extra map regions are needed.
		_event_room_size.value = 15
		
		var _room_total = Builder._data.room_total[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number]
		
		# this is the math formula used to create the size of the room.
		# TODO if game crashes, you can decrease this value of Settings._system.corridor_length_between_rooms or increase the _extra_room_size var below.
		var _math = float("0." + str(_room_total))
		if _room_total >= 10:
			_math = float(str(_room_total))
		
		var _extra_room_size = 0
		if Builder._data.event_room_size[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] > 0:
			_extra_room_size = 3.4 - int(Builder._data.room_size_max[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number]) / 10
			
		
		Builder._data.level_size[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] =  int(((Builder._data.room_size_max[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] * _room_total) * (3.3 - _math)) + _extra_room_size * Settings._system.corridor_length_between_rooms)
		
	_update_coordinates_static()
	
	
func _on_event_room_size_Spinbox_value_changed(value):
	# store the current value in to the builder var.
	Builder._data.event_room_size[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] = value # not - 1
	
	_update_coordinates_static()
	
	
func _on_StatusBar_tree_exiting():
	
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()


func _return_to_main_menu():	
	var _s = get_tree().change_scene_to_file("res://3d/scenes/gridmap.tscn")


func _update_coordinates_static():
	Builder._event_puzzles.data.coordinates_static_location[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number] = Builder._event_puzzles.data.coordinates_s_location[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_puzzles.data.event_number]
	
