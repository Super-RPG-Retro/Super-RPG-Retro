"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node


onready var _sound_walk_timer = $SoundWalkTimer


# at try_move() func, if blocked var is not true then play this walk sound.
func start_walk_timer():
	if Settings._system.sound == true:
		# trigger the _on_sound_WalkTimer_timeout() func if not playing that sound.
		if (_sound_walk_timer.time_left == 0):
			_sound_walk_timer.start()

			
func _on_sound_WalkTimer_timeout():
	$SoundWalk.stream = get_parent()._walk_sounds[get_parent()._walk_index]
	$SoundWalk.play()	
	_sound_walk_timer.stop()
	

func _music_stop():
	if $MusicScene.is_playing() == true:
		$MusicScene.stop()
	
	if $MusicBattle.is_playing() == true:
		$MusicBattle.stop()


func _music_scene():
	_music_stop()
	
	if Settings._system.music == true:
		$MusicScene.play()
		

# show the battle system.
func _battle_system():
	_music_stop()
	
	if Settings._system.music == true:
		$MusicBattle.play()
		
	Variables._child_scene_open = true
	get_parent()._battle.visible = true
	

func play_goodbye_mob_sound():
	# play a random walking sound but first select a random sound.
	var _sound = randi() % 18 
		
	$SoundGoodbye.stream = get_parent()._goodbye_mob_sounds[_sound]
	$SoundGoodbye.play()


func play_door_sound():
	# play a random walking sound but first select a random sound
	var _sound = randi() % 7 
		
	$SoundDoor.stream = get_parent()._door_sounds[_sound]
	$SoundDoor.play()
	

func play_puzzle_sound(_num):
	$SoundDoor.stream = get_parent()._puzzle_sounds[_num]
	$SoundDoor.play()
	
	
func play_ambient():
	$AmbientWind.play()
	$AmbientWater.play()

	
func stop_ambient():
	$AmbientWind.stop()
	$AmbientWater.stop()
