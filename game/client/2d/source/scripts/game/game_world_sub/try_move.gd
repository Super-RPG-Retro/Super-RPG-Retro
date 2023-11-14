"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# try_move,gd
extends Node2D


@onready var game := get_parent()
@onready var build := get_parent().get_node("BuildLevel")
@onready var damage := get_parent().get_node("Player/Damage")
@onready var timer_yield := get_parent().get_node("TimerYield")

func _ready():
	pass

# a request to save game was made. keep the visibility map updated by saving this file.	
func update_visibility_map():
	# "true" means game was requested to be saved.
	Filesystem.save_visibility_map(game.LEVEL_SIZE, game.visibility_map, true) 


func process_icons():
	for icon in game.icons:
		if game._player_tile == icon.tile and icon._id == 3:
			get_tree().call_group("game_ui", "save_game")


func process_puzzle_blocks():
	var x = game._player_tile.x
	var y = game._player_tile.y
	
	var _block_count = 0
	
	# if player is standing on a puzzle block. see try_move for setting block back to tile.
	for blocks in game.puzzle_blocks:
		# player holding a block counts as 1 value. if the block count is 2, then there is a block under feet which means the blocks.act func should be ignored since 1 block cannot be placed on top of another block.
		if blocks.tile.x == x and blocks.tile.y == y:
			_block_count += 1
			
	if _block_count < 2:
		for blocks in game.puzzle_blocks:
			blocks.act(game, x, y, blocks)
	

# everytime a request to move tile is made, this func is called only for player.
func try_move(dx, dy):
	# walk delay.
	if game._timer_move_speed_player.time_left == 0:
		game._timer_move_speed_player.start()
	else:
		return
	
	var x = game._player_tile.x + dx
	var y = game._player_tile.y + dy
	
	# keep player in room if player is holding a puzzle block.
	if game._player_holding_puzzle_block == true:
		if x < game.rooms[0].position.x + 1 or x > game.rooms[0].position.x + 13 or y < game.rooms[0].position.y + 1 or y > game.rooms[0].position.y + 13:
			return 
	
	# if true then the invisibility rune is on. decrement until var is zero then remove rune effect from player by changing player's sprite frame back to zero.
	if Variables._rune_invisible_turns > 0:
		Variables._rune_invisible_turns -= 1
	
	if Variables._rune_invisible_turns <= 0:
		game.player.frame = 0
	
	# if true then one of the haste runes is enabled. decrement until var is zero then remove rune effect from player by changing the Variables._is_haste_enabled to false. At reference file, the entity walking speed will then be set back to normal.
	if Variables._rune_haste_turns > 0:
		Variables._rune_haste_turns -= 1
	else:
		Variables._is_haste_enabled = false
		PC._move_speed = 0
		PC._move_speed = 0
	
	# player cannot move off the map. Get the tile type at requested move location.
	var tile_type = Enum.Tile.Stone	
	if x >= 0 and x < game.LEVEL_SIZE and y >= 0 and y < game.LEVEL_SIZE:
		tile_type = game.map[x][y]
	
	# respawn emeny if game turn is true.
	for mobs in game.mobs:
		if mobs.dead == false:
			# set mobs as dead for a respawn when mobs is too far away from its starting position.
			if mobs.respawn_position.x - mobs.tile.x > mobs._dead_at_tile_distance_from_start or mobs.tile.x - mobs.respawn_position.x > mobs._dead_at_tile_distance_from_start or mobs.respawn_position.y - mobs.tile.y > mobs._dead_at_tile_distance_from_start or mobs.tile.y - mobs.respawn_position.y > mobs._dead_at_tile_distance_from_start:
				if mobs.timer.time_left == 0:
					mobs._sprite_scene.get_node("AnimationPlayer").play("goodbye")
					
					mobs.timer.wait_time = 0.7
					mobs.timer.one_shot = true
					mobs.timer.start()
					
		# this condition is not 0 when the mobs is dead. everytime a user requests a player move, this var could minus 1 in value.
		if mobs._respawn_after_these_turns_current > 0:
			mobs._respawn_after_these_turns_current -= 1
			
			# respawn the mobs when this condition is true.
			if mobs._respawn_after_these_turns_current == 0:
				mobs.dead = false
				mobs._hp = mobs._hp_max
				mobs.tile = mobs.respawn_position
				
				if Settings._game.respawn_direct_sight == false:
					mobs._sprite_scene.visible = true
				
				mobs._sprite_scene.get_node("AnimationPlayer").play("hello")
				
	match tile_type:
		Enum.Tile.Stone:
			if Settings._system.sound == true and 	Variables._wait_a_turn == -1:
				get_tree().call_group("game_audio", "start_walk_timer")
			
			# This is needed for a few mob movement types so that the mobs will not move when player stands still.
			dx = 0
			dy = 0
	
		Enum.Tile.Wall:
			if Settings._system.sound == true and 	Variables._wait_a_turn == -1:
				get_tree().call_group("game_audio", "start_walk_timer")
			
			# This is needed for a few mob movement types so that the mobs will not move when player stands still.
			dx = 0
			dy = 0
	
		Enum.Tile.Floor:
			# if player is holding a puzzle block. move any block that was over player's head to a different tile.
			for blocks in game.puzzle_blocks:
				if blocks.tile.x == x - dx and blocks.tile.y == y - dy:
					blocks.move_puzzle_block(game, dx, dy, x, y)
				
			var blocked = false
			
			for mobs in game.mobs:
				if mobs.tile.x == x and mobs.tile.y == y and mobs.dead == false:
					if Settings._game.use_battle_system == true:
						_music_play()
						
						# display the battle Variables.
						get_tree().call_group("game_audio", "_battle_system")
						# enter the battle system game loop.
						get_tree().call_group("battle_system", "_battle_system", mobs, dx, dy)
						
						await timer_yield.timeout
						
					# the second parameter is the damage taken to the mobs.
					mobs.take_damage(game, 1)
					
					# a mobs found at this tile location, so set blocked to equal true.
					blocked = true
					break
						
			# location of player.
			# if tile is not blocked then move to tile.
			if !blocked:
				game._player_tile = Vector2(x, y)
				Variables._dungeon_coordinates = Common.dungeon_coordinates(x, y, false)
					
				# pickup items after player moves to a new tile, if any.
				game.pickup_items()
				
				if Settings._system.sound == true and Variables._wait_a_turn == -1:
					get_tree().call_group("game_audio", "start_walk_timer")
		
		
		Enum.Tile.Floor_rooms:
			# if player is holding a puzzle block. move any block that was over player's head to a different tile.
			for blocks in game.puzzle_blocks:
				if blocks.tile.x == x - dx and blocks.tile.y == y - dy:
					blocks.move_puzzle_block(game, dx, dy, x, y)
				
			var blocked = false
			
			for mobs in game.mobs:
				if mobs.tile.x == x and mobs.tile.y == y and mobs.dead == false:
					if Settings._game.use_battle_system == true:
						_music_play()
						
						# display the battle Variables.
						get_tree().call_group("game_audio", "_battle_system")
						# enter the battle system game loop.
						get_tree().call_group("battle_system", "_battle_system", mobs, dx, dy)
						
						await timer_yield.timeout
						
					# the second parameter is the damage taken to the mobs.
					mobs.take_damage(game, 1)
										
					# a mobs found at this tile location, so set blocked to equal true.
					blocked = true
					break
						
			# location of player.
			# if tile is not blocked then move to tile.
			if !blocked:
				game._player_tile = Vector2(x, y)
				Variables._dungeon_coordinates = Common.dungeon_coordinates(x, y, false)
					
				# pickup items after player moves to a new tile, if any.
				game.pickup_items()
				
				if Settings._system.sound == true and Variables._wait_a_turn == -1:
					get_tree().call_group("game_audio", "start_walk_timer")
		
			
		# if tile is a door then change that door into a tile.
		Enum.Tile.Door:
			# when at this code, the player walked in the room, so remove door if exists.
			if game.tile_map.get_cell_source_id(0, Vector2i(x, y)) == Enum.Tile.Door:
				build.clear_path(Vector2(x, y))
					
			# if we are here, the door was just opened.
			if game.map[x-1][y] == Enum.Tile.Ceiling or game.map[x+1][y] == Enum.Tile.Ceiling or game.map[x][y-1] == Enum.Tile.Ceiling or game.map[x][y+1] == Enum.Tile.Ceiling:
				for _i in range (game.ceiling.size()):
					# if there is a ceiling at this coordinates.
					if game.ceiling[_i].x == x-1 and game.ceiling[_i].y == y or game.ceiling[_i].x == x+1 and game.ceiling[_i].y == y or game.ceiling[_i].x == x and game.ceiling[_i].y == y-1 or game.ceiling[_i].x == x and game.ceiling[_i].y == y+1:
						# loop this ceiling var, searching for only the ceiling in that room. not every room.
						var _z = game.ceiling[_i].z
						
						# loop through the ceiling array searching only values with a room of _z
						for _ii in range (0, game.ceiling.size()):
							if game.ceiling[_ii].z == _z:	
								# if tile is a ceiling, change that tile to a floor_room tile.
								if game.map[game.ceiling[_ii].x][game.ceiling[_ii].y] == Enum.Tile.Ceiling:
									build.set_tile(game.ceiling[_ii].x, game.ceiling[_ii].y, Variables._floor_rooms_tile_value )
				# remove ceiling for ladder_down.
				game.overlay_map.set_cell(0, Variables._ladder_down, -1)
			
			build.set_tile(x, y, Enum.Tile.Floor)
			
			if Settings._system.sound == true:
				get_tree().call_group("game_audio", "play_door_sound")
		
		
		Enum.Tile.Ladder_down:
			# before going down the ladder, save the state of this level's visibility map.
			# "false" means game was not requested to be saved.
			Filesystem.save_visibility_map(game.LEVEL_SIZE, game.visibility_map, false)
			
			Settings._game.level_number += 1
			# increase dungeon level number when entering a tile that is a ladder.
			Builder_playing._data.level_number += 1
			
			Variables._going_down_level = true
			Variables._ladder_down.x = x	
			Variables._ladder_down.y = y
			
			# go to next level if Settings._game.level_number is less than max level.
			if Settings._game.level_number < game.LEVEL_SIZE:
				var _s = get_tree().change_scene_to_file("res://2d/source/scenes/game/game_ui.tscn")
			
		Enum.Tile.Ladder_up:
			# if true then a wait turn is used. player should stand still. so do not climb up ladder.
			if dx == 0 and dy == 0:
				pass
			
			else:	
				# before going up the ladder, save the state of this level's visibility map.
				# "false" means game was not requested to be saved.
				Filesystem.save_visibility_map(game.LEVEL_SIZE, game.visibility_map, false)
							
				# climbing out of the dungeon? exit to the library.
				if Settings._game.level_number == 0:
					# Cannot enter library using a mouse click because there is a bug. without this code, player could not return to dungeon.
					if Variables._wait_a_turn == 0:
						Variables._wait_a_turn = -2
						return
						
				
					Variables._at_library = true
					Variables._compass = Variables._compass_last_known_for_3d
						
					game._player_tile = Vector2(x, y)
					game.call_deferred("update_visuals")
					
					get_tree().call_group("game_ui", "scene_3d")
					
					get_parent().get_node("TimerDelayMove").start()
					
					return
				
				Settings._game.level_number -= 1
				Builder_playing._data.level_number -= 1
				
				# returning up ladder.
				Variables._going_down_level = false
				
				# player (x/y) is now at the positon of the current down ladder.			
				x = Variables._ladder_down.x
				y = Variables._ladder_down.y
				
				# go to next level if Settings._game.level_number is less than max level.
				if Settings._game.level_number < game.LEVEL_SIZE:
					var _s = get_tree().change_scene_to_file("res://2d/source/scenes/game/game_ui.tscn")
		
	# mobs movement.
	for mobs in game.mobs:
		mobs.act(game, mobs, dx, dy)	
	
	# this var is set at impair_vision()
	if Variables._potion_impair_vision_turns > 0:
		Variables._potion_impair_vision_turns -= 1
		
		# value of 3 is the potion number starting at 1
		# potion_panel is the gd file, set_label is the func followed by the func parameters.
		get_tree().call_group("potion_panel", "set_label", 1, Variables._potion_impair_vision_turns)
		
		if Variables._potion_impair_vision_turns == 0:
			get_parent().get_node("Player/Impairment").visible = false
		
	
	# cannot heal if poisoned, so this statement is elif instead of if.		
	if Variables._potion_healing_turns > 0:
		Variables._potion_healing_turns -= 1
		# value of 3 is the potion number starting at 1
		get_tree().call_group("potion_panel", "set_label", 2, Variables._potion_healing_turns)
				
		PC._hp += 2
		
		damage.damage_player(0)
	
	
	elif Variables._potion_poison_turns > 0:
		Variables._potion_poison_turns -= 1
		# value of 3 is the potion number starting at 1
		get_tree().call_group("potion_panel", "set_label", 3, Variables._potion_poison_turns)
		
		damage.damage_player(1)
			
		
	if Variables._potion_mana_turns > 0:
		Variables._potion_mana_turns -= 1
		# value of 3 is the potion number starting at 1
		get_tree().call_group("potion_panel", "set_label", 4, Variables._potion_mana_turns)
				
		PC._mp += 2
		
		damage.damage_player(0)
		
	# when adding collision to a new tile map, sometimes ray-cast needs an extra frame to update its variables. This command tells godot to wait for the next game update before going to this update_visuals function.
	game.call_deferred("update_visuals")
	
func _on_TimerMoveSpeedPlayer_timeout():
	game._timer_move_speed_player.stop()


func start_timer_yield():
	timer_yield.start(.5)


func _on_TimerYield_timeout():
	timer_yield.stop()
	

func _music_play():
	if Settings._system.music == true:
		Common._music_play(Builder_playing._audio_music.data.file_name[3], 3, false)
		Variables._last_known_music_id = 3
	
