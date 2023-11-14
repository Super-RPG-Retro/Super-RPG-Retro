"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


func _ready():
	pass


func _process(_delta):
	Hud._loaded.difficulty_score = 0
	
	# calculate the value of the difficulty score.
	Hud._loaded.difficulty_score += int(Settings._game.difficulty_level) * 300
	
	if Settings._game.clock == true:
		Hud._loaded.difficulty_score += 200
	
	if Settings._game.respawn_direct_sight == true:
		Hud._loaded.difficulty_score += 50
		
	if Settings._game.visibility_map == true:
		Hud._loaded.difficulty_score += 75
		
	if Settings._game.show_mobs_when_door_closed == false:
		Hud._loaded.difficulty_score += 50
		
	if Settings._game.show_item_when_door_closed == false:
		Hud._loaded.difficulty_score += 25
	
	if Settings._game.room_ceiling == true:
		Hud._loaded.difficulty_score += 100
	
	if Settings._game.normal_doors_exist == false:
		Hud._loaded.difficulty_score += 300
	
	if Settings._game.different_floor_tiles == true:
		Hud._loaded.difficulty_score += 50	
	
	if Settings._game.keep_mobs_in_room == false:
		Hud._loaded.difficulty_score += 150
	
	if Settings._game.use_battle_system == true:
		Hud._loaded.difficulty_score += 400
	
	if Settings._game.down_ladder_always_shown == false:
		Hud._loaded.difficulty_score += 30
		
	if Settings._game.can_continue_saved_game == false:
		Hud._loaded.difficulty_score += 700
		
		
	# the longer the mobs follows player, the more difficult it is, so this value gives more for a higher value.
	Hud._loaded.difficulty_score += Settings._game.mobs_dead_distance
	
	Hud._loaded.difficulty_score -= Settings._game.respawn_turn_elapses

				
	$LabelValue.text = str(Hud._loaded.difficulty_score)

