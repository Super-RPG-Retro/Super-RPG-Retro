"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


# an array of arrays to hold each tile.
var map := []

# an array to hold the rooms.
# rooms[1] is the starting room where the player is at. puzzle room is rooms[0]. a puzzle room is always 15 x 15 tiles wide. puzzle room is first to be drawn because it is the biggest room. to avoid running out of free regions, it is better to draw bigger rooms first. it is easy to find space for smaller rooms.
# rooms[0].position.x is the top left corner of the room, where the wall is at and in tiles, rooms[0].position.y is the rooms y coordinates in units. rooms[0].size.x and rooms[0].size.y is the amount of tiles including the walls. 
var rooms := []
var room_number := -1
var floor_rooms := []
var floor_rooms_size := []
var doors := []
var ceiling := []

var mobs := []
var items := []
var icons := []
var potion_types  
var puzzle_blocks := []

# if false then no puzzle block can be moved because player has moved the allowed amount of puzzle blocks. every time the player places a block on the map, the move total increases until player cannot move anymore pieces.
var _can_player_move_puzzle_block = true

# if true then player will not be able to leave room.
var _player_holding_puzzle_block:bool = false

# Node refs -----------------------------
@onready var _timer_move_speed_player = $TimerMoveSpeedPlayer
@onready var tile_map = $TileMap
@onready var overlay_map = $OverlayMap
@onready var visibility_map = $VisibilityMap

# visibility_map takes this data when player returns to a level. this data is saved to disk just before exiting a level. This is not from saved_data folder on hard drive. saved_data is only used when returning to a game from main menu.
@onready var visibility_map_saved = $VisibilityMap
@onready var player = $Player
@onready var build = $BuildLevel
@onready var reference = $RefCounted
@onready var rune_casting = $RuneCasting

# Game State ----------------------------
var TILE_SIZE = 32

# size of the levels in cells from left to right or up to down.
# the game will sometimes crash if you have a room total less than 5. it could crash if there is not enough region for the rooms. therefore, this var must have a value to hold all the rooms. 
var LEVEL_SIZE = []

# _total_level_room. how many rooms are there at a level.
# _total_level_enemy. how many mobs at a level. mobs will not be placed on a tile if there is already an emeny there. So basically, you can have any number here. However, its a good idea to keep it at or below the min room dimension squared.
# _total_level_item. how many items on the ground at each level. this value can also go beyond the room dimentions.
# MIN/_max_room_dimension. a room size includes the rooms in tiles. so a five tile width room will only have 3 width floor tiles. so remember that these dimension are always 2 less for the floors
var _total_level_room
var _total_level_enemy
var _total_level_item
var _max_room_dimension
var _min_room_dimension
var _puzzle_room_dimension
var _total_enemy_at_level = 0 # value is set later to this var.

# var[a][b][c]. a: dungeon. b: mobs dictionary name. c: level mobs is at.
var _level_enemies_names = []

const LEVEL_ITEM_NAMES = ["Paper", "Potion"]

# these are function names. jump to these functions depending on the item id that player picked up.
const POTION_FUNCTIONS = ["potion_impair_vision", "potion_healing", "potion_poison", "potion_mana"]

var _player_tile
var _mobs_pathfinding

var _new_wall = null
var _new_door = null
var _new_floor = null
var _new_ladder_down = null
var _new_ladder_up = null
var _new_stone = null
var _new_floor_rooms = null
var _new_ceiling = null
var _new_ceiling2 = null

# blocks at puzzle room will reset when this value equals 0.
var _event_puzzle_move_total = -1

func _ready():
	var _temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_saved_game) + "/settings_game.txt")
		
	if _temp != null:
		Settings._game = _temp
		
	randomize()
	
	# if custom game is enabled, set these variables.
	_total_level_enemy = Builder_playing._data.mobs_total[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._data.level_number]
	_total_level_item = Builder_playing._data.item_total[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._data.level_number]
	
	_event_puzzle_move_total = Builder_playing._event_puzzles.move_total[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number] + 1
	
	# always start with the static puzzle layout for the room.
	Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number] = Builder_playing._event_puzzles.coordinates_static_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number]
	
	Variables._block_id = -1
	Variables._block_id_old = -1

	# this is the values of all puzzle blocks in the puzzle room.
	Variables._puzzle_room_block_values = [
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	]
	
	game_seed()
	
	if _total_level_enemy > 0:
		populate_mobs_data()	
	
	if Settings._game.visibility_map == false:
		get_node("VisibilityMap").visible = false
	
	LEVEL_SIZE = ceil(Builder_playing._data.level_size[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Settings._game.level_number] / 2) # /2 because builder uses a value that is both height and width
	
	# do not use + 1 here.
	_total_level_room = Builder_playing._data.room_total[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._data.level_number]
	
	_max_room_dimension = Builder_playing._data.room_size_max[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._data.level_number]
	_min_room_dimension = Builder_playing._data.room_size_min[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._data.level_number]
	_puzzle_room_dimension = Builder_playing._data.event_room_size[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._data.level_number]
	
	# change the tile appearance based on the level your at. maybe some levels have same door or same ladder. sometimes levels may have same floors or walls.
	tiles_change_on_level_load()	
	
	# the true value of the event may be set below if there is an event to be set.
	Builder_playing._event_puzzles.event_number = 802
	
	# 800 events total. 8 dungeons times 99 levels is the total events. 800 value is plenty of events for the game.
	# get the event number for this dungeon number and level number.
	# events could also be triggered when talking to someone or when opening a chest.
	# __i = event_number
	for _i in range (99):
		if Builder_playing._data.dungeon_number == Builder._event_puzzles.data.dungeon_number[Builder._config.game_id][Builder._data.dungeon_number][_i] and Builder_playing._data.level_number == Builder._event_puzzles.data.dungeon_number[Builder._config.game_id][Builder._data.level_number][_i] and bool(Builder_playing._event_puzzles.event_enabled[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][_i]) == true:
			Builder_playing._event_puzzles.event_number = _i
			break
	
	build.build_level()
	
	if Variables._potion_impair_vision_turns > 0:
		get_node("Player/Impairment").visible = true
	
	rune_casting.build_guides()
	
	# this is the image used to select an object with the mouse to get its description.
	get_node("Player/Cursor").position.x -= 128
	get_node("Player/Cursor").position.y -= 128

	modulate = Color(1, 1, 1, 1)


func _process(_delta):
	if Settings._game.clock == true:
		var _color = Clock._raw_value
		
		# _color - 0.09 means that at night it will darker for longer than 0.02 would be.
		modulate = Color(_color - 0.09, _color - 0.09, _color - 0.09, 1)
	
	else:
		modulate = Color(1, 1, 1, 1)


# each time at main menu when a new seed is used, the seed_current var will be set not the same as the seed_previous var so that the dungeon_level_seed var can be reset back to default, so that a new game with seed values can be stored in the dungeon_level_seed var. see Settings._system.dungeon_level_seed for more information
func game_seed():
	if Settings._system.seed_current != Settings._system.seed_previous:
		Settings._system.seed_previous = Settings._system.seed_current
		
		# reset back to default.
		Settings._system.dungeon_level_seed[Settings._game.level_number] = {}
		# set seed for this dungeon level.
		Settings._system.dungeon_level_seed[Settings._game.level_number] = Settings._system.seed_current
		
		seed(Settings._system.seed_current)
		print("1-seed", Settings._system.seed_current)
		
	# if dungeon level seed index is null then use seed value from main menu.
	elif Settings._system.dungeon_level_seed.has(Settings._game.level_number) == true:
		seed(Settings._system.seed_current)
		# if this is true then its either a new game or a new seed is used because the player's path to exit ladder could not be found.
		print("2-seed", Settings._system.seed_current)
			
	# else if path to exit ladder could not be found then these vars will not match.
	elif Settings._system.dungeon_level_seed.has(Settings._game.level_number) == true and Settings._system.seed_current != Settings._system.dungeon_level_seed[Settings._game.level_number]:
		seed(Settings._system.dungeon_level_seed[Settings._game.level_number])
		print("3-seed", Settings._system.dungeon_level_seed[Settings._game.level_number])
	
	else:
		seed(Settings._system.seed_current)
		
		print("4-seed", Settings._system.seed_current)
	

# this func deals with data from the user://data folder. for example, the folder names inside of the data/animals folders is read and stored as Variables._file_names for group anaimals.
func populate_mobs_data():
	if !DirAccess.dir_exists_absolute(Variables._project_path + "/builder/objects/data/" + str(Builder_playing._config.game_id + 1) + "/mobs/" + str(Builder_playing._data.dungeon_number + 1) + "/" + str(Builder_playing._data.level_number + 1) + "/"):
		return
	
	
	_level_enemies_names.clear()
	_total_enemy_at_level = 0
	
	var _name = Json.refresh_dictionaries(Variables._project_path + "/builder/objects/data/" + str(Builder_playing._config.game_id + 1) + "/mobs/" + str(Builder_playing._data.dungeon_number + 1) + "/" + str(Builder_playing._data.level_number + 1) + "/", true)
		
	Variables.enemy_total_in_game = 0
	
	Common.count_mobs_total_in_game()
	
	# create an array what stores each mobs and what level the mobs is at and what dungeon that mobs is at. 
	# var[a][b][c]. a: dungeon. b: mobs dictionary name. c: level mobs is at.
	# create the array indexes for all mobs.
	for x in range(8):
		_level_enemies_names.append([])
		
		# when adding more mobs, make such that this var in big enought to hold them all.
		for y in range(Variables.enemy_total_in_game):
			_level_enemies_names[x].append([])
			
			# 100 is the max level of 0 to 99 plus 1 extra needed to end loop.
			for _z in range(100):
				_level_enemies_names[x][y].append([])
	
	var _c = -1
	for _e in _name:
		_c += 1
		_level_enemies_names[Builder_playing._data.dungeon_number][_c][Settings._game.level_number] = _e

	# count how many mobs are at current level. for each level _total_enemy_at_level is used in a random command to display mobs. for example, if two mobs was found at level 3, then this var will have a value of 2 and randi command is used to pick an mobs in a _total_level_enemy loop  
	for _i in range(Variables.enemy_total_in_game):
		if _level_enemies_names[Builder_playing._data.dungeon_number][_i][Settings._game.level_number].is_empty() == false:
			_total_enemy_at_level += 1


# change the tile appearance based on the level your at. maybe some levels have same door or same ladder. sometimes levels may have same floors or walls.
# TODO this should be at builder.
func tiles_change_on_level_load():
	_new_wall = load("res://bundles/assets/images/foundation/wall" + str(Settings._game.level_number + 1 ) + ".png")
	tile_map.tile_set.get_source(0).texture =  _new_wall

	_new_door = load("res://bundles/assets/images/foundation/door" + str(Settings._game.level_number + 1 ) + ".png")
	tile_map.tile_set.get_source(1).texture = _new_door

	_new_floor = load("res://bundles/assets/images/foundation/floor" + str(Settings._game.level_number + 1 ) + ".png")
	tile_map.tile_set.get_source(2).texture = _new_floor

	_new_ladder_down = load("res://bundles/assets/images/foundation/ladder_down" + str(Settings._game.level_number + 1 ) + ".png")
	tile_map.tile_set.get_source(3).texture = _new_ladder_down

	_new_ladder_up = load("res://bundles/assets/images/foundation/ladder_up" + str(Settings._game.level_number + 1 ) + ".png")
	tile_map.tile_set.get_source(4).texture = _new_ladder_up

	_new_stone = load("res://bundles/assets/images/foundation/stone" + str(( Settings._game.level_number + 1 )) + ".png")
	tile_map.tile_set.get_source(5).texture =_new_stone
		
	_new_floor_rooms = load("res://bundles/assets/images/foundation/floor_rooms" + str(Settings._game.level_number + 1 ) + ".png")
	tile_map.tile_set.get_source(6).texture = _new_floor_rooms

	_new_ceiling = load("res://bundles/assets/images/foundation/ceiling.png")
	tile_map.tile_set.get_source(7).texture = _new_ceiling
		
	_new_ceiling2 = load("res://bundles/assets/images/foundation/ceiling.png")
	overlay_map.tile_set.get_source(0).texture = _new_ceiling2
			

func try_move(dx, dy):
	# go to try_move.hd. currently not linked to any node.
	get_tree().call_group("move", "try_move", dx, dy)		

func pickup_items():
	# every item that needs to be picked up will be added to this list.
	var remove_queue = []
	
	for item in items:
		if item.tile == _player_tile:
			# do any event after an item is picked up.
			if item._item_id == 0:
				PC._hp += 2
				Hud._loaded.Score += 1
				player.get_node("Damage").damage_player(0)
				
			else:
				# we can use "call" to call array that have strings in them, which are intended to be funcs. In this example, the frame is the id of the item which extends reference, the _sprite_scene is the instance of that reference. so if typing the potion_types[1] then that would output the second array, but if you would rather go to that func, which is a string in that array then you would use call. see POTION_TYPES and POTION_FUNCTIONS
				call(potion_types[item._sprite_scene.frame])
			# call the remove function to free the item.
			item.remove()
			
			# add item to the queue list.
			remove_queue.append(item)
			
	# then remove that queue list. null the item.
	for item in remove_queue:
		items.erase(item)

# code for these func are at try_move()
func potion_impair_vision():
	Variables._potion_impair_vision_turns += 10
	Variables._potion_impair_vision_turns = clamp(Variables._potion_impair_vision_turns, 1, 999)
	$Player/Impairment.visible = true 
	get_tree().call_group("potion_panel", "set_label", 1, Variables._potion_impair_vision_turns)


func potion_healing():
	Variables._potion_healing_turns += 10
	Variables._potion_healing_turns = clamp(Variables._potion_healing_turns, 1, 999)
	get_tree().call_group("potion_panel", "set_label", 2, Variables._potion_healing_turns)


func potion_poison():
	Variables._potion_poison_turns += 10
	Variables._potion_poison_turns = clamp(Variables._potion_poison_turns, 1, 999)
	get_tree().call_group("potion_panel", "set_label", 3, Variables._potion_poison_turns)

func potion_mana():
	Variables._potion_mana_turns += 10
	Variables._potion_mana_turns = clamp(Variables._potion_mana_turns, 1, 999)
	get_tree().call_group("potion_panel", "set_label", 4, Variables._potion_mana_turns)

	
# this func will not work outside of this game script.
func update_visuals():
	# set the player's position. tile_size is 32 pixels.
	player.position = _player_tile * TILE_SIZE
	await get_tree().create_timer(0.000001).timeout
	
	# ray-casting will be used to determine what the player can see.
	# for starters, get pixel coordinates for the center of the player's tile.
	var player_center = tile_to_pixel_center(_player_tile.x, _player_tile.y)
	
	# space state is like n interface to the physics Variables. It is used to do the ray-casting. now i am going go through ever tile in the level 
	var space_state = get_world_2d().direct_space_state
	
	for x in range(_player_tile.x - 10, _player_tile.x + 10):
		for y in range(_player_tile.y - 10, _player_tile.y + 10):
			# the ray-cast will be done if there is a zero, a visibility tile. However there is a complication here. If we go from center to center, some tiles will be cut off even though you should be able to see the side of it. So an offset will be used to the closet corner.
			# see folder ref/5-1.png
			# a value of zero means player cannot see tile. tile is all black.
			if visibility_map.get_cell_source_id(0, Vector2i(x, y)) == 0:
				var x_dir = 1 if x < _player_tile.x else -1
				var y_dir = 1 if y < _player_tile.y else -1
				# once the direction is found, tile will be multiplied by half its size to get the offset.
				var test_point = tile_to_pixel_center(x, y) + Vector2(x_dir, y_dir) * TILE_SIZE / 2
				
				# now i can do the ray-cast starting from intersect ray. Going from the center to the point that was just calculated.
				var occlusion = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(player_center, test_point))
				
				# if no occlusion then we can see the tile. However, here is one complication. For tiles that block vision, we always get hit when casting a ray at it, but that does not mean we should not see it, just means we should not see past it. so we need to check the distance between the point of the hit to the point that we were just testing. A value of 1 give a 1 margin error to the tile.
				if !occlusion or (occlusion.position - test_point).length() < 1:
					# a value of -1 clears the tile.
					visibility_map.set_cell(0, Vector2i(x, y), -1)
					
	for mob in mobs:
		mob._sprite_scene.position = mob.tile * TILE_SIZE
		if !mob._sprite_scene.visible:
			var mob_center = tile_to_pixel_center(mob.tile.x, mob.tile.y)
			var occlusion = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(player_center, mob_center))
			
			if !occlusion and mob.dead == false:
				mob._sprite_scene.visible = true
				
				
	for item in items:
		item._sprite_scene.position = item.tile * TILE_SIZE
		if !item._sprite_scene.visible:
			var item_center = tile_to_pixel_center(item.tile.x, item.tile.y)
			# if the mobs is not already visible, we will cast a ray and if nothing blocks it then we will make it visible.
			var occlusion = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(player_center, item_center))
			if !occlusion:
				item._sprite_scene.visible = true

# find pixel coordinates for the center of the player's tile.
func tile_to_pixel_center(x, y):
	return Vector2((x + 0.5) * TILE_SIZE, (y + 0.5) * TILE_SIZE)


func _on_timer_delay_move_timeout():
	Variables._compass_update = true


func _on_timer_move_speed_player_timeout():
	_timer_move_speed_player.stop()
