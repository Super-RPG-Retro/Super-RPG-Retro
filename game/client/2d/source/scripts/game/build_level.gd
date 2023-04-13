"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

onready var game = get_parent()
onready var reference = get_parent().get_node("Reference")


func _ready():
	pass


# start with a blank map. do this also for the first map.
func build_level():
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/settings_game.txt", Settings._game)
	
	game.rooms.clear()
	game.room_number = -1
	game.floor_rooms.clear()
	game.floor_rooms_size.clear()
	game.ceiling.clear()
	game.doors.clear()
	game.map.clear()
	game.tile_map.clear()
	
	# clear all mobs in the list. remove removes mobs from scene and clear nulls the mobs array.
	for mobs in game.mobs:
		mobs.remove()
	game.mobs.clear()
	
	# do the same for the list of items.
	for item in game.items:
		item.remove()
	game.items.clear()
	
	for icon in game.icons:
		icon.remove()
	game.icons.clear()

	for block in game.puzzle_blocks:
		game.remove_child(block._sprite_scene)
		block.remove()
		block = null
	game.puzzle_blocks.clear()
	
	# start by creating astar for this level. see clear_path()
	game._mobs_pathfinding = AStar.new()
	
	# Randomize potion effects
	game.potion_types = game.POTION_FUNCTIONS.duplicate()
		
	# load a saved level here.
	var _temp = Filesystem.load_visibility_map(game.LEVEL_SIZE, game.visibility_map)
	
	for x in range(game.LEVEL_SIZE):
		game.map.append([])
		for y in range(game.LEVEL_SIZE):
			# dungeon level is saved when player uses a ladder. if this value is null then dungeon level has not been saved. make these values zero, which is the default value when first entering a dungeon level.
			if _temp == null:
				game.visibility_map_saved.set_cellv(Vector2(x, y), 0)
			else:
				game.visibility_map_saved.set_cellv(Vector2(x, y), _temp.get_cell(x, y))
			
			#for every x and y coordinate, create the scene filled with stone walls. later other objects will be placed overtop of that wall, such as a room, floor or an empty cell.
			game.map[x].append(Enum.Tile.Stone)
			
			if Settings._system.hide_stone_walls == false:
				game.tile_map.set_cellv(Vector2(x, y), Enum.Tile.Stone)
				
				
			# for each tile in the visibility map, set index to the first tile since that is the only tile at its tile map.
			game.visibility_map.set_cellv(Vector2(x, y), game.visibility_map_saved.get_cellv(Vector2(x, y))) # the third parameter here, if not saving, has a value of zero.
	
			
	# Rect2 consists of a position, a size, and several utility Common. It is typically used for fast overlap tests. 
	# create a 4 tile margin around all side of the level. That is so i can add walls, doors, windows and still have 1 tile for walking.
	# see folder ref/1-0.png
	var free_regions = [Rect2(Vector2(4, 4), Vector2(game.LEVEL_SIZE, game.LEVEL_SIZE) - Vector2(6, 6))]
	
	# try to add room to free space.
	for _i in range(game._total_level_room):
		# the add_room function will add rooms to free regions.
		game.room_number += 1
		add_room(free_regions)
		# stop adding rooms if the remainder free space in level is empty.
		if free_regions.empty():
			break
			
	connect_rooms()
	
	# array element 0, room 1, is a puzzle room.
	var start_room = game.rooms[1]
	
	# place player in random room, excluding the outer most tiles because those are walls
	var player_x = start_room.position.x + 1 + randi() % int(start_room.size.x - 2)
	
	var player_y = start_room.position.y + 1 + randi() % int(start_room.size.y - 2)
	
	if Variables._at_library == false:
		Variables._dungeon_coordinates = str(player_x) + "," + str(player_y)
	
	# do not place ladder beside a door.
	# since ladder_up is set to position of player, changing player's position will change ladder_up.
	# first check if at position is a door, then check if player moves away from door if that position is a floor.	
	if Enum.Tile.Door == game.tile_map.get_cellv(Vector2(player_x - 1, player_y)) && game.tile_map.get_cellv(Vector2(player_x + 1, player_y)) == Enum.Tile.Floor || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(player_x - 1, player_y)) && game.tile_map.get_cellv(Vector2(player_x + 1, player_y)) == Enum.Tile.Ceiling || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(player_x - 1, player_y)) && game.tile_map.get_cellv(Vector2(player_x + 1, player_y)) == Variables._floor_rooms_tile_value:
		player_x += 1
		
	if Enum.Tile.Door == game.tile_map.get_cellv(Vector2(player_x, player_y - 1)) && game.tile_map.get_cellv(Vector2(player_x, player_y + 1)) == Enum.Tile.Floor || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(player_x, player_y - 1)) && game.tile_map.get_cellv(Vector2(player_x, player_y + 1)) == Enum.Tile.Ceiling || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(player_x, player_y - 1)) && game.tile_map.get_cellv(Vector2(player_x, player_y + 1)) == Variables._floor_rooms_tile_value:
		player_y += 1
		
	if Enum.Tile.Door == game.tile_map.get_cellv(Vector2(player_x + 1, player_y)) && game.tile_map.get_cellv(Vector2(player_x - 1, player_y)) == Enum.Tile.Floor || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(player_x + 1, player_y)) && game.tile_map.get_cellv(Vector2(player_x - 1, player_y)) == Enum.Tile.Ceiling || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(player_x + 1, player_y)) && game.tile_map.get_cellv(Vector2(player_x - 1, player_y)) == Variables._floor_rooms_tile_value:
		player_x -= 1
		
	if Enum.Tile.Door == game.tile_map.get_cellv(Vector2(player_x, player_y + 1)) && game.tile_map.get_cellv(Vector2(player_x, player_y - 1)) == Enum.Tile.Floor || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(player_x, player_y + 1)) && game.tile_map.get_cellv(Vector2(player_x, player_y - 1)) == Enum.Tile.Ceiling || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(player_x, player_y + 1)) && game.tile_map.get_cellv(Vector2(player_x, player_y - 1)) == Variables._floor_rooms_tile_value:
		player_y -= 1
	
	# when game first starts or after going down a ladder, show player standing at the ladder_up.
	set_tile(player_x, player_y, Enum.Tile.Ladder_up)
	game._player_tile = Vector2(player_x, player_y)
	
	if Variables._reset_player == true:
		Variables._reset_player = false
		game._player_tile = Variables._reset_player_position
		
	# set the end room. this room is randomly selected. it could be directly beside the start room. 
	var end_room = game.rooms.back()
	
	# ladder is also randomly selected inside a room. x + 1, x - 2, y + 1 and y - 1 exclude wall positions. 
	var ladder_x = end_room.position.x + 1 + randi() % int(end_room.size.x - 2)
	var ladder_y = end_room.position.y + 1 + randi() % int(end_room.size.y - 2)
	
	var _ladder_move_x = 0
	var _ladder_move_y = 0
	
	# do not place ladder_down beside a door.
	# first check if next to ladder_down is a door, then check if 1 tile from that door is a floor. if door is found then ladder will be 1 tile from that door.	
	if Enum.Tile.Door == game.tile_map.get_cellv(Vector2(ladder_x - 1, ladder_y)) && game.tile_map.get_cellv(Vector2(ladder_x + 1, ladder_y)) == Enum.Tile.Floor || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(ladder_x - 1, ladder_y)) && game.tile_map.get_cellv(Vector2(ladder_x + 1, ladder_y)) == Enum.Tile.Ceiling || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(ladder_x - 1, ladder_y)) && game.tile_map.get_cellv(Vector2(ladder_x + 1, ladder_y)) == Variables._floor_rooms_tile_value:
		_ladder_move_x += 1
		
	elif Enum.Tile.Door ==  game.tile_map.get_cellv(Vector2(ladder_x, ladder_y - 1)) && game.tile_map.get_cellv(Vector2(ladder_x, ladder_y + 1)) == Enum.Tile.Floor || Enum.Tile.Door ==  game.tile_map.get_cellv(Vector2(ladder_x, ladder_y - 1)) && game.tile_map.get_cellv(Vector2(ladder_x, ladder_y + 1)) == Enum.Tile.Ceiling || Enum.Tile.Door ==  game.tile_map.get_cellv(Vector2(ladder_x, ladder_y - 1)) && game.tile_map.get_cellv(Vector2(ladder_x, ladder_y + 1)) == Variables._floor_rooms_tile_value:
		_ladder_move_y += 1
				
	elif Enum.Tile.Door == game.tile_map.get_cellv(Vector2(ladder_x + 1, ladder_y)) && game.tile_map.get_cellv(Vector2(ladder_x - 1, ladder_y)) == Enum.Tile.Floor || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(ladder_x + 1, ladder_y)) && game.tile_map.get_cellv(Vector2(ladder_x - 1, ladder_y)) == Enum.Tile.Ceiling || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(ladder_x + 1, ladder_y)) && game.tile_map.get_cellv(Vector2(ladder_x - 1, ladder_y)) == Variables._floor_rooms_tile_value:
		_ladder_move_x -= 1
		
	elif Enum.Tile.Door == game.tile_map.get_cellv(Vector2(ladder_x, ladder_y + 1)) && game.tile_map.get_cellv(Vector2(ladder_x, ladder_y - 1)) == Enum.Tile.Floor || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(ladder_x, ladder_y + 1)) && game.tile_map.get_cellv(Vector2(ladder_x, ladder_y - 1)) == Enum.Tile.Ceiling || Enum.Tile.Door == game.tile_map.get_cellv(Vector2(ladder_x, ladder_y + 1)) && game.tile_map.get_cellv(Vector2(ladder_x, ladder_y - 1)) == Variables._floor_rooms_tile_value:
		_ladder_move_y -= 1
	
	# next we set the tile at that coordinate for a ladder.
	set_tile((ladder_x + _ladder_move_x), (ladder_y + _ladder_move_y), Enum.Tile.Ladder_down)
	
	Variables._ladder_down = Vector2((ladder_x + _ladder_move_x), (ladder_y + _ladder_move_y))
	
	# set ceiling for ladder_down.
	if Settings._game.room_ceiling == true && Settings._game.down_ladder_always_shown == false:		
		game.overlay_map.set_cellv(Variables._ladder_down, Enum.Tile_Overlay.Ceiling)
			
	# without this code, you cannot return to the previous level.
	if Variables._going_down_level == false:
		player_x = Variables._ladder_down.x
		player_y = Variables._ladder_down.y 
		
		set_tile(player_x, player_y, Enum.Tile.Ladder_down)
		game._player_tile = Vector2(player_x, player_y)
	
		game.overlay_map.set_cellv(Variables._ladder_down, -1)
	
	# Place mobs
	# look at how many mobs there shall be.
	var num_mobs = game._total_level_enemy
	
	# this loops thru the amount of mobs to place in the room.
	for _i in range(num_mobs):
		var room
		var x
		var y
		
		# pick a room, excluding the first room. this code seems to stop a bug where once in a rare event, mobs will be placed in the first room.
		room = current_room()
		while( start_room == room):
			room = current_room() 
		
		# and place the mobs at position on the map and excluding the walls of the room.
		x = room.position.x + 1 + randi() % int(room.size.x - 2)
		y = room.position.y + 1 + randi() % int(room.size.y - 2)
		
		var blocked = false
		
		# check if the tile has an mobs already in it.
		for mobs in game.mobs:    
			if mobs.tile.x == x && mobs.tile.y == y:
				blocked = true
				break
		
		# if its not blocked then i will create an instance of that mobs by passing a reference to this node, random mobs level and its x and y coordinates.
		if !blocked:
			if game._total_enemy_at_level > 0:
				# prepare to place mobs on map..
				for _l in range(game._total_level_enemy):
					var mobs
					
					# do not create mobs at ladder_down location.
					if Enum.Tile.Ladder_down !=  	get_parent().get_node("TileMap").get_cell(x, y):
						mobs = reference.Mobs.new(self, Settings._game.level_number, x, y, game._level_enemies_names, game._total_enemy_at_level)
						
						# add it to the mobs list.
						game.mobs.append(mobs)
						break # stop a possible stack of mobs on each other.
				
	# Place items randomly around the level. pick a room, including the starting room. 
	for _i in range(game._total_level_item): # how many items in the item list.
		var room = game.rooms[randi() % (game.rooms.size())]
		# don't put items on wall. place them in room var and position x/y.
		var x = room.position.x + 1 + randi() % int(room.size.x - 2)
		var y = room.position.y + 1 + randi() % int(room.size.y - 2)
		
		# if 0: paper, else 1: a potion. 
		var _item:int = randi() % 2
		
		# Item.new, calls a new instance of the item. see the constructor, init.
		game.items.append(reference.Item.new(self, x, y, _item, game.LEVEL_ITEM_NAMES[_item]))
	
	# update the room at next frame.
	game.call_deferred("update_visuals")
	
	if Settings._system.remove_extra_stone_walls == true:
		var _neat = []
		for x in range(game.LEVEL_SIZE):
			for y in range(game.LEVEL_SIZE):
				# The Stone tiles that surrounds the room and the Stone tiles that surrounds the corridor will remain on the map. All other Stone tile will be removed.
				# for every tile in loop, search every tile that surrounds the room. set tile as stone if the condition fails.
				if x > 0 && x < game.LEVEL_SIZE - 1 && y > 0 && y < game.LEVEL_SIZE - 1:
					if game.map[x][y-1] == Enum.Tile.Stone && game.map[x+1][y-1] == Enum.Tile.Stone && game.map[x+1][y] == Enum.Tile.Stone && game.map[x+1][y+1] == Enum.Tile.Stone && game.map[x][y+1] == Enum.Tile.Stone && game.map[x-1][y+1] == Enum.Tile.Stone && game.map[x-1][y] == Enum.Tile.Stone && game.map[x-1][y+1] == Enum.Tile.Stone:
						_neat.append(Vector2(x, y))
	
				# remove every one tile wide Stone tile that borders the level.
				if Settings._system.remove_level_border == true:
					if x == 0 || x == game.LEVEL_SIZE - 1 || y == 0 || y == game.LEVEL_SIZE - 1:
						game.map[x].append(Enum.Tile.Ceiling)
						game.tile_map.set_cellv(Vector2(x, y), Enum.Tile.Ceiling)
				
		# hide the extra stone walls. only the stone walls that touch the corridor will be displayed.
		for _n in _neat:
			set_tile(_n.x, _n.y, Enum.Tile.Ceiling)
	
	
	for x in range(game.LEVEL_SIZE):
		for y in range(game.LEVEL_SIZE):
			# mobs can walk on floors.
			if game.tile_map.get_cellv(Vector2(x, y)) == Enum.Tile.Floor:
				clear_path(Vector2(x, y)) 
			
			if game.tile_map.get_cellv(Vector2(x, y)) == Enum.Tile.Floor_rooms:
				clear_path(Vector2(x, y))
	
	if Builder._data.store_items_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] == 1:
		_add_icons(0)
		
	if Builder._data.store_armor_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] == 1:
		_add_icons(1)
	
	if Builder._data.store_weapons_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] == 1:
		_add_icons(2)
	
	if Builder._data.save_point_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] == 1:
		_add_icons(3)
	
# store, save point...
# 0:store, 1:save point.
func _add_icons(_id):
	var _do_again:bool = true	
	
	while(_do_again == true):
		var _icons_at_room = []
		randomize()
		
		# don't include the walls of the room.
		# if size of a room is 7-7 then this output will be 1-6. a value of 0 or 7 would be the wall.
		var _x = int(rand_range(1, game.rooms[1].size.x))
		var _y = int(rand_range(1, game.rooms[1].size.y))
		
		if game.tile_map.get_cellv(Vector2(game.rooms[1].position.x + _x, game.rooms[1].position.y + _y)) == Enum.Tile.Floor || game.tile_map.get_cellv(Vector2(game.rooms[1].position.x + _x, game.rooms[1].position.y + _y)) == Enum.Tile.Floor_rooms:
			_do_again = false
			
			for icon in game.icons:
				if icon.tile.x == game.rooms[1].position.x + _x && icon.tile.y == game.rooms[1].position.y + _y: 
					_do_again = true
		
			# should there be a store at this level?
			if _do_again == false:
				game.icons.append(reference.Icons.new(self, game.rooms[1].position.x + _x, game.rooms[1].position.y + _y, _id))



# pick a room,to place mobs in but excluding the first room if that room is a puzzle room.	
func current_room():
	var room:Rect2
	
	# change to % (game.rooms.size() - 1 to exclude mobs at down ladder room.
	if game._puzzle_room_dimension > 0:
		room = game.rooms[1 + randi() % (game.rooms.size())]
	else:
		room = game.rooms[randi() % (game.rooms.size())]
		
	return room
	
	
# this func will add a point to the graph, when player opens door, where the point in the maze can move through.
func clear_path(tile):
	# we get the next available id and add the point.
	var new_point = game._mobs_pathfinding.get_available_point_id()
	game._mobs_pathfinding.add_point(new_point, Vector3(tile.x, tile.y, 0))
	
	# i will be building a list of points to connect to and i will add the connects at the end of this func.
	var points_to_connect = []
	
	# similar to how we connected the rooms, To get the graph point for these adjacent tiles, I will check for adjacent tiles are floor and connect them as so. I will be specifying closest points.
	if Settings._game.keep_mobs_in_room == false:
		if tile.x > 0 && game.map[tile.x - 1][tile.y] == Enum.Tile.Floor:
			points_to_connect.append(game._mobs_pathfinding.get_closest_point(Vector3(tile.x - 1, tile.y, 0)))

		# this time i will be checking down and to the right because these points might already be added.
		if tile.y > 0 && game.map[tile.x][tile.y - 1] == Enum.Tile.Floor:
			points_to_connect.append(game._mobs_pathfinding.get_closest_point(Vector3(tile.x, tile.y - 1, 0)))
		
		if tile.x < game.LEVEL_SIZE - 1 && game.map[tile.x + 1][tile.y] == Enum.Tile.Floor:
			points_to_connect.append(game._mobs_pathfinding.get_closest_point(Vector3(tile.x + 1, tile.y, 0)))
		
		if tile.y < game.LEVEL_SIZE - 1 && game.map[tile.x][tile.y + 1] == Enum.Tile.Floor:
			points_to_connect.append(game._mobs_pathfinding.get_closest_point(Vector3(tile.x, tile.y + 1, 0)))
		
	if tile.x > 0 && game.map[tile.x - 1][tile.y] == Variables._floor_rooms_tile_value:
		points_to_connect.append(game._mobs_pathfinding.get_closest_point(Vector3(tile.x - 1, tile.y, 0)))

	# this time i will be checking down and to the right because these points might already be added.
	if tile.y > 0 && game.map[tile.x][tile.y - 1] == Variables._floor_rooms_tile_value:
		points_to_connect.append(game._mobs_pathfinding.get_closest_point(Vector3(tile.x, tile.y - 1, 0)))
	
	if tile.x < game.LEVEL_SIZE - 1 && game.map[tile.x + 1][tile.y] == Variables._floor_rooms_tile_value:
		points_to_connect.append(game._mobs_pathfinding.get_closest_point(Vector3(tile.x + 1, tile.y, 0)))
	
	if tile.y < game.LEVEL_SIZE - 1 && game.map[tile.x][tile.y + 1] == Variables._floor_rooms_tile_value:
		points_to_connect.append(game._mobs_pathfinding.get_closest_point(Vector3(tile.x, tile.y + 1, 0)))
		
	# now we just loop through and make the connections.
	for point in points_to_connect:
		if point != new_point:
			game._mobs_pathfinding.connect_points(point, new_point)



func connect_rooms():
	# Build an AStar graph of the area where we can add corridors. AStar is used for pathfinding. all that is needed is a list of points that you can make a path through, on how they are all connected and thus defining a graph. AStar can give the shortest path on that graph.
	# see folder ref/0.9.png
	
	var stone_graph = AStar.new()
	# For all the stones outside the graph is fair game, so add each stone tile as a point.
	var point_id = 0
	
	for x in range(game.LEVEL_SIZE):
		for y in range(game.LEVEL_SIZE):
			if game.map[x][y] == Enum.Tile.Stone:
				stone_graph.add_point(point_id, Vector3(x, y, 0))
				
				# when the connection is in the adjacent tiles, I will check the connection to the left and add a connection if its stone.
				# Connect to left if also stone
				if x > 0 && game.map[x - 1][y] == Enum.Tile.Stone:
					var left_point = stone_graph.get_closest_point(Vector3(x - 1, y, 0))
					stone_graph.connect_points(point_id, left_point)
					
				# the same as the above but I do not check down to the right because i will make a left connections when i am there.
				# Connect to above if also stone
				if y > 0 && game.map[x][y - 1] == Enum.Tile.Stone:
					var above_point = stone_graph.get_closest_point(Vector3(x, y - 1, 0))
					stone_graph.connect_points(point_id, above_point)
				
				# each point will now have an unique identifier
				point_id += 1

	# Build an AStar graph of room connections
	
	# this time instead of doing tile by tile we check to see if there are rooms connected so we can add a path to all of them.
	var room_graph = AStar.new()
	point_id = 0
	
	# I will add each room as a point but to start with there are no connections.
	for room in game.rooms:
		var room_center = room.position + room.size / 2
		room_graph.add_point(point_id, Vector3(room_center.x, room_center.y, 0))
		point_id += 1
		
	# Add random connections until everything is connected
	# we need a helper func to see if everything is connected and another one to add a random connection.
	while !is_everything_connected(room_graph):
		add_random_connection(stone_graph, room_graph)

# first I will get a list of points that correspond to rooms then pick one to start from because all the connections are bidirectional and i only need to use one starting point. If you can get everywhere from there that means you can get everywhere from anywhere else.  
func is_everything_connected(graph):
	var points = graph.get_points()
	var start = points.pop_back()
	
	# for every point in points, I will try to get a path. if that failed, something is not connected. If the loop does not fail then everything is connected.
	for point in points:
		var path = graph.get_point_path(start, point)
		if !path:
			return false
	
	return true

# this is the path to the room. the corridor floor.
# lets add the connections. to stop this from getting to complicated, we need more helper Common.
func add_random_connection(stone_graph, room_graph):
	# Pick rooms to connect
	
	# at the first attempt, I picked a start and end room at random, but i felt that started with too many connections. I get better results by always picking a room with the least connections. deciding at random when ever there is a tie.
	var start_room_id = get_least_connected_point(room_graph)
	
	# then i connect to a room that is not already connected to.
	var end_room_id = get_nearest_unconnected_point(room_graph, start_room_id)
	
	# Pick door locations
	# then i need to pick a location at random, where to place the doors with another helper func.
	var start_position = pick_random_door_location(game.rooms[start_room_id])
	var end_position = pick_random_door_location(game.rooms[end_room_id])
	
	# Find a path to connect the doors to each other
	# we have got are start and end door location, and i know that "stone.png" astar graph with a point to each because the room start out surround by stone. so i will get the closest point to each door and ask astar for the path between them.
	var closest_start_point = stone_graph.get_closest_point(start_position)
	var closest_end_point = stone_graph.get_closest_point(end_position)
	
	var path = stone_graph.get_point_path(closest_start_point, closest_end_point)
	
	# i am putting an assert here because it should not fail, but if it does then i will know about it. 
	assert(path)
	path = Array(path)
	
	# now that we have the path, we will add it to the map. I will start by setting the door tiles in oppisite direction. starting from bottom-right to top-left. a horizontal room wall can have two doors. in that example, the first door that might be drawn, at the beginning of that wall, is "start" and the second door, that might exists, will be "end".
	if Settings._game.normal_doors_exist == true:
		set_tile(start_position.x, start_position.y, Enum.Tile.Door)
		set_tile(end_position.x, end_position.y, Enum.Tile.Door)
	else:
		set_tile(start_position.x, start_position.y, Enum.Tile.Floor)
		set_tile(end_position.x, end_position.y, Enum.Tile.Floor)
		
		
	game.doors.append(Vector2(start_position.x, start_position.y))
	game.doors.append(Vector2(end_position.x, end_position.y))
	
	# for each position along the path, we will be replacing the stone floor.
	for position in path:
		set_tile(position.x, position.y, Enum.Tile.Floor)
		
		# Hide a corridor to make the game a bit more difficult but only if set from builder.
		# for this feature to work, Set hide_stone_walls to true at builder. Hide a corridor from room one and a random room. Only a random value from 0 to 3 is used. When creating the corridors, The last preset room is excluded since that room is used to create the corridors.
		if end_room_id == 0 && Builder_playing._data.hide_random_corridor[Builder._config.game_id][Builder._data.dungeon_number][Builder._data.level_number] == 1 && Settings._system.hide_stone_walls == true:
			game.overlay_map.set_cellv(Vector2(position.x, position.y), Enum.Tile_Overlay.Ceiling)
				
	# lastly, i will update the room graph because the two rooms are now connected.
	room_graph.connect_points(start_room_id, end_room_id)	

	# i am not changing the stone graph because I want to allow paths to intersect. that means we will get branching corridors. This makes for easer coding.
	
# least connected room (point)
func get_least_connected_point(graph):
	var point_ids = graph.get_points()
	
	# we get the least of points which start with the full list of points. least holds the lowest connections seen so far.
	var least
	# tied for least is a list of points with least of that many connections.
	var tied_for_least = []
	
	# looping through the list, i will check the connections. 
	for point in point_ids:
		var count = graph.get_point_connections(point).size()
		
		# if we have not set that least var yet, or if this number is lower, i will reset the least seen and reset the list to only contain this point. 
		if !least || count < least:
			least = count
			tied_for_least = [point]
			
		# otherwise, if this point is tied with the current least, i will add it to the list.
		elif count == least:
			tied_for_least.append(point)
	
	# then at the end i will just pick one at random for the list.
	return tied_for_least[randi() % tied_for_least.size()]
	
# finding the nearest distance between an unconnected point will be very similar to the above func. except instead of finding the connections we want nearest distance.
func get_nearest_unconnected_point(graph, target_point):
	var target_position = graph.get_point_position(target_point)
	var point_ids = graph.get_points()
	
	var nearest
	var tied_for_nearest = []
	
	for point in point_ids:
		# We do not want to connect a room to itself so we will skip this.
		if point == target_point:
			continue
		
		# skip then if there is already a path connecting the two rooms.
		var path = graph.get_point_path(point, target_point)
		if path:
			continue
		
		# same as above func get_least_connected_point	
		var dist = (graph.get_point_position(point) - target_position).length()
		if !nearest || dist < nearest:
			nearest = dist
			tied_for_nearest = [point]
		elif dist == nearest:
			tied_for_nearest.append(point)
			
	return tied_for_nearest[randi() % tied_for_nearest.size()]

# now for picking a door location, this is for putting a 1 tile gap around all the rooms makes thing way easer. I know there is space around the room at every side where there is a corridor. so i can put a door on every wall.
func pick_random_door_location(room):
	var options = []
	
	# Top and bottom walls
	
	# if a value of 0 then the door will be placed at the right side wall in a room.
	var _int = rand_range(0, 1)
	
	if round(_int) == 0:
		# a will just go along the width and add each tile along the top and bottom to a list of options.
		for x in range(room.position.x + 1, room.end.x - 2):
			options.append(Vector3(x, room.position.y, 0))
			options.append(Vector3(x, room.end.y - 1, 0))
			break
			
		# then i will do the sides. skipping the top and bottom wall, just like when I was adding wall tiles. 
		for y in range(room.position.y + 1, room.end.y - 2):
			options.append(Vector3(room.position.x, y, 0))
			options.append(Vector3(room.end.x - 1, y, 0))
			break
	
	# start at left side of room.
	else:
		for x in range(room.end.x - 2, room.position.x + 1, -1):
			options.append(Vector3(x, room.position.y, 0))
			options.append(Vector3(x, room.end.y - 1, 0))
			break
			
		for y in range(room.end.y - 2, room.position.y + 1, -1):
			options.append(Vector3(room.position.x, y, 0))
			options.append(Vector3(room.end.x - 1, y, 0))
			break
	
	
	# then i will pick one of these options as random.
	return options[randi() % options.size()]


func add_room(free_regions):
	var _min_room_dimensions
	if game._puzzle_room_dimension > 0 && game.room_number == 0:
		_min_room_dimensions = game._puzzle_room_dimension
	else:
		_min_room_dimensions = game._min_room_dimension
	
	# add_rooms will select a random region of free space in the level.
	var region = free_regions[randi() % free_regions.size()]
		
	var size_x = _min_room_dimensions 
	
	# check if the random size of the region can go bigger.
	if region.size.x > _min_room_dimensions:
		# add a random amount to the region size with an extra amount to go bigger. That extra amount will always be a value of 1 because of the condition above so to avoid the division by zero.
		# see folder ref/1-1.png
		size_x += randi() % int(region.size.x - _min_room_dimensions)
	
	# do the same for this y region
	var size_y = _min_room_dimensions
	if region.size.y > _min_room_dimensions:
		size_y += randi() % int(region.size.y - _min_room_dimensions)
	
	var _max_room_dimensions
	if game._puzzle_room_dimension > 0 && game.room_number == 0:
		_max_room_dimensions = game._puzzle_room_dimension
	else:
		_max_room_dimensions = game._max_room_dimension
		
	# constrain the size we found earlier to the max dimensions a room can have. 
	size_x = min(size_x, _max_room_dimensions)
	size_y = min(size_y, _max_room_dimensions)
	
	# at min the start x will be the start of the region but if there is extra space we will add a region amount up the the region available.
	# see ref 1-2.png
	var start_x = region.position.x
	if region.size.x > size_x:
		start_x += randi() % int(region.size.x - size_x)
		
	var start_y = region.position.y
	if region.size.y > size_y:
		start_y += randi() % int(region.size.y - size_y)
	
	# bundle up the x and y and put them in a rooms list. So the first room will be room[0]
	var room
		
	
	# top left - X
	# if a room is too close to another room then return to this func and try for another random location. this code check for room touching room and room two tiles from another room. there is a bug where when a room is too close to another room, sometimes a door is not drawn.
	if game.tile_map.get_cell(start_x - 1, start_y) == Enum.Tile.Wall:
		add_room(free_regions)
		return
	# there must be more than one tile seperating each room.
	if game.tile_map.get_cell(start_x - 2, start_y) == Enum.Tile.Wall:
		add_room(free_regions)
		return
	
	# top right corner
	if game.tile_map.get_cell(start_x + size_x + 1, start_y) == Enum.Tile.Wall:
		add_room(free_regions)
		return
	if game.tile_map.get_cell(start_x + size_x + 2, start_y) == Enum.Tile.Wall:
		add_room(free_regions)
		return
	
	# bottom left
	if game.tile_map.get_cell(start_x - 1, start_y + size_y) == Enum.Tile.Wall:
		add_room(free_regions)
		return
	if game.tile_map.get_cell(start_x - 2, start_y + size_y) == Enum.Tile.Wall:
		add_room(free_regions)
		return
	
	# bottom right corner
	if game.tile_map.get_cell(start_x + size_x + 1, start_y + size_y) == Enum.Tile.Wall:
		add_room(free_regions)
		return
	if game.tile_map.get_cell(start_x + size_x + 2, start_y + size_y) == Enum.Tile.Wall:
		add_room(free_regions)
		return
		
	# top left - Y
	# stop rooms touching each other. if there is a room to the right then move this room one tile to the left.
	if game.tile_map.get_cell(start_x, start_y - 1) == Enum.Tile.Wall:
		add_room(free_regions)
		return
	# this code moves a room that is too close.
	if game.tile_map.get_cell(start_x, start_y - 2) == Enum.Tile.Wall:
		add_room(free_regions)
		return
	
	# top right corner
	if game.tile_map.get_cell(start_x + size_x, start_y - 1) == Enum.Tile.Wall:
		add_room(free_regions)
		return
	if game.tile_map.get_cell(start_x + size_x, start_y - 2) == Enum.Tile.Wall:
		add_room(free_regions)
		return
	
	# bottom left corner
	if game.tile_map.get_cell(start_x, start_y + size_y + 1) == Enum.Tile.Wall:
		add_room(free_regions)
		return		
	if game.tile_map.get_cell(start_x, start_y + size_y + 2) == Enum.Tile.Wall:
		add_room(free_regions)
		return
	
	# bottom right corner
	if game.tile_map.get_cell(start_x + size_x, start_y + size_y + 1) == Enum.Tile.Wall:
		add_room(free_regions)
		return
	if game.tile_map.get_cell(start_x + size_x, start_y + size_y + 2) == Enum.Tile.Wall:
		add_room(free_regions)
		return
		
	# sometimes the event room overlaps the normal room. the reason is the top/bottom wall corner room checks above this line does not detect the other rooms. the reason is the smaller rooms can fit part inside of the event room and the event room top/bottom wall corners are outside of that normal room borders. so the corner code of the event room fails to find the normal room.
	# this code checks the event room at the region where it will be made, for any walls that may be at that region. if fail, the code will reenter this func for another try.
	# do this for every room.
	for x in range (size_x): # current size of room to be made.
		for y in range (size_y):
			if game.tile_map.get_cell(start_x + x, start_y + y) == Enum.Tile.Wall:
				add_room(free_regions)
				return
			
	room = Rect2(start_x, start_y, size_x, size_y)
	
	game.rooms.append(room)
	game.floor_rooms.append(Vector2(start_x, start_y))
	game.floor_rooms_size.append(Vector2(size_x, size_y))
	
	game.ceiling.append(Vector3(start_x, start_y, game.room_number))
	
	# set the tiles of the map for this room. start with the top/botton horizontal walls. looping through the width of the room.  
	for x in range(start_x, start_x + size_x):
		# start making top walls, left to right.
		set_tile(x, start_y, Enum.Tile.Wall)
		
		# followed by ending at start y minus the height of the room minus 1.
		# see ref 1-3.png
		set_tile(x, start_y + size_y - 1, Enum.Tile.Wall)
		
	
	# ignore the sides of the room. _frame is used to place the puzzle sprites on the map in the correct block color.
	var _frame:int = - 1
	
	# do the same for height of the room but skip the top/bottom horizontal tiles for each side because they were done when the width of the room was set.
	# folder ref/1-4.png
	for y in range(start_y + 1, start_y + size_y - 1):
		# left side wall. starting from one tile from top of room to one tile at buttom of room.
		set_tile(start_x, y, Enum.Tile.Wall)
		
		# right wall. top right to buttom left.
		set_tile(start_x + size_x - 1, y, Enum.Tile.Wall)
				
		# add another loop for to do the width of the floor. This will do every floor tile in the room since the loop above is used for the height of this floor.
		# see folder ref/1-5.png
		for x in range(start_x + 1, start_x + size_x - 1):
			_frame += 1
			
			if Settings._game.room_ceiling == false:
				set_tile(x, y, Variables._floor_rooms_tile_value)
			else:
				if game.room_number != 1 && game.visibility_map_saved.get_cell(x, y) != -1:
					game.ceiling.append(Vector3(x, y, game.room_number))
					set_tile(x, y, Enum.Tile.Ceiling)
				else:
					set_tile(x, y, Variables._floor_rooms_tile_value)	
	
			
			# room 0 (puzzle)
			# place the puzzle sprites on the map at room 0.
			if game.room_number == 0 && bool(Builder_playing._event_puzzles.data.event_enabled[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.data.event_number]) == true:
				# continue if color of the puzzle block is not 0.
				if Builder_playing._event_puzzles.data.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.data.event_number][_frame] != 0:
					var _puzzle_blocks = reference.Puzzle.new(self, x, y, Builder_playing._event_puzzles.data.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.data.event_number][_frame], _frame)
					
					game.puzzle_blocks.append(_puzzle_blocks)
					
					# place the puzzle in this 2 dimentional var, so that it is easier to process later when player moves puzzle blocks at reference.gd.
					Variables._puzzle_room_block_values[x - start_x - 1][y - start_y - 1] = Builder_playing._event_puzzles.data.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.data.event_number][_frame]
	
	
	cut_regions(free_regions, room)

# add or remove regions from the free regions list. cannot change an array while iterating thought it so I will simply add and remove it and process it later.
func cut_regions(free_regions, region_to_remove):
	# for each region, if it intersects with the room that was just created, remove that region.
	var removal_queue = []
	var addition_queue = []
	
	# calculate that leftover space at each side of the room - 1 margin.
	for region in free_regions:
		if region.intersects(region_to_remove):
			removal_queue.append(region)
			
			# the margin makes it easier because i do not need to calculate two adjacent rooms.
			# see folder ref/1-7.png
			var leftover_left = region_to_remove.position.x - region.position.x - 1
			var leftover_right = region.end.x - region_to_remove.end.x - 1
			var leftover_above = region_to_remove.position.y - region.position.y - 1
			var leftover_below = region.end.y - region_to_remove.end.y - 1
			
			var _min_room_dimensions 
			if game._puzzle_room_dimension > 0 && game.room_number == 1:
				_min_room_dimensions = game._puzzle_room_dimension
			else:
				_min_room_dimensions = game._min_room_dimension
			
			# now if at each side there is enough space for a room, I will be adding a new region. Note the regions being added can overlap, or else I could be missing out on places I could place a room because it would be across the border of two different regions and because these regions can overlap, I will be checking everything in the free list and not just the one I choose to put the room in.
			# see folder ref/1-8.png
			if leftover_left >= _min_room_dimensions:
				addition_queue.append(Rect2(region.position, Vector2(leftover_left, region.size.y)))
			if leftover_right >= _min_room_dimensions:
				addition_queue.append(Rect2(Vector2(region_to_remove.end.x + 1, region.position.y), Vector2(leftover_right, region.size.y)))
			if leftover_above >= _min_room_dimensions:
				addition_queue.append(Rect2(region.position, Vector2(region.size.x, leftover_above)))
			if leftover_below >= _min_room_dimensions:
				addition_queue.append(Rect2(Vector2(region.position.x, region_to_remove.end.y + 1), Vector2(region.size.x, leftover_below)))
		
	# now that i am finished iterating through the free regions list, i can now modify it.
	for region in removal_queue:
		free_regions.erase(region)
		
	# this function should be used in a test for, because it is easy to mix the x and y values and be off by 1 tile.
	for region in addition_queue:
		free_regions.append(region)

func set_tile(x, y, type):
	# TODO if the game crashes here then the size of the map is too small. increase it at builder puzzle and at builder levels.
	# set the array of arrays for map and tile_map.
	game.map[x][y] = type
	game.tile_map.set_cellv(Vector2(x, y), type)
	
	if Settings._game.normal_doors_exist == false: 
		if type == Enum.Tile.Door:
			clear_path(Vector2(x, y))
