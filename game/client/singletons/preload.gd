"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# most preloads are here so that they are loaded at bootup instead of loading them when clicking the play button.
extends Node


const MobsScene 				= preload("res://2d/source/scenes/sprites/mobs.tscn")
const PotionScene 				= preload("res://2d/source/scenes/items/potion.tscn")
const PaperScene 				= preload("res://2d/source/scenes/items/paper.tscn")
const PuzzleScene 				= preload("res://2d/source/scenes/sprites/puzzle.tscn")
const Icons						= preload("res://2d/source/scenes/sprites/tile_event.tscn")

const _walk_1 					= preload("res://audio/sound/walk0.ogg")
const _walk_2 					= preload("res://audio/sound/walk1.ogg")

const _goodbye_mob_1 			= preload("res://audio/sound/goodbye_mob0.ogg")
const _goodbye_mob_2  			= preload("res://audio/sound/goodbye_mob1.ogg")
const _goodbye_mob_3  			= preload("res://audio/sound/goodbye_mob2.ogg")
const _goodbye_mob_4  			= preload("res://audio/sound/goodbye_mob3.ogg")
const _goodbye_mob_5  			= preload("res://audio/sound/goodbye_mob4.ogg")
const _goodbye_mob_6  			= preload("res://audio/sound/goodbye_mob5.ogg")
const _goodbye_mob_7  			= preload("res://audio/sound/goodbye_mob6.ogg")
const _goodbye_mob_8  			= preload("res://audio/sound/goodbye_mob7.ogg")
const _goodbye_mob_9  			= preload("res://audio/sound/goodbye_mob8.ogg")
const _goodbye_mob_10 			= preload("res://audio/sound/goodbye_mob9.ogg")
const _goodbye_mob_11 			= preload("res://audio/sound/goodbye_mob10.ogg")
const _goodbye_mob_12 			= preload("res://audio/sound/goodbye_mob11.ogg")
const _goodbye_mob_13 			= preload("res://audio/sound/goodbye_mob12.ogg")
const _goodbye_mob_14 			= preload("res://audio/sound/goodbye_mob13.ogg")
const _goodbye_mob_15 			= preload("res://audio/sound/goodbye_mob14.ogg")
const _goodbye_mob_16 			= preload("res://audio/sound/goodbye_mob15.ogg")
const _goodbye_mob_17 			= preload("res://audio/sound/goodbye_mob16.ogg")
const _goodbye_mob_18 			= preload("res://audio/sound/goodbye_mob17.ogg")

const _door_open_0 				= preload("res://audio/sound/door_open0.ogg")
const _door_open_1 				= preload("res://audio/sound/door_open1.ogg")
const _door_open_2 				= preload("res://audio/sound/door_open2.ogg")
const _door_open_3 				= preload("res://audio/sound/door_open3.ogg")
const _door_open_4 				= preload("res://audio/sound/door_open4.ogg")
const _door_open_5 				= preload("res://audio/sound/door_open5.ogg")
const _door_open_6 				= preload("res://audio/sound/door_open6.ogg")
const _door_open_7 				= preload("res://audio/sound/door_open7.ogg")

const _slash_0 					= preload("res://audio/sound/slash0.ogg")
const _slash_1  				= preload("res://audio/sound/slash1.ogg")
const _slash_2  				= preload("res://audio/sound/slash2.ogg")
const _slash_3  				= preload("res://audio/sound/slash3.ogg")
const _slash_4  				= preload("res://audio/sound/slash4.ogg")
const _slash_5  				= preload("res://audio/sound/slash5.ogg")
const _slash_6  				= preload("res://audio/sound/slash6.ogg")
const _slash_7  				= preload("res://audio/sound/slash7.ogg")
const _slash_8  				= preload("res://audio/sound/slash8.ogg")
const _slash_9 					= preload("res://audio/sound/slash9.ogg")

const _puzzle_block_move  		= preload("res://audio/sound/puzzle_block_move.ogg")
const _puzzle_failed  			= preload("res://audio/sound/puzzle_failed.ogg")
const _puzzle_success 			= preload("res://audio/sound/puzzle_success.ogg")

const bar_gray 					= preload("res://2d/assets/images/healthbar_gray.png")
const bar_red 					= preload("res://2d/assets/images/healthbar_red.png")
const bar_blue 					= preload("res://2d/assets/images/healthbar_blue.png")
const bar_yellow 				= preload("res://2d/assets/images/healthbar_yellow.png")

var _audio 						= preload("res://2d/source/scripts/game/game_ui_sub/audio.gd")


func _exit_tree():
	call_deferred("remove_child", MobsScene)
	call_deferred("remove_child", PaperScene)
	call_deferred("remove_child", PuzzleScene)
	call_deferred("remove_child", Icons)
	call_deferred("remove_child", _audio)

	call_deferred("queue_free", MobsScene)
	call_deferred("queue_free", PaperScene)
	call_deferred("queue_free", PuzzleScene)	
	call_deferred("queue_free", Icons)
	call_deferred("queue_free", _audio)
	
	queue_free()


