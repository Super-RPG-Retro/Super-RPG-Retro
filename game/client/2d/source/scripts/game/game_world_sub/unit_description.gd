"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


var _mouse_pos = Vector2i(-1, -1)
var _tile_pos = Vector2i(0, 0)
	
var _last_known_tile_pos := Vector2i(-1, -1)

@onready var game := get_parent()
const TILE_SIZE := 32

# player, mobs, item, tile data. these vars will be passed to tile_summary scene for the label of overview panel. these vars hold data that can be accessed like a dictionary. for example, p_node._name to display the name of that entity.
@onready var p_node := get_parent().get_node("Player")
var e_node # enemy
var i_node := [] # item
var t_node := {"_name": "", "x": 0, "y": 0} # tile

# timer to display the mouse summary.
@onready var _timer_object_coordinate := get_node("Timer")

var mouse_player_offset := Vector2(0, 0) # this var is set at ready()

@onready var _cursor := get_parent().get_node("Player/Cursor")


func _ready():
	_cursor.set_offset(Vector2(16, 16))
	set_process(true)
	

func _input(event):
	_mouse_pos = game.tile_map.get_global_mouse_position()
	_tile_pos = game.tile_map.local_to_map(_mouse_pos)
	
	if event is InputEventMouseMotion or event is InputEventScreenDrag or event is InputEventMouseButton and event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
		_last_known_tile_pos = Vector2i(-1, -1)
		_timer_object_coordinate.start()
		
		unit_description()


# the values of the vars in this func is determined both by the distance mouse is from player and the click event of the mouse at that position.
# this func calculates the mouse location, player's location and any offsets created from negative tile values and then outputs the tile number of where the mouse is positioned at. This func then gets the object at that location and then outputs that as tile description.
func unit_description():
	var player = game.player
	var mobs = game.mobs
	var items = game.items
		
	var _pos = get_node("../Player").get_local_mouse_position()
		
	var _tile_pos2 = game.tile_map.local_to_map(_pos)
		
	_cursor.position.x = _tile_pos2.x * 32
	_cursor.position.y = _tile_pos2.y * 32
	
	if _last_known_tile_pos != _tile_pos:
		# clear tile indormation.
		Variables._name.clear()
		Variables._type.clear()
		
		e_node # enemy
		i_node = [] # item
		
		p_node = player
		
		
		for i in randf_range(1, 4):	
			# player node
			if i == 1:
				# get the tile coordinates of player.
				var c_node = Vector2i(0, 0)
				c_node.x = player.position.x / 32
				c_node.y = player.position.y / 32
				
				if _tile_pos == c_node:
					unit_information_player()
			
			# mobs node.
			if i == 2:
				var c_node = Vector2i(0, 0)
								
				# o_node is an object node. in this case, the object is an emnemy.
				for o_node in mobs:
					c_node.x = o_node.tile.x
					c_node.y = o_node.tile.y
				
					if _tile_pos == c_node:
						e_node = o_node # e_node is the mobs. this var is passed to tile_summary. it holds all data like a dictionary.
						unit_information_mobs(o_node)
						
			# item node.			
			if i == 3:
				var c_node = Vector2i(0, 0)
				
				for o_node in items:
					c_node.x = o_node.tile.x
					c_node.y = o_node.tile.y
					
					if _tile_pos == c_node:
						i_node.append(o_node)
						unit_information_item(o_node)
						
		# tile node.	
		var _tile_id = game.tile_map.get_cell_source_id(0, Vector2i(_tile_pos))
		
		var _tile_name = Enum._tile_name[_tile_id]		
		_tile_name = _tile_name.capitalize()
		_tile_name = _tile_name.replace("_", " ")
		
		unit_information_tile(_tile_name)
		
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "tile_summary", "unit_text")
		_last_known_tile_pos = _tile_pos


func unit_information_player():
	var _found = false
	for _type in Variables._type:
		if _type == "player":
			_found = true
			
	if _found == false:
		Variables._name.append(p_node._name)
		Variables._type.append("player")
	

func unit_information_mobs(o_node):	
	# if type equals mobs then cursor is at mobs tile.
	var _found = false
	for _type in Variables._type:
		if _type == "mobs":
			_found = true
			
	if _found == false:
		Variables._name.append(o_node._name.replace("_", " "))
		Variables._type.append("mobs")
		
	
func unit_information_item(o_node):
	var _found = false
	for _type in Variables._type:
		if _type == "item":
			_found = true
			
	if _found == false:
		Variables._name.append(o_node._name)
		Variables._type.append("item")
	
	
func unit_information_tile(_tile_name):	
	var _found = false
	for _type in Variables._type:
		if _type == "tile":
			_found = true
			
	if _found == false:
		Variables._name.append(_tile_name)
		Variables._type.append("tile")
		
		t_node.x = _tile_pos.x
		t_node.y = _tile_pos.y
		
		t_node._name = _tile_name					
		t_node._description = Tiles._dungeon1["level_" + str(Settings._game.level_number + 1)][Enum._tile_name[game.tile_map.get_cell_source_id(0, Vector2i(t_node.x, t_node.y))]]["Description"]


# show the panel that has the player's stats, the mobs's stats, or other things, such as wall or door description.
func tile_overview():
	_timer_object_coordinate.stop()
	
	# go to tile overview if user selected a valid tile.
	get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "tile_summary", "overview", p_node, e_node, i_node, t_node)
	
# display the mouse summary panel.
func _on_Timer_timeout():
	if Variables.mouse_at_viewport == true:
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "tile_summary", "summary")	
		_timer_object_coordinate.stop()
	

