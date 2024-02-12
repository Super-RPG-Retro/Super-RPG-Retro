"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# game -> reference file.
extends Node2D


const TILE_SIZE = 32

class Item extends RefCounted:
	var _type := ""
	var _name := ""
	
	# the item description, such as what kind of potion is on the floor.
	var _description := ""
	
	# sprite scene that this Item uses.
	var _sprite_scene
	
	# tile.x and tile.y refers to a tile number from the top-left (0,0 coordinate) position. if x has a value of 1, then tile.x is one tile to the right.
	var tile
	
	# _item_id  0: paper, 1:potion, ect. see Items.gd.
	var _item_id := -1
	
	
	func _init(game, x, y, item_id, name):
		self._item_id = item_id
				
		# tile in x and y coordinate.
		tile = Vector2(x, y)
		
		if _item_id == 0:
			_sprite_scene = Preload.PaperScene.instantiate()
		else:
			_sprite_scene = Preload.PotionScene.instantiate()
		
		# after adding an item from the Item dictionary, remember to go to mouse_command scene and add the code there.
		_name = name
				
		if Settings._game.show_item_when_door_closed == true:
			_sprite_scene.visible = true
		
		# random drop item.
		_sprite_scene.frame = randi() % _sprite_scene.hframes
		
		if _item_id == 0:
			_description = Inventory._paper["Description"]
		
		if _item_id == 1:
			# the items dropped from the mobs.
			if _name == "Potion":
				_name = Inventory.drop_items()	
			
			# this block is used when placing objects on the map at build time. a name has all ready been selected at build time.
			if _name != "Potion":
				# set the image of the item.
				_sprite_scene.frame = Inventory._potion[_name.to_lower().replace(" ", "_")]["ID"]
				
				_description = Inventory._potion[_name.to_lower().replace(" ", "_")]["Description"]
		
		# sprite position on viewport.
		_sprite_scene.position = tile * TILE_SIZE
		
		# if there is more than 1 item on the tile, offset each item randomly so that more than one item can be seen on that tile.
		_sprite_scene.offset = Vector2(randi() % 12 - 6, randi() % 12 - 6) 
		
		game.add_child(_sprite_scene)
	
	# see mobs remove function.
	func remove():
		_sprite_scene.queue_free()
	
	
# define a class to hold the mobs information.
class Mobs extends RefCounted:
	var _move_tile := Vector2(0, 0)
	
	# mob goodbye/hit timer.
	var timer := Timer.new()
	
	# this var is used at tiles.gd to display tile information. this var is either "item", "mobs" or "player". 
	var _type := ""
	
	# how does this object move. follows player, moves in opposite direction of player...
	var _movement_type := Enum.Movement_type.Target_player
	
	# this holds the last direction the mob moved in. 0:left, 1:up, 2:right, 3:down.
	var _movement_direction := 0
	
	# this will hold a reference to the mobs scene.
	var _sprite_scene
	
	# this will be assigned the "position / TILE_SIZE" of the mobs, used to get tile coordinates of the mobs.
	var tile := Vector2(0, 0)
	
	# how much gold the mobs has.
	var _gold := 0
	
	var _str := 0
	var _def := 0
	var _con := 0
	var _dex := 0
	var _int := 0
	var _cha := 0
	var _wis := 0
	var _wil := 0
	var _per := 0
	var _luc := 0
	var _des := ""
	
	# starting hit points. Variable hp will be given to this var.
	var _hp_max := 0
	
	# current hp. mobs dies once this value reaches 0. this hp max is the hp_max var.
	var _hp			:= 0
	var _mp_max		:= 0
	var _mp			:= 0
	var	_xp_given	:= 0

	# is mobs died. this can trigger a respawn.
	@export var dead := false
	
	# name of the mobs.
	var _name := ""
	
	# respawn mobs when value is 0 when dead is true.
	var respawn_position := Vector2(0, 0)
	
	# mobs are set invisible when mobs are too far from their starting position.
	var _dead_at_tile_distance_from_start := 0
	
	# this is the current game turns after mobs had died.
	var _respawn_after_these_turns_current := 0
	
	# amount of game turns needed before an mobs respawn. when _respawn_after_these_turns_current reaches this value, the mobs will respawn.
	var _respawn_after_these_turns_max := 0
	
	# these values are hardcoded. no been to be concerned with them. they are used for the haste spells, to slow the movement of the mobs.
	var _move_speed					:= 0
	var _move_speed_reset_min 		:= 3
	var _move_speed_min				:= 0
	var _move_speed_max				:= 0

	# godot calls this before scene is ready. This func is called when you create a new instance.
	# game				is the reference to the game node.
	# mobs_level		0:first mobs in the index array.
	# x-y				mobs coordinates.
	func _init(game, mobs_level, x, y, _level_enemies_names, _total_enemy_at_level):
		# the tile value. 0,0 starts at top-left of viewport.
		tile = Vector2(x, y)
			
		# this holds the funcs and vars of the mobs instance.
		_sprite_scene = Preload.MobsScene.instantiate()
		
		if Settings._game.show_mobs_when_door_closed == true:
			_sprite_scene.visible = true
		
		# pick a random mobs for this level,
		var id = randi() % (_total_enemy_at_level)
		
		_name =		_level_enemies_names[Builder_playing._data.dungeon_number][id][mobs_level]
		
		# return if no mobs at level. this avoids a runtime crash.
		if _name.is_empty() == true:
			return
		
		_gold = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].Drop_gold + Settings._game.difficulty_level)   
		
		_str = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].Strength + Settings._game.difficulty_level) - 1
		
		_def = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].Defense + Settings._game.difficulty_level) - 1
		
		_con = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].Constitution + Settings._game.difficulty_level) - 1
		
		_dex = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].Dexterity + Settings._game.difficulty_level) - 1
		
		_int = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].Intelligence + Settings._game.difficulty_level) - 1
		
		_cha = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].Charisma + Settings._game.difficulty_level) - 1
		
		_wis = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].Wisdom + Settings._game.difficulty_level) - 1
		
		_wil = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].Willpower + Settings._game.difficulty_level) - 1
		
		_per = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].Perception + Settings._game.difficulty_level) - 1
		
		_luc = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].Luck + Settings._game.difficulty_level) - 1
		
		_des = Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].Description
		
		# starting hit points. Variable hp will be given to this var.
		_hp_max = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].HP + Settings._game.difficulty_level)
		
		# current hp. mobs dies once this value reaches 0.
		# _hp might not equal hp_max because mobs could spawn with low health.
		_hp = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].HP + Settings._game.difficulty_level)
		
		_mp_max = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].MP_max + Settings._game.difficulty_level)
		
		_mp = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].MP + Settings._game.difficulty_level)
		
		_xp_given = int(Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].XP_given + Settings._game.difficulty_level)
		
		_movement_type = Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name].Movement_type
		
		# set invisible if any mobs are to far from mobs starting position.
		_dead_at_tile_distance_from_start	= Settings._game.mobs_dead_distance
		
		# mobs will respawn after these many game turn elapses.
		_respawn_after_these_turns_max		= Settings._game.respawn_turn_elapses
		
		_move_speed = 3		
		_move_speed_min = 3
		_move_speed_max = 3		
		
		_sprite_scene.texture = Filesystem._load_external_image(Variables._project_path + "/builder/objects/images/dictionaries/" + str(Builder_playing._config.game_id + 1) + "/mobs/" + str(Builder_playing._data.dungeon_number + 1) + "/" + str(Builder_playing._data.level_number + 1) + "/" + Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][_name]["Class"] + "/" + _name.to_lower() + "/1.png")
		
		# starting location of mobs.
		respawn_position = Vector2(x, y)
				
		# the mobs position.
		_sprite_scene.position = tile * TILE_SIZE
		
		# add the instance to the scene.
		game.add_child(_sprite_scene)
		
		# when mobs dies, there will be a short delay where player cannot move that the tile. the reason is timer is set to 0.7s while animation is set for 0.65s. this is to avoid any assertion errors.
		timer.connect("timeout", Callable(self, "_on_goodbye_timer_timeout")) 
		game.add_child(timer)
		
	# we need to remove the instance when needed. you could do a instance notification and have godot clear the instance (see folder ref/6-1.png) but when changing scenes, godot will clear it there and that would give you an error since the instance is already removed. instead we can do the following.
	func remove():
		_sprite_scene.queue_free()
	
	# mobs damage.
	func take_damage(game, dmg):
		# mobs instance.
		if dead:
			return
		
		# reduce the hp but not below the value of 0.
		_hp = max(0, _hp - dmg)
		
		# change the width of the hp bar, depending on the percentage of the hp value.
		if _hp_max > 0:
			_sprite_scene.get_node("EntityChildScene/HP").size.x = TILE_SIZE * _hp / _hp_max
		
		# change the color of the hp bar, based on the hp percent of the hp_max.
		if _hp >= _hp_max * 0.7:
			_sprite_scene.get_node("EntityChildScene/HP").color = Color("00007d")
				
		if _hp < _hp_max * 0.7:
			_sprite_scene.get_node("EntityChildScene/HP").color = Color("7d7d00")
			
		if _hp < _hp_max * 0.35:
			_sprite_scene.get_node("EntityChildScene/HP").color = Color("7d0000")
		
			_sprite_scene.get_node("AnimationPlayer").play("goodbye")
					
			PC._xp += _xp_given			
			_sprite_scene.get_tree().call_group("stats_loaded", "stats_value_all_update", _xp_given)
			
			timer.wait_time = 0.265
			timer.one_shot = true
			timer.start()
						
			if Settings._system.sound == true:
				_sprite_scene.get_tree().call_group("game_audio", "play_goodbye_mob_sound")
			
			# Drop paper
			for _i in range(randi() % 4):
				game.items.append(Item.new(game, tile.x, tile.y, Inventory.selected.Paper, "Paper"))
			
			for _i in range(randi() % 3):
				# select an item to give.
				var _item_name = Inventory.drop_items()
				
				# place the item on map.
				game.items.append(Item.new(game, tile.x, tile.y, Inventory.selected.Potion, _item_name))
		
				
		elif dmg > 0 and timer.time_left == 0:
			_sprite_scene.get_node("AnimationPlayer").play("hit")
	
	func _on_goodbye_timer_timeout():
			_hp = 0
			dead = true
			_respawn_after_these_turns_current = _respawn_after_these_turns_max
			_sprite_scene.visible = false
			
			# place the mobs off map.
			tile.x = -1
			tile.y = -1
			
	
	# mobs movement.			
	# _dx and _dy is player's movement. 0: no movement. -1 left or up. 1: right or down
	func act(game, mobs, _dx:int, _dy:int):
		# don't do anything with this mobs if mobs is not visible.
		if !_sprite_scene.visible:
			return
			
		# get the points the player and mobs are at. this is the mobs location.
		var my_point = game._mobs_pathfinding.get_closest_point(Vector3(tile.x, tile.y, 0))
		
		var player_point = game._mobs_pathfinding.get_closest_point(Vector3(game._player_tile.x, game._player_tile.y, 0))
	
		# then we try to find a path between them.
		var path = game._mobs_pathfinding.get_point_path(my_point, player_point)
		
		#if path:			
		# exit this func and try next move if player is standing on a mob. if this is true then mob respawned at player's position. mob will be seen standing with player but no errors will be giving because of this return.
		# cannot stand on mob at corridor. enter this function regardless of path size because mob might be running from player.
		if path.size() <= 1 and game.tile_map.get_cell_source_id(0, Vector2i(tile.x, tile.y)) != Enum.Tile.Floor:
			return
		
		# if mob stands still, return if player is not next to mob. else mob will attack.
		if path.size() > 2 and _movement_type == Enum.Movement_type.Stationary:
			return
		
		
		# path between them should be 2 tiles long. This assures that mobs will not be in the same tile as player.
		#assert(path.size() > 1)
		
		# mobs only moves 1 tile at a time.
		_move_tile = Vector2(tile.x, tile.y)
		
		# types of movement that a mob can do.
		_mob_movement_type(game, path, _dx, _dy)
		
		# if a haste rune is in effect, set the min speed that mobs can move. the lower the value, the slower the move to next tile will be because mobs is set to only move when normal _move_speed equals _move_speed_max.
		if Variables._is_haste_enabled == true:
			if PC._move_speed == 2:
				_move_speed_min = 2
			if PC._move_speed == 3:
				_move_speed_min = 1
		
		# if haste rune is not enabled then set back the min move speed.
		else:
			_move_speed_min = 3
		
		# increment the move speed. if move speed equals move speed max, as set below this code block, the mobs will then move. clamp statement assures that the normal move speed (_move_speed) does not have a greater value than _move_speed_max.	
		if _move_speed != null:
			_move_speed += 1
			_move_speed = clamp(_move_speed, _move_speed_min, _move_speed_max)
		
		if game.player.frame == 1: # player is invisible...
			_move_tile = Vector2(path[0].x, path[0].y)
			
			# ...but touches mob. set player back to normal so that player can receive damage from mob.
			if path.size() == 2:
				game.player.frame = 0
		
		# minus one because the value will be set to PC._move_speed_min at next loop.
		if _move_speed == _move_speed_max:
			_move_speed = _move_speed_min - 1
		else:
			_move_tile = Vector2(path[0].x, path[0].y)
			
		# if mobs wants to move to the player then give player damage.
		if _move_tile == game._player_tile and timer.time_left == 0:
			game.player.get_node("Damage").damage_player(1)
		
		else:
			# else, move the mobs to the player if at not blocked position.
			var blocked = false
			for other_mobs in game.mobs:
				if other_mobs.tile == _move_tile:
					blocked = true
			
			if mobs.tile == _move_tile:
				blocked = true
						
			if !blocked and timer.time_left == 0 and !_sprite_scene.get_node("AnimationPlayer").is_playing():
				if _dx == 0 and _dy == 0 and _movement_type == Enum.Movement_type.Avoid_player:
					pass
				
				if _dx == 0 and _dy == 0 and _movement_type == Enum.Movement_type.Run_away_from_player:
					pass
					
				else:
					tile = _move_tile
	
	# type of movement that a mob can do.
	func _mob_movement_type(game, path:PackedVector3Array, _dx:int, _dy:int):
		if _movement_type == Enum.Movement_type.Run_away_from_player:
			if game._player_tile.x < tile.x and tile.x - game._player_tile.x == 1 and game._player_tile.y < tile.y and tile.y - game._player_tile.y == 1 or game._player_tile.x > tile.x and game._player_tile.x - tile.x == 1 and game._player_tile.y < tile.y and tile.y - game._player_tile.y == 1:
				_dx = 0
				_dy = 0
								
			elif game._player_tile.x < tile.x and tile.x - game._player_tile.x == 1 and tile.y < game._player_tile.y and game._player_tile.y - tile.y == 1 or game._player_tile.x > tile.x and game._player_tile.x - tile.x == 1 and tile.y < game._player_tile.y and game._player_tile.y - tile.y == 1:
				_dx = 0
				_dy = 0
								
			
		if _movement_type == Enum.Movement_type.Avoid_player:
			var _xl = 1000
			if game._player_tile.x <= tile.x:
				_xl = game._player_tile.x - tile.x
			
			var _xr = 1000
			if game._player_tile.x >= tile.x:
				_xr = tile.x - game._player_tile.x
			
			var _yl = 1000
			if game._player_tile.y <= tile.y:
				_yl = game._player_tile.y - tile.y
			
			var _yr = 1000
			if game._player_tile.y >= tile.y:
				_yr = tile.y - game._player_tile.y
				
				
			if _xl > _xr and _xl > _yl and _xl > _yr:
				_dx = 1
				_dy = 0
			elif _xr > _xl and _xr > _yl and _xr > _yr:
				_dx = -1
				_dy = 0
				
			elif _yl > _yr and _yl > _xl and _yl > _xr:
				_dx = 0
				_dy = 1
			elif _yr > _yl and _yr > _xl and _yr > _xr:
				_dx = 0
				_dy = -1
		
		if _movement_type == Enum.Movement_type.Stationary or _movement_type == Enum.Movement_type.Target_player:
			_move_tile = Vector2(path[1].x, path[1].y)
		
		if _movement_type == Enum.Movement_type.Random_movement:
			randomize()
			var _ra = int(randf_range(0, 4)) 
			
			if _ra == 0:
				_dx = -1
				_dy = 0
			
			if _ra == 1:
				_dx = 1
				_dy = 0
				
			if _ra == 2:
				_dx = 0
				_dy = -1
				
			if _ra == 3:
				_dx = 0
				_dy = 1
				
		
		if _movement_type == Enum.Movement_type.Trace_walls:
			# if game is not using Floor_rooms, change this mob movement type to random. this code is needed because mobs would run outside of room, braking the trace wall movement.
			if game.tile_map.get_cell_source_id(0, Vector2i(tile.x, tile.y)) != Enum.Tile.Floor_rooms:
				_movement_type = Enum.Movement_type.Random_movement
			
			if _movement_direction == 0:
				var blocked = false
				for other_mobs in game.mobs:
					if other_mobs.tile.x == tile.x - 1 and other_mobs.tile.y == tile.y:
						blocked = true
				
				if blocked == true:
					_movement_direction = 1
				
				elif game.tile_map.get_cell_source_id(0, Vector2i(tile.x - 1, tile.y)) == Enum.Tile.Floor_rooms:
					_dx = 1 # this value will be reversed before mob is moved.
					_dy = 0
				
				else:
					_movement_direction = 1
					
			if _movement_direction == 1:
				var blocked = false
				for other_mobs in game.mobs:
					if other_mobs.tile.x == tile.x and other_mobs.tile.y == tile.y - 1:
						blocked = true
				
				if blocked == true:
					_movement_direction = 2
				
				elif game.tile_map.get_cell_source_id(0, Vector2i(tile.x, tile.y - 1)) == Enum.Tile.Floor_rooms:
					_dx = 0
					_dy = 1
				
				else:
					_movement_direction = 2
			
			if _movement_direction == 2:
				var blocked = false
				for other_mobs in game.mobs:
					if other_mobs.tile.x == tile.x + 1 and other_mobs.tile.y == tile.y:
						blocked = true
				
				if blocked == true:
					_movement_direction = 3
				
				elif game.tile_map.get_cell_source_id(0, Vector2i(tile.x + 1, tile.y)) == Enum.Tile.Floor_rooms:
					_dx = -1
					_dy = 0
				
				else:
					_movement_direction = 3
					
			if _movement_direction == 3:
				var blocked = false
				for other_mobs in game.mobs:
					if other_mobs.tile.x == tile.x and other_mobs.tile.y == tile.y + 1:
						blocked = true
				
				if blocked == true:
					_movement_direction = 0
				
				elif game.tile_map.get_cell_source_id(0, Vector2i(tile.x, tile.y + 1)) == Enum.Tile.Floor_rooms:
					_dx = 0
					_dy = -1
				
				else:
					_movement_direction = 0
			
			# this dupicate is needed here so that the mob does not pause movement. without this code, when mob moving in down direction fails the mob does not move to this left.
			if _movement_direction == 0:
				var blocked = false
				for other_mobs in game.mobs:
					if other_mobs.tile.x == tile.x - 1 and other_mobs.tile.y == tile.y:
						blocked = true
				
				if blocked == true:
					_movement_direction = 1
				
				elif game.tile_map.get_cell_source_id(0, Vector2i(tile.x - 1, tile.y)) == Enum.Tile.Floor_rooms:
					_dx = 1 # this value will be reversed before mob is moved.
					_dy = 0
				
				else:
					_movement_direction = 1
			
		
		if _movement_type == Enum.Movement_type.Avoid_player or _movement_type == Enum.Movement_type.Run_away_from_player or _movement_type == Enum.Movement_type.Random_movement or _movement_type == Enum.Movement_type.Trace_walls:
			# player did not move.
			if _dx == 0 and _dy == 0:
				# no mob movement.
				_move_tile = Vector2(tile.x, tile.y)
				
			# left.
			if _dx == -1 and game.tile_map.get_cell_source_id(0, Vector2i(tile.x + 1, tile.y)) == Enum.Tile.Floor or _dx == -1 and game.tile_map.get_cell_source_id(0, Vector2i(tile.x + 1, tile.y)) == Enum.Tile.Floor_rooms:
				_move_tile = Vector2(tile.x + 1, tile.y)
			
			# right.
			if _dx == 1 and game.tile_map.get_cell_source_id(0, Vector2i(tile.x - 1, tile.y)) == Enum.Tile.Floor or _dx == 1 and game.tile_map.get_cell_source_id(0, Vector2i(tile.x - 1, tile.y)) == Enum.Tile.Floor_rooms:
				_move_tile = Vector2(tile.x - 1, tile.y)
			
			# up.
			if _dy == -1 and game.tile_map.get_cell_source_id(0, Vector2i(tile.x, tile.y + 1)) == Enum.Tile.Floor or _dy == -1 and game.tile_map.get_cell_source_id(0, Vector2i(tile.x, tile.y + 1)) == Enum.Tile.Floor_rooms:
				_move_tile = Vector2(tile.x, tile.y + 1)
			
			# down.
			if _dy == 1 and game.tile_map.get_cell_source_id(0, Vector2i(tile.x, tile.y - 1)) == Enum.Tile.Floor or _dy == 1 and game.tile_map.get_cell_source_id(0, Vector2i(tile.x, tile.y - 1)) == Enum.Tile.Floor_rooms:
				_move_tile = Vector2(tile.x, tile.y - 1)
					

# puzzle is blocks in only one room when enabled. blocks are displayed on the floor. each block is red on one side and yellow on the other, the object is to move the blocks around, making them appear to be all one color, but in so many turns. puzzle uses room 1. that room is 15 x 15 tiles wide,
class Puzzle extends RefCounted:
	# block red:0, yellow:1.
	# this is the piece value of the currently selected piece the player just placed back to the ground.
	var _block_placed_on_ground := 1
	var _block_to_be_flipped := 2
	
	var _block_grabbed_at := Vector2(0,0)
	
	var tile := Vector2(0, 0)
		
	var _sprite_scene
	
	var _frame := 0
	var _id := 0
	#var _default_id
	
	# game				is the reference to the game node.
	# x and y			main map coordinates in unit.
	func _init(game, x, y, frame:int = 1, id:int = 0):
		_frame = frame
		_id = id
				
		# this holds the funcs and vars of the puzzle sprite node.
		_sprite_scene = Preload.PuzzleScene.instantiate()
		
		tile = Vector2(x, y)
			
		# the puzzle position.
		_sprite_scene.get_node("Sprite2D").set_frame(_frame)
		_sprite_scene.position = tile * TILE_SIZE
		
		game.add_child(_sprite_scene)
				
		"""var _i:int = -1
		for yy in range (13):
			for xx in range (13):
				_i += 1
				# place the puzzle in this 2 dimentional var, so that it is easier to process later when player moves puzzle blocks at reference.gd.
				if Variables._block_id == _default_id:
					Variables._puzzle_room_block_values[xx][yy] = Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number][_i]
		"""
						
	# this func is used to move the block in the direction the player is moving, so the block stays overtop of the player's head.			
	func move_puzzle_block(game, dx, dy, x, y):
		for blocks in game.puzzle_blocks:
			if blocks.tile.x == x - dx and blocks.tile.y == y - dy and blocks._sprite_scene.get_node("Sprite2D").z_index == 100:
				
				# game.rooms[0].position.x is top-left corner of puzzle room, minus that value because this var starts at 0.
				_block_grabbed_at.x = game._player_tile.x - game.rooms[0].position.x - 1
				_block_grabbed_at.y = game._player_tile.y - game.rooms[0].position.y - 1
								
				var _i = -1
				for yy in range (13):
					for xx in range (13):
						_i += 1
						
						if xx == _block_grabbed_at.x and yy == _block_grabbed_at.y and game._player_tile.x == x and game._player_tile.y == y:
							
							Variables._puzzle_room_block_values[_block_grabbed_at.x][_block_grabbed_at.y] = 0
						
							Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number][_i] = Variables._puzzle_room_block_values[xx][yy]
				
				if dx == 1:
					blocks._sprite_scene.get_node("Sprite2D").position.x += 32
					blocks.tile.x += 1
					
					# the position of the block might have changed, so update the id which refers to the location of that block on the main map.					
					Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number][blocks._id] = 0
					
					Variables._block_id += 1
										
				if dx == -1:
					blocks._sprite_scene.get_node("Sprite2D").position.x -= 32
					blocks.tile.x -= 1
					
					Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number][blocks._id] = 0
					
					Variables._block_id -= 1
					
				if dy == 1:
					blocks._sprite_scene.get_node("Sprite2D").position.y += 32
					blocks.tile.y += 1
					
					Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number][blocks._id] = 0
					
					Variables._block_id += 13
					
				if dy == -1:
					blocks._sprite_scene.get_node("Sprite2D").position.y -= 32
					blocks.tile.y -= 1
					
					Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number][blocks._id] = 0
					
					Variables._block_id -= 13
					
					
	func act(game, x, y, blocks):
		if game._can_player_move_puzzle_block == false:
			return
			
		# if the player is standing at the location of a block, put the block overtop at the player's head.
		# this value is 100 when the mouse is clicked.
		if blocks.tile.x == x and blocks.tile.y == y and blocks._sprite_scene.get_node("Sprite2D").z_index == 0:
			blocks._sprite_scene.get_node("Sprite2D").set_offset(Vector2(16, 11))
			blocks._sprite_scene.get_node("Sprite2D").set_z_index(100)
			blocks._sprite_scene.get_node("Sprite2D").set_modulate(Color(0.7, 0.7, 0.7, 0.7))
			
			game._player_holding_puzzle_block = true
			
			_block_placed_on_ground = blocks._sprite_scene.get_node("Sprite2D").frame 
			
			# this var will now always be the opposite value of _block_to_be_flipped.
			if _block_placed_on_ground == 1:
				_block_to_be_flipped = 2
			else:
				_block_to_be_flipped = 1
				
			Variables._block_id = blocks._id
			Variables._block_id_old = blocks._id
			
			var _i:int = -1
			for yy in range (13):
				for xx in range (13):
					_i += 1
				
					# this is the location of the block that was first picked up. this location does not change until block is put back onto the map.
					if Variables._block_id_old == _i:
						Variables._puzzle_room_block_values[xx][yy] = 0		
						
						Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number][_i] = 0	
			
					
			_sprite_scene.get_tree().call_group("game_audio", "play_puzzle_sound", 
			Enum.Puzzle_sounds.Puzzle_block_move)
			
		# if the player is standing at the location of a block, put the block back on the tile
		elif blocks.tile.x == x and blocks.tile.y == y and blocks._sprite_scene.get_node("Sprite2D").z_index == 100 and Variables._block_id != -1:
			blocks._sprite_scene.get_node("Sprite2D").set_offset(Vector2(16, 16))
			blocks._sprite_scene.get_node("Sprite2D").set_z_index(0)
			blocks._sprite_scene.get_node("Sprite2D").set_modulate(Color(1, 1, 1, 1))
			
			game._player_holding_puzzle_block = false
			
			Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number][Variables._block_id] = _block_placed_on_ground
			
			blocks._id = Variables._block_id
			_redraw_blocks(game)
			
			game._event_puzzle_move_total -= 1
				
			# if current puzzle matches the layout of what the end layout looks like then play a success sound.
			if Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number] == Builder_playing._event_puzzles.coordinates_e_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number]:
				_sprite_scene.get_tree().call_group("game_audio", "play_puzzle_sound", 
			Enum.Puzzle_sounds.Puzzle_success)
				
				game._can_player_move_puzzle_block = false
				
			# play a failed sound if current puzzle layout does not match puzzle's end layout.
			elif game._event_puzzle_move_total == 0:
				game._event_puzzle_move_total = -1
				
				if Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number] != Builder_playing._event_puzzles.coordinates_e_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number]:
					_sprite_scene.get_tree().call_group("game_audio", "play_puzzle_sound", 
			Enum.Puzzle_sounds.Puzzle_failed)
					
					game._can_player_move_puzzle_block = false
						
			# play a sound when puzzle is picked up or placed back on the ground.
			else:
				_sprite_scene.get_tree().call_group("game_audio", "play_puzzle_sound", 
			Enum.Puzzle_sounds.Puzzle_block_move)
			
	# this code searches every tile in the puzzle room, replacing the oppisite block color with the current color if the oppisite block color is surrounded by the current color's pieces. this is just like reversi where an empty tile breaks the search.
	# ONLY FOUR DIRECTIONS ARE NEEDED. E, SE, S AND SW.
	func _redraw_blocks(game):
		flip(game.rooms[0], game._player_tile.x, game._player_tile.y)
		
		var _i:int = -1
		for yy in range (13):
			for xx in range (13):
				_i += 1
				# place the puzzle in this 2 dimentional var, so that it is easier to process later when player moves puzzle blocks.
				if Variables._block_id == _i:
					Variables._puzzle_room_block_values[xx][yy] = Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number][_i]
		

		# this is the location of the block when block is placed back on the map.
		_i = -1
		for yy in range (13):
			for xx in range (13):
				_i += 1
				
				Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number][_i] = Variables._puzzle_room_block_values[xx][yy]
		
		# update all the sprites textures.
		for blocks in game.puzzle_blocks:		
			if Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number][blocks._id] > 0:
				blocks._sprite_scene.get_node("Sprite2D").frame = Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number][blocks._id]
						
		Variables._block_id = -1
					
	# flips blocks in one direction
	func flip_dir(xx:float, yy:float, dx:float, dy:float, _commit = false):
		var _row:float = dx # Starting index in x direction
		var _column:float = dy # Starting index in y direction
		var _other_piece_found:bool = false
		
		# In between boundaries. if player plus row var is within room.
		while ((_row + xx >= -1) and (_row + xx <= 12) and (_column + yy >= -1) and (_column + yy <= 12)):
			
			# The block to be flipped.
			if Variables._puzzle_room_block_values[xx + _row][yy + _column] == _block_to_be_flipped:
				if _commit == true:
					Variables._puzzle_room_block_values[xx + _row][yy + _column] = _block_placed_on_ground
				
				_other_piece_found = true
				
			# The block playrer placed on the ground.
			elif (Variables._puzzle_room_block_values[xx + _row][yy + _column] == _block_placed_on_ground): 
				# All possible flips become real flips.
				if _commit == false and _other_piece_found == true:
					flip_dir(xx, yy, dx, dy, true)
				
				else:
					break
				
			# The block belongs to no player.
			elif Variables._puzzle_room_block_values[xx + _row][yy + _column] == 0:
				# There are no possible flips.
				break
			
			# Advance in direction.
			_row += dx
			_column += dy
			

	func flip(room:Rect2, xx:int, yy:int):
		var rx = room.position.x + 1 # room start location.	
		var ry = room.position.y + 1
		
		"""
		for y in range (13):
			print(str(Variables._puzzle_room_block_values[0][y]) + " " + str(Variables._puzzle_room_block_values[1][y]) + " " + str(Variables._puzzle_room_block_values[2][y]) + " " + str(Variables._puzzle_room_block_values[3][y]) + " " + str(Variables._puzzle_room_block_values[4][y]) + " " + str(Variables._puzzle_room_block_values[5][y]) + " " + str(Variables._puzzle_room_block_values[6][y]) + " " + str(Variables._puzzle_room_block_values[7][y]) + " " + str(Variables._puzzle_room_block_values[8][y]) + " " + str(Variables._puzzle_room_block_values[9][y]) + " " + str(Variables._puzzle_room_block_values[10][y]) + " " + str(Variables._puzzle_room_block_values[11][y]) + " " + str(Variables._puzzle_room_block_values[12][y]))
				
		print("")
		print(Builder_playing._event_puzzles.coordinates_s_location[Builder_playing._config.game_id][Builder_playing._data.dungeon_number][Builder_playing._event_puzzles.event_number])
		"""
		
		# rx = top left coodinates of room,
		# xx = x coordinates of player.
		# 0, -1 and +1 are the direction to move to.
		flip_dir(xx - rx, yy - ry, 0, -1) 	# north
		flip_dir(xx - rx, yy - ry, +1, -1) 	# north east
		flip_dir(xx - rx, yy - ry, +1,  0) 	# east
		flip_dir(xx - rx, yy - ry, +1, +1) 	# south east
		flip_dir(xx - rx, yy - ry, 0, +1) 	# south	
		flip_dir(xx - rx, yy - ry, -1, +1) 	# south west
		flip_dir(xx - rx, yy - ry, -1,  0) 	# west
		flip_dir(xx - rx, yy - ry, -1, -1) 	# north west
		
		
	func remove():
		_sprite_scene.queue_free()


class Icons extends RefCounted:
	var tile := Vector2(0, 0)
		
	var _sprite_scene
	
	var _frame := 0
	var _id := 0
	
	# game				is the reference to the game node.
	# x and y			main map coordinates in unit.
	func _init(game, x, y, id:int = 0):
		_id = id
		
		# this holds the funcs and vars of the puzzle sprite node.
		_sprite_scene = Preload.Icons.instantiate()
		
		tile = Vector2(x, y)
		
		# the puzzle position.
		_sprite_scene.get_node(".").set_frame(_id)
		_sprite_scene.position = tile * TILE_SIZE
		
		game.add_child(_sprite_scene)
	
	
	# see mobs remove function.
	func remove():
		_sprite_scene.queue_free()
