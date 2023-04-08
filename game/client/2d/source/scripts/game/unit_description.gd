"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

onready var game = get_parent()
const TILE_SIZE = 32

# player, mobs, item, tile data. these vars will be passed to tile_summary scene for the label of overview panel. these vars hold data that can be accessed like a dictionary. for example, p_node._name to display the name of that entity.
onready var p_node = get_parent().get_node("Player")
var e_node = {"_name": "", "x": 0, "y": 0} # tile
var i_node = [] # item
var t_node = {"_name": "", "x": 0, "y": 0} # tile

# this is the distance between player and mobs in tiles.
var p_to_o_offset = Vector2(0, 0)

# timer to display the mouse summary.
onready var _timer_object_coordinate = get_node("Timer")

var mouse_player_offset = Vector2(0, 0) # this var is set at ready()

onready var _cursor = get_parent().get_node("Player/Cursor")


func _ready():
	p_to_o_offset.x = 0
	_cursor.set_offset(Vector2(16, 16))

	change_mouse_to_player_offset()
	
# this makes the square box that highlights the tile move currectly with the mouse cursor. without this code, the square box would change to a different tile but the mouse cursor might not be located at that tile or the mouse cursor might be offset to that tile.
func change_mouse_to_player_offset():
	if Settings._system.small_client_panel == false:
		if Settings._system.use_large_tiles == true:
			mouse_player_offset = Vector2(163, 51)
		else:
			mouse_player_offset = Vector2(220, 43)
	
	else:
		if Settings._system.use_large_tiles == true:
			mouse_player_offset = Vector2(163, -1)
		else:
			mouse_player_offset = Vector2(220, -30)


# the values of the vars in this func is determined both by the distance mouse is from player and the click event of the mouse at that position.
# this func calculates the mouse location, player's location and any offsets created from negative tile values and then outputs the tile number of where the mouse is positioned at. This func then gets the object at that location and then outputs that as tile description.
func unit_description():
	var player = game.player
	var mobs = game.mobs
	var items = game.items
	
	if Variables._child_scene_open == false:
		p_to_o_offset.x = 0
		p_to_o_offset.y = 0
					
		var pos = get_node("../Player").get_local_mouse_position()
		
		Variables._name.clear() 
		
		# move cursor to the left.
		for _i in range (0, 13):
			if pos.x + (mouse_player_offset.x + 19) >= -_i * 52 && pos.x + (mouse_player_offset.x + 19) <= (-_i * 52) + 52:
				_cursor.position.x = -(_i + 1 ) * 32
				p_to_o_offset.x = -_i - 1
			
		# move cursor to the right
		for _i in range (1, 13):
			if pos.x + (mouse_player_offset.x + 16) >= _i * 52 && pos.x + (mouse_player_offset.x + 16) <= (_i * 52) + 52:
				_cursor.position.x = (_i - 1 ) * 32
				p_to_o_offset.x = _i - 1
		
		# moves up.
		for _i in range (0, 13):
			if pos.y + (mouse_player_offset.y + 2) >= -_i * 51 && pos.y + (mouse_player_offset.y + 2) <= (-_i * 51) + 51:
				_cursor.position.y = -(_i + 1 ) * 32
				p_to_o_offset.y = -_i - 1
		
		# moves down
		for _i in range (1, 13):
			if pos.y + mouse_player_offset.y >= _i * 51 && pos.y + mouse_player_offset.y <= (_i * 51) + 51:
				_cursor.position.y = (_i - 1 ) * 32
				p_to_o_offset.y = _i - 1


		p_node = player
		
		for i in rand_range(1, 5):	
			# player node
			if i == 1:
				# get the tile coordinates of player.
				var c_node = Vector2(0, 0)
				c_node.x = player.position.x / 32
				c_node.y = player.position.y / 32
								
				if p_to_o_offset.x == 0 && p_to_o_offset.y == 0:
					unit_information_player()
			
			# mobs node.
			if i == 2:
				var c_node = Vector2(0, 0)
				c_node.x = player.position.x / 32
				c_node.y = player.position.y / 32
								
				# o_node is an object node. in this case, the object is an emnemy.
				for o_node in mobs:
					if e_node == null:
						e_node = o_node # e_node is the mobs. this var is passed to tile_summary. it holds all data like a dictionary.
						
					if o_node.tile.x == c_node.x + p_to_o_offset.x && o_node.tile.y == c_node.y + p_to_o_offset.y:	
						e_node = o_node # this is needed here so that the tile summary updates correctly. this code is also needed above, to stop a display bug.
						unit_information_mobs(o_node)
						
			# item node.			
			if i == 3:
				var c_node = Vector2(0, 0)
				c_node.x = player.position.x / 32
				c_node.y = player.position.y / 32
								
				if i_node == []:
					for o_node in items:
						if o_node.tile.x == c_node.x + p_to_o_offset.x && o_node.tile.y == c_node.y + p_to_o_offset.y:	
							i_node.push_back(o_node)
	
				for o_node in items:
					if o_node.tile.x == c_node.x + p_to_o_offset.x && o_node.tile.y == c_node.y + p_to_o_offset.y:	
						unit_information_item(o_node)
						
			# tile node.
			if i == 4:	
				t_node.x = player.position.x / 32
				t_node.y = player.position.y / 32
				
				var _tilemap = get_parent().get_node("TileMap").get_cell(t_node.x + p_to_o_offset.x , t_node.y + p_to_o_offset.y )
								
				if _tilemap > -1:					
					unit_information_tile(_tilemap)
					
					# this complicated code writes the tile name and its description to the t_node var.
					t_node._name = get_parent().get_node("TileMap").get_tileset().tile_get_name(get_parent().get_node("TileMap").get_cell(t_node.x + p_to_o_offset.x , t_node.y + p_to_o_offset.y )) 
					t_node._description = Tiles._dungeon1["level_" + str(Settings._game.level_number + 1)][Enum._tile_name[game.tile_map.get_cellv(Vector2(t_node.x + p_to_o_offset.x, t_node.y + p_to_o_offset.y))]]["Description"]
					
					# next, set the timer to display the mouse summary after a short delay.
					if _timer_object_coordinate.time_left == 0:
							_timer_object_coordinate.start()
							
					get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "tile_summary", "unit_text")
						

func unit_information_player():
	# at player node.
	if p_to_o_offset.x == 0 && p_to_o_offset.y == 0:
		Variables._name.append(p_node._name)
		
		var _found = false
		for _type in Variables._type:
			if _type == "player":
				_found = true
				
		if _found == false:
			Variables._type.append("player")
	

func unit_information_mobs(o_node):
	Variables._name.append(o_node._name.replace("_", " "))
	
	# if type equals mobs then cursor is at mobs tile.
	var _found = false
	for _type in Variables._type:
		if _type == "mobs":
			_found = true
			
	if _found == false:
		Variables._type.append("mobs")
		
	
func unit_information_item(o_node):
	Variables._name.append(o_node._name)
	
	var _found = false
	for _type in Variables._type:
		if _type == "item":
			_found = true
			
	if _found == false:
		Variables._type.append("item")
	
	
func unit_information_tile(_tilemap):
	var _found = false
	for _type in Variables._type:
		if _type == "tile":
			_found = true
			
	if _found == false:
		Variables._type.append("tile")
		
		
	var _name = get_parent().get_node("TileMap").tile_set.tile_get_name(_tilemap)
	if _name != "":
		Variables._name.append(_name)


# show the panel that has the player's stats, the mobs's stats, or other things, such as wall or door description.
func tile_summary():
	_timer_object_coordinate.stop()

	if p_node._name != "" || e_node._name != "" || i_node[i_node.size() - 1]._name != "" || t_node._name != "":		
		get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "tile_summary", "overview", p_node, e_node, i_node, t_node)
	
# display the mouse summary panel.
func _on_Timer_timeout():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "tile_summary", "summary")	
	_timer_object_coordinate.stop()
	

# this clears the item node when the mouse is moved. the reason is so a condition statement can recreate the items at the selected tile. without this code, one item at a tile would register as many.
func clear_i_node():
	i_node = []

