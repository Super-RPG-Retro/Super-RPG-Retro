"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# game builder, creator, construction set variables.

# when adding a new var, also go to Common.builder_load_data and add the new var there.
# remember to delete the settings file at user:// after adding something here, else you will receive a run time error.

# add the new sub event to the singletons builder_events folder.
# add the var here, below extends node, and at builder_playing.
# add it here at the _all_init() func.
# add it at the builder save/load funcs at Common.

extends Node

var _event_inventory = load("res://singletons/builder/events/inventory.gd").new()
var _event_locked_doors = load("res://singletons/builder/events/locked_doors.gd").new()
var _event_puzzles = load("res://singletons/builder/events/puzzles.gd").new()
var _event_story = load("res://singletons/builder/events/story.gd").new()
var _event_tasks = load("res://singletons/builder/events/tasks.gd").new()

var _dictionary_artifacts = load("res://singletons/builder/dictionaries/artifacts.gd").new()
var _audio_music = load("res://singletons/builder/audio/music.gd").new()

# at the builder home scene, these are the options. the game id is used at Builder._data as a number index, to seperate the builder games from each other. game id 0 has a game title of "Super RPG Retro"
var _config = {
	"game_id": 				0,
	"game_title": 			["Super RPG Retro", "", "", "", "", "", "", ""],
	"dungeon_number": 		0,
	"level_number": 		0,
	# is the current dungeon selected.
	"dungeon_enabled": 		[],
	
	# for next_event to work, each sub event is called by its scene title name at next_event and then setting this var to that sub event value at next event.
	# example, if Variables._scene_title == "Builder: Event Story." then Builder._config.event_id =  will have a value of 1. see: next_event at source/builder/next_event.
	"event_id":				0, # 0: quests, 1: quests_story.
}


# _config.game_id is used at part of the file created as Builder._data_##.txt where ## is the value. when changing game_id value at the builder scene, if that value is 5, then the 5th _data file here will be loaded.
var _data = {
	# 1: true. 0: false. refers to the dungeon itself.
	"dungeon_number": 		0,
	
	# the current floor of the dungeon that is currently being edited at builder levels.
	"level_number": 		0,
	
	# this value refers to the number of the event in use.
	# while playing a game,
	"event_number":			0,
		
	# the starting floor / level of the dungeon when entering from the library. a value of 1 means the player will enter to that level.
	"starting_level": 		1,
			
	"level_size": 			[],
	# how many rooms at current level.
	"room_total": 			[],
	
	# size of room will be a random value between room_size_max and room_size_min. if both values are the same then no random is needed.
	"room_size_max": 		[],
	"room_size_min": 		[],
	
	# how many mobs at current level. this is a random value starting from 1 to this total value. there will always be at least 1 mobs at a level.
	"mobs_total": 			[],
	
	# how many items at current level. this is a random value starting from 1 to this total value.  there will always be at least 1 item at a level.
	"item_total": 			[],
	
	# size of event room. event room is where puzzles are.
	"event_room_size":		[],
	"event_enabled":		[],
	
	# is the store that sells only items enabled?
	"store_items_enabled":	[],
	
	# is the store that sells only armor enabled?
	"store_armor_enabled":	[],
	
	# is the store that sells only weapons enabled?
	"store_weapons_enabled":	[],
	
	# should a save point be enabled for this level.
	"save_point_enabled":	[],
	
	# for this feature to work, Set hide_stone_walls to true at builder. Hide a corridor from room one and a random room. Only a random value from 0 to 3 is used. When creating the corridors, The last preset room is excluded since that room is used to create the corridors.
	"hide_random_corridor":	[],
	
}

var _next_event = {
	"dungeon_number":		[],
	"level_number":			[],
	# this is the next event for this dungeon and level.
	"item_list":			[],
}

var _event_parent = {
	"event_number":			0,
	"category":				[],
	"dungeon_number":		[],
	"level_number":			[],	
	"event_enabled":		[],
	
	# at builder_data directory at hard drive, its the file name excluding its extension.
	"file_name":			[],
	
	# path including extension to the builder_data json file for this event.
	"file_path_json":		[],
	
	# this is the full path including its file name and file extension of the image at builder_data folder.
	"image_texture":		[],
	
	# at builder_data folder, this is the first folder just inside the builder/object/data/# id folder, such as, mobs, weapon, gold, etc.
	"directory_name":		[],
	
	# ask if player will accept to do this event? Otherwize, event is disabled.
	"accepting_enabled":	[],
	
	# this is the text asking if player accepts this quest.
	"accepting_text":		[],
}


var _starting_skills = {
	"Charisma": 			[0,0,0,0,0,0,0],
	"Constitution": 		[0,0,0,0,0,0,0],
	"Defense": 				[0,0,0,0,0,0,0],
	"Dexterity": 			[0,0,0,0,0,0,0],
	"Intelligence": 		[0,0,0,0,0,0,0],
	"Luck": 				[0,0,0,0,0,0,0],
	"Perception": 			[0,0,0,0,0,0,0],
	"Strength": 			[0,0,0,0,0,0,0],
	"Willpower": 			[0,0,0,0,0,0,0],
	"Wisdom":				[0,0,0,0,0,0,0],
	"HP_max":				[10,10,10,10,10,10,10],	
	"HP":					[10,10,10,10,10,10,10],
	"MP_max":				[0,0,0,0,0,0,0],	
	"MP":					[0,0,0,0,0,0,0],
	"XP":					[0,0,0,0,0,0,0],
	"XP_next":				[34,34,34,34,34,34,34],
}


func reset_config():	
	for x in range(Variables._total_builder_data_directories):
		_config.dungeon_enabled.append([])
		
		for _y in range(8):
			_config.dungeon_enabled[x].append(0)
	
	
func init_vars_data():
	_data = {
	"dungeon_number":		0,
	# 99 levels max. 
	"level_number": 		0,	
	"starting_level": 		1,
	"event_number":			0,
	
	"level_size": 			[],
	"room_total": 			[],
	"room_size_max": 		[],
	"room_size_min": 		[],
	"mobs_total": 			[],
	"item_total": 			[],
	"event_room_size":		[],
	"event_enabled":		[],
	
	"store_items_enabled":	[],
	"store_armor_enabled":	[],
	"store_weapons_enabled":	[],
	"save_point_enabled":	[],
	"hide_random_corridor":	[],
	
	}

func init_vars_next_event():
	_next_event = {
	"dungeon_number":		[],
	"level_number":			[],
	"item_list":			[],
	
	}
	
func init_vars_event_parent():
	_event_parent = {
	"event_number":			0,
	"category":				[],
	"dungeon_number":		[],
	"level_number":			[],
	"event_enabled":		[],
	"file_name":			[],
	"file_path_json":		[],
	"image_texture":		[],
	"directory_name":		[],
	"accepting_enabled":	[],
	"accepting_text":		[],	
	
	}


func all_array_append():
	for x in range (Variables._total_builder_data_directories):
		# game id.
		_data.level_size.append([])
		_data.room_total.append([])
		_data.room_size_max.append([])
		_data.room_size_min.append([])
		_data.mobs_total.append([])
		_data.item_total.append([])
		_data.event_room_size.append([])
		_data.event_enabled.append([])
		_data.store_items_enabled.append([])
		_data.store_armor_enabled.append([])
		_data.store_weapons_enabled.append([])
		_data.save_point_enabled.append([])
		_data.hide_random_corridor.append([])
					
		_next_event.dungeon_number.append([])
		_next_event.level_number.append([])
		_next_event.item_list.append([])
		
		_event_parent.category.append([])
		_event_parent.dungeon_number.append([])
		_event_parent.level_number.append([])
		_event_parent.event_enabled.append([])
		_event_parent.file_name.append([])
		_event_parent.file_path_json.append([])
		_event_parent.image_texture.append([])
		_event_parent.directory_name.append([])
		_event_parent.accepting_enabled.append([])
		_event_parent.accepting_text.append([])
				
		# dungeon number.
		for y in range (8):
			_data.level_size[x].append([])
			_data.room_total[x].append([])
			_data.room_size_max[x].append([])
			_data.room_size_min[x].append([])
			_data.mobs_total[x].append([])
			_data.item_total[x].append([])
			_data.event_room_size[x].append([])
			_data.event_enabled[x].append([])
			_data.store_items_enabled[x].append([])
			_data.store_armor_enabled[x].append([])
			_data.store_weapons_enabled[x].append([])
			_data.save_point_enabled[x].append([])
			_data.hide_random_corridor[x].append([])
					
			_next_event.dungeon_number[x].append([])
			_next_event.level_number[x].append([])
			_next_event.item_list[x].append([])
			
			_event_parent.category[x].append([])
			_event_parent.dungeon_number[x].append([])
			_event_parent.level_number[x].append([])
			_event_parent.event_enabled[x].append([])
			_event_parent.file_name[x].append([])
			_event_parent.file_path_json[x].append([])
			_event_parent.image_texture[x].append([])
			_event_parent.directory_name[x].append([])
			_event_parent.accepting_enabled[x].append([])
			_event_parent.accepting_text[x].append([])
			
			# dungeon level number.
			for z in range (803):			
				_data.level_size[x][y].append(71)
				_data.room_total[x][y].append(5)
				_data.room_size_max[x][y].append(5)
				_data.room_size_min[x][y].append(5)
				_data.mobs_total[x][y].append(1)
				_data.item_total[x][y].append(1)
				_data.event_room_size[x][y].append(0)
				_data.event_enabled[x][y].append(0)
				_data.store_items_enabled[x][y].append(0)
				_data.store_armor_enabled[x][y].append(0)
				_data.store_weapons_enabled[x][y].append(0)
				_data.save_point_enabled[x][y].append(0)
				_data.hide_random_corridor[x][y].append(0)
				
				_event_parent.category[x][y].append(0)
				_event_parent.dungeon_number[x][y].append(0)
				_event_parent.level_number[x][y].append(0)
				
				_next_event.dungeon_number[x][y].append([])
				_next_event.level_number[x][y].append([])
				_next_event.item_list[x][y].append([])
				
				# these elements that end in [] will be push_back() at builder.
				_event_parent.event_enabled[x][y].append(0)
				_event_parent.file_name[x][y].append([])
				_event_parent.file_path_json[x][y].append([])
				_event_parent.image_texture[x][y].append([])
				_event_parent.directory_name[x][y].append([])
				_event_parent.accepting_enabled[x][y].append(0)
				_event_parent.accepting_text[x][y].append("")
				
				# directory index
				for _z in range (20):
					_event_parent.file_name[x][y][z].append([])
					_event_parent.file_path_json[x][y][z].append([])
					_event_parent.image_texture[x][y][z].append([])
					_event_parent.directory_name[x][y][z].append([])
				
				# 40 possible events at builder. increase if you get an error here.
				for _q in range (40): 
					_next_event.dungeon_number[x][y][z].append(0)
					_next_event.level_number[x][y][z].append(0)
					_next_event.item_list[x][y][z].append(0)
	
	
	_event_inventory.all_array_append()
	_event_locked_doors.all_array_append()
	_event_puzzles.all_array_append()
	_event_story.all_array_append()
	_event_tasks.all_array_append()
		
	_dictionary_artifacts.all_array_append()
	_audio_music.all_array_append()
		
# at builder project menu, request to reset game data has been made. the id of the game is passed to this constructor.
func reset_game(x: int):
	# this title cannot be changed at builder when game id used equals 1.
	if x == 0:
		_config.game_title[0] = "Super RPG Retro"
	else:
		_config.game_title[x] = ""
		
	_config.dungeon_number = 0
	_config.level_number = 0
		
	for y in range(Variables._total_builder_data_directories):
		_config.dungeon_enabled[x][y] = 0
	
	_data.level_size.clear()
	_data.room_total.clear()
	_data.room_size_max.clear()
	_data.room_size_min.clear()
	_data.mobs_total.clear()
	_data.item_total.clear()
	_data.event_room_size.clear()
	_data.event_enabled.clear()
	_data.store_items_enabled.clear()
	_data.store_armor_enabled.clear()
	_data.store_weapons_enabled.clear()
	_data.save_point_enabled.clear()
	_data.hide_random_corridor.clear()
	
	_next_event.dungeon_number.clear()
	_next_event.level_number.clear()
	_next_event.item_list.clear()
	
	_event_parent.category.clear()
	_event_parent.dungeon_number.clear()
	_event_parent.level_number.clear()
	_event_parent.event_enabled.clear()
	_event_parent.file_name.clear()
	_event_parent.file_path_json.clear()
	_event_parent.image_texture.clear()
	_event_parent.directory_name.clear()
	_event_parent.accepting_enabled.clear()
	_event_parent.accepting_text.clear()
		
	_event_inventory.reset_game()
	_event_locked_doors.reset_game()
	_event_puzzles.reset_game()
	_event_story.reset_game()
	_event_tasks.reset_game()

	_dictionary_artifacts.reset_game()
	_audio_music.reset_game()
		
	# recreate the arrays in this func.
	Builder.all_array_append()
	
	Filesystem.save("user://saved_data/builder_data_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._data)
	
	Filesystem.save("user://saved_data/builder_config.txt", Builder._config)
		
	Filesystem.save("user://saved_data/builder_event_parent_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_parent)
	
	Filesystem.save("user://saved_data/builder_next_event_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._next_event)
	
	Filesystem.save("user://saved_data/builder_starting_skills.txt", Builder._starting_skills)
	

# initiates these arrays by creating array elements.	
func _all_init():
	init_vars_data()
	init_vars_event_parent()
	init_vars_next_event()
	_event_puzzles.init()
	_event_story.init()
	_event_locked_doors.init()
	_event_tasks.init()
	_event_inventory.init()
	_dictionary_artifacts.init()
	_audio_music.init()
	

func _exit_tree():
	_event_inventory.queue_free()
	_event_locked_doors.queue_free()
	_event_puzzles.queue_free()
	_event_story.queue_free()
	_event_tasks.queue_free()

	_dictionary_artifacts.queue_free()
	_audio_music.queue_free()
	
	queue_free()
