"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# this is the builder vars while playing game. saving and loading the game will change these vars and not the builder vars from builder menu. also, game_world uses these vars. when a new game is created, these vars get their data from the bulder.gd vars.

extends Node


var _event_inventory 				= null
var _event_locked_doors 			= null
var _event_puzzles 					= null
var _event_story 					= null
var _event_tasks 					= null
var _dictionary_artifacts 			= null
var _audio_music 					= null
var _library_cell	 				= null
var _config 						= null
var _data 							= null
var _next_event						= null
var _event_parent					= null
var _starting_skills 				= null


func all_array_append():
	_event_inventory 	 		= Builder._event_inventory.data.duplicate(true)
	_event_locked_doors 		= Builder._event_locked_doors.data.duplicate(true)
	_event_puzzles 				= Builder._event_puzzles.data.duplicate(true)
	_event_story				= Builder._event_story.data.duplicate(true)
	_event_tasks 				= Builder._event_tasks.data.duplicate(true)
	_dictionary_artifacts 		= Builder._dictionary_artifacts.data.duplicate(true)
	_audio_music 				= Builder._audio_music.data.duplicate(true)
	_library_cell 				= Builder._library_cell.data.duplicate(true)
	_config 					= Builder._config.duplicate(true)
	_data 						= Builder._data.duplicate(true)
	_next_event 				= Builder._next_event.duplicate(true)
	_event_parent 				= Builder._event_parent.duplicate(true)
	_starting_skills 			= Builder._starting_skills.duplicate(true)


func _exit_tree():
	_event_inventory.clear()
	_event_locked_doors.clear()
	_event_puzzles.clear()
	_event_story.clear()
	_event_tasks.clear()
	
	_dictionary_artifacts.clear()
	_audio_music.clear()
	_library_cell.clear()

	_config.clear()
	_data.clear()
	_next_event.clear()
	_event_parent.clear()
	_starting_skills.clear() 	
	
	queue_free()
