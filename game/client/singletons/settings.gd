"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# remember to delete the settings file at user:// after adding something here, else you will receive a run time error.
# if changing something here from false to true or true to false, then go to the system.gd or game.gd at settings folder and change it there at the ready function. the value at the ready func should be opposite of the value here.
extends Node


# general settings for the settings_game scene. 
# NOTE. remember to add the next data also at the bottom of this file, at the _reset_game() func.
var _game := {
	"clock": false,
	
	# when in a room fighting mobs, after mobs are dead, mobs will never respawn if player is outside of room at some place where mobs does not have direct sight of player.
	"respawn_direct_sight": true,
	
	# when this is true, a black map hides unexplored dungeon areas.
	"visibility_map": false,
	
	# higher level means more mobs hp, mp, etc. game play... 1:easy. 5:extremely difficult.
	"difficulty_level": 1,
	
	# show mobs in room when room door is closed?
	"show_mobs_when_door_closed": true,
	"show_item_when_door_closed": true,
	
	# should a black ceiling be placed overtop of a dungeon room, hidding objects?
	"room_ceiling": false,
	
	# are there room doors in the room? if false, mobs will exit to the corridor.
	"normal_doors_exist": true,
	
	# Off: Mobs cannot stay in room.
	"different_floor_tiles": true,
	
	# Should mobs be forced to stay in their rooms? Enabling this option will set the different colored floor tiles then corridor option to true.
	"keep_mobs_in_room": true,
	
	# Mobs are dead when they are this many units from their starting position.
	"mobs_dead_distance": 10,	
	
	# mobs will respawn after these many game turn elapses.
	"respawn_turn_elapses": 10,
	
	# In battle, if this is true, bumping into mobs will not take nor give damage. Instead, use a graphical display where you can use buttons to fight, defend, magic or run.
	"use_battle_system": false,
	
	# show down ladder when room ceiling is enabled?
	"down_ladder_always_shown": true,
	
	# After continuing game play, player will... False: return to start of game. True: return to start of last level. Game data will will not be deleted.
	"return_to_last_level": false,
	
	# current level of the dungeon the player is at.  
	"level_number": 0,
	
	# Enabled: Continue from saved game. Disabled: All data will be deleted. Player must start from the beginning again. Select this option for a major difficulty score increase.
	"can_continue_saved_game": true,
	
	# NOTE. remember to add the next data also at the bottom of this file, at _reset_game() func.	
}

# general settings for the settings_system scene. 
# NOTE. remember to add the next data also at the bottom of this file, at the _reset_system() func.
var _system := {
	"music": false,
	"start_3d": false,
	"randomize_2d_maze": true,
	"sound": true,
		
	# A random seed specifies the start point when a computer generates a random number sequence. using the same value will always display the dungeon exactly the same. the reason is because in computers there are no real randomness. when selecting a value between one and ten, at first try, the computer will always display the same value unless at startup, the seed is different. 
	"seed_current": 639971417,
	
	# each time at main menu scene when a new seed is used, the seed_current var will be set not the same as the seed_previous var so that the dungeon_level_seed var can be reset back to default, so that a new game with seed values can be stored in the dungeon_level_seed var.
	# if this var is different than seed_current, "dungeon_level_seed", var will then be reset back to default because a new dungeon seed is used.
	"seed_previous": 0,
	
	# sometimes a dungeon will not have any path for the player to take to the exit ladder. the bug happens when there are rooms touching each other without a corridor. the simple fix is just to use a working seed. however, instead, another try to build the dungeon by reentering game/game_world/build_level.gd is made. a check is made to determine if the path exists.

	# this var will be saved everytime entry to the main scene is made. the values in this var will only change when player is at a new scene. if you have never been to dungeon level 4 then this index of 3 will check for its value. if this var has no value at that index then the value from the main menu is used. if that value is already in that index then no changes to that value is given. if however, a new seed is needed because the path to ladder cannot be made then that value will be recorded and then another try to build the dungeon will be made.

	# at the debug scene, any new seed will not be seen. instead, the selected seed from main menu scene will be shown to avoid confusion.
	"dungeon_level_seed": {},
	
	# when this value is true, the client panel will be smaller in height, showing more of the map. This feature is useful for people that want to see more of the main game map.
	"small_main_map": false,
	
	# Should the navigation panel, displaying the WASD buttons and A, B, C, D buttons be shown?
	"show_player_controls": true,
	
	# play a looped sound of wind and water.
	"ambient": false,

	# after clicking a rune to cast, show guide images on map, refering to locations where a rune can be casted, unless you disable that feature at settings game scene.
	"rune_guides": true,
		
	# False: Cast the rune at the main map. True: Instant rune casting
	"automatic_rune_casting": false,
	
	# the stone wall are the dungeon corridor walls not the room walls.
	"show_stone_walls": true,
	
	# Try to show only the stone walls that parameter the corridor.
	"remove_extra_stone_walls": true,
	
	# remove every one tile wide stone tile that borders the level.
	"remove_level_border": false,
	
	# higher value can increase the corridor distance between rooms.
	"corridor_length_between_rooms": 6,
	
	# the size of the players stats panel increases when anyone of the inventory panel or magic panel is removed from the scene. when those panels are removed, this value increases. a value of 2 means both panel are removed from scene. When 1 panel is removed, this var increases in value and that new value is used to resize the player stats panel to fill in the new available stats space.
	"player_stats_panel_size": 0,
	
	# Show the connect to server buttom, public room buttom and the private room button at the client panel?
	"show_chat_features": true,
	
	# Display the panel that shows user text, output text, username, server button, public room button, private room button, commands button and game button?
	"show_client_panel": true,
	
	# NOTE. remember to add the next data also at the bottom of this file, at _reset_system() func.
	
	
}

# general settings for the settings_game. this func resets the settings game data back to default.
func _reset_game():
	_game = {
		"clock": false,
		"respawn_direct_sight": true,
		"visibility_map": false,
		"difficulty_level": 1,
		"show_mobs_when_door_closed": true,
		"show_item_when_door_closed": true,
		"room_ceiling": false,
		"normal_doors_exist": true,
		"different_floor_tiles": true,
		"keep_mobs_in_room": true,
		"mobs_dead_distance": 10,	
		"respawn_turn_elapses": 10,
		"use_battle_system": false,
		"down_ladder_always_shown": true,
		"return_to_last_level": false,
		"level_number": 0,
		"can_continue_saved_game": true,
	}


# this func is not currently used. no need to reset these var by code since they can be changed at anytime by clicking the settings system button from the main menu.
func _reset_system():
	_system = {
		"music": false,
		"start_3d": false,
		"randomize_2d_maze": true,
		"sound": true,
		"seed_current": 639971417,
		"seed_previous": 0,
		"dungeon_level_seed": {},
		"small_main_map": false,
		"show_player_controls": true,
		"ambient": false,
		"rune_guides": true,
		"automatic_rune_casting": false,
		"show_stone_walls": true,
		"remove_extra_stone_walls": true,
		"remove_level_border": false,
		"corridor_length_between_rooms": 6,
		"player_stats_panel_size": 0,
		"show_chat_features": true,
		"show_client_panel": true,
		
	}
