"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# this is the builder vars while playing game. saving and loading the game will change these vars and not the builder vars from builder menu. also, game_world uses these vars. when a new game is created, these vars get their data from the bulder.gd vars.

extends Node

var _event_inventory = load("res://singletons/builder/events/inventory.gd").new()
var _event_locked_doors = load("res://singletons/builder/events/locked_doors.gd").new()
var _event_puzzles = load("res://singletons/builder/events/puzzles.gd").new()
var _event_story = load("res://singletons/builder/events/story.gd").new()
var _event_tasks = load("res://singletons/builder/events/tasks.gd").new()

var _dictionary_artifacts = load("res://singletons/builder/dictionaries/artifacts.gd").new()
var _audio_music = load("res://singletons/builder/audio/music.gd").new()

var _library_cell = load("res://singletons/builder/library/cells.gd").new()

var _config 					= Builder._config.duplicate(true)

var _data 						= Builder._data.duplicate(true)

var _next_event 				= Builder._next_event.duplicate(true)

var _event_parent 				= Builder._event_parent.duplicate(true)

var _starting_skills 				= Builder._starting_skills.duplicate(true)


func _exit_tree():
	_event_inventory.queue_free()
	_event_locked_doors.queue_free()
	_event_puzzles.queue_free()
	_event_story.queue_free()
	_event_tasks.queue_free()
	
	_dictionary_artifacts.queue_free()	
	_audio_music.queue_free()
	_library_cell.queue_free()
	
	queue_free()
