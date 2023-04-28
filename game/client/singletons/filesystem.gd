"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# anything related to the hard drive is here.
# json dictionaries are saved in binary format.
extends Node

var _image			= []
var _image_texture	= []

# when resizing the image to the given width and height, pixels are calculated using the interpolation mode defined via Interpolation constants.
# INTERPOLATE_NEAREST = 0
# Performs nearest-neighbor interpolation. If the image is resized, it will be pixelated.
var _image_quality = 0

var FILE_PATH = ""
const FILE_EXT = ".json"

func save (var path : String, var thing_to_save):
	var file = File.new()
	file.open(path, File.WRITE)
	
	var _err
	if (thing_to_save != null):
		file.store_var(thing_to_save, false)
		_err = file.get_error()
	
	if _err != 0:
		printerr(path + " Could not save file. Error code " + str(_err) + ".")
		
	file.close()

	
func load_dictionary (var path : String) -> Dictionary:
	var _theDict = {}
	var file = File.new()
	var _err
	
	if file.file_exists(path):
		file.open(path, File.READ)
		_theDict = file.get_var()
		
		_err = file.get_error()
		if _err != 0:
			printerr(path + " Could not load file. Error code " + str(_err) + ".")
			
	else:
		_theDict = null
		
		
	file.close()
	return _theDict

func load_saved_dictionary (var path : String) -> Dictionary:
	var _theDict = {}
	var file = File.new()
	var _err
	
	if file.file_exists(path):
		file.open(path, File.READ)
		_theDict = file.get_var()
	
		_err = file.get_error()
		if _err != 0:
			printerr(path + " Could not load file. Error code " + str(_err) + ".")
			
	else:
		P._update_character_stats_saved()
		_theDict = null
		
	
	file.close()
	return _theDict

func load_int (var path : String) -> int:
	var file = File.new()
	var _int = 0 
	var _err
	
	if file.file_exists(path):
		file.open(path, File.READ)
		_int = file.get_var()

		_err = file.get_error()
		if _err != 0:
			printerr(path + " Could not load file. Error code " + str(_err) + ".")
	
	file.close()
	return _int


func load_array_high_scores():
	var path = "user://saved_data/"
	var file = File.new()
	var _err
	
	if not file.file_exists(path + "high_scores.txt"):
		return
	
	file.open_encrypted_with_pass(path + "high_scores.txt", File.READ, "r85v&D4vHw3!df3Gd")
	for _i in range (10):
		Variables._high_score_names[_i] = str(file.get_line())
	for _i in range (10):
		Variables._high_score_scores[_i] = int(file.get_line())
	for _i in range (10):
		Variables._high_score_turns[_i] = int(file.get_line())
	
	_err = file.get_error()
	if _err != 0:
		printerr(path + " Could not load file. Error code " + str(_err) + ".")
		
	file.close()
	
func save_array_high_scores():
	var path = "user://saved_data/"
	var _err
	
	var file = File.new()
	file.open_encrypted_with_pass(path + "high_scores.txt", File.WRITE, "r85v&D4vHw3!df3Gd")
	for _i in range (10):
		file.store_line(str(Variables._high_score_names[_i]))
	for _i in range (10):
		file.store_line(str(Variables._high_score_scores[_i]))
	for _i in range (10):
		file.store_line(str(Variables._high_score_turns[_i]))
	
	_err = file.get_error()
	if _err != 0:
		printerr(path + " Could not save file. Error code " + str(_err) + ".")
		
	file.close()

# load only the visibility map, which is the normal/black tiles of the map referring to unexplored tiles. the map starts with unexplored dungeon level tiles in black, and as the player moves around, the explored region is seen. this func saves the state of the level's visibility just before the player exits the level. 
func load_visibility_map(_size, visibility_map) -> TileMap:
	var path = "user://saved_data/" + str(Variables._id_of_loaded_game) + "/maps/"
	var file = File.new()
	var _err
	
	if file.file_exists(path + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(Settings._game.level_number) + ".txt"):
		file.open(path + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(Settings._game.level_number) + ".txt", File.READ)
		
		for x in range (_size):
			for y in range (_size):
				visibility_map.set_cell(x, y, int(file.get_line() ))
			
		_err = file.get_error()
		if _err != 0 &&	_err != 18:
			printerr(path + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(Settings._game.level_number) + ".txt. Could not load file. Error code " + str(_err) + ".")
			
		
	file.close()
	
	if file.file_exists(path + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(Settings._game.level_number) + ".txt"):
		return visibility_map
	else:
		return null


# save only the visibility map, which is the normal/black tiles of the map referring to unexplored tiles. the map starts with unexplored dungeon level tiles in black, and as the player moves around, the explored region is seen. this func saves the state of the level's visibility just before the player exits the level. 
func save_visibility_map(_size, visibility_map, _save_game_requested):
	var path = "user://saved_data/" + str(Variables._id_of_loaded_game) + "/maps/"
	var dir = Directory.new() 

	if !dir.dir_exists(path):
		dir.make_dir(path)
	
	var _err
	
	var file = File.new()
	file.open(path + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(Settings._game.level_number) + ".txt", File.WRITE)
	
	for x in range (_size):
		for y in range (_size):
			file.store_line(str(visibility_map.get_cell(x ,y)))
	
	_err = file.get_error()
	if _err != 0:
		printerr(path + " Could not save file. Error code " + str(_err) + ".")
		
	file.close()

	if _save_game_requested == true:
		for _i in range (100):	
			if dir.file_exists( path + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt"):
				_err = dir.copy(path + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt", path + "visibility_map_saved_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt")
	
			if _err != 0:
				printerr(path + " Could not copy visibility_map file " + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt. Error code " + str(_err) + ".")


# delete current game when game is over or when new game is requested at main menu.
func _delete_all_visibility_maps():
	var dir = Directory.new() 
	var path = "user://saved_data/" + str(Variables._id_of_loaded_game) + "/maps/"
	var _err
	
	if dir.dir_exists(path):
		# delete these files that were created when player first enters a dungeon level.
		for _i in range(100):
			if dir.file_exists( path + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt"):
				_err = dir.remove(path + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt")
				
				if _err != 0:
					printerr(path + " Could not remove visibility_map file " + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt. Error code " + str(_err) + ".")
					
		# delete these files that were created when saving a game.
		for _i in range(100):
			if dir.file_exists(path + "visibility_map_saved_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt"):
				_err = dir.remove(path + "visibility_map_saved_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt")
				
				if _err != 0:
					printerr(path + " Could not copy visibility_map_saved file " + "visibility_map_saved_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt. Error code " + str(_err) + ".")
					
# these saved visibility_map files created from the save game scene needs to be copied over other files so to correctly display the visibility map when restarting or starting a game. the reason is the visibility map is updated when using ladders or after saving a game.
func _load_visibility_maps():
	var path = "user://saved_data/" + str(Variables._id_of_loaded_game) + "/maps/"
	var dir = Directory.new() 
	var _err
	
	if dir.dir_exists(path):

		#remove these files since the game is about to start.
		for _i in range(100):
			if dir.file_exists( path + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt"):
				_err = dir.remove(path + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt")
		
				if _err != 0:
					printerr(path + "Could not remove " + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt")			
					
		# create the new visibility_map files from the last saved game.
		for _i in range(100):
			if dir.file_exists( path + "visibility_map_saved_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt"):
				_err = dir.copy(path + "visibility_map_saved_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt", path + "visibility_map_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt")
		
				if _err != 0:
					printerr(path + "Could not copy " + "visibility_map_saved_" + str(Variables._dungeon_number) + "-" + str(Variables._level_number) + "_" + str(Settings._system.seed_current) + "_" + str(_i) + ".txt")
					
					
func load_dictionary_json(FILE_NAME):
	var _data = {}
	var file = File.new()
	
	if file.file_exists(FILE_PATH + FILE_NAME + FILE_EXT):
		var _o = file.open_encrypted_with_pass(FILE_PATH + FILE_NAME + FILE_EXT, File.READ, "r85v&D4vHw3!df3Gd")
		
		var text = file.get_as_text()
		_data = parse_json(text)
			
		file.close()
		
	return _data


func load_dictionary_json2(FILE_NAME):
	var _data = {}
	var file = File.new()
	
	if file.file_exists(FILE_NAME):
		var _o = file.open_encrypted_with_pass(FILE_NAME, File.READ, "r85v&D4vHw3!df3Gd")
		
		var text = file.get_as_text()
		_data = parse_json(text)
		
		file.close()
	
	return _data


# TODO there are 3 save_dictionary_json funcs at this file. try to fix this mess.
func save_dictionary_json(FILE_FOLDER, FILE_NAME, _data):
	var dir = Directory.new() 
	
	if !dir.dir_exists(FILE_PATH + FILE_FOLDER):
		dir.make_dir(FILE_PATH + FILE_FOLDER)
	
	var file = File.new()
	
	file.open_encrypted_with_pass(FILE_PATH + FILE_FOLDER + "/" + FILE_NAME + FILE_EXT, File.WRITE, "r85v&D4vHw3!df3Gd")
	file.store_line(to_json(_data))
	file.close()

	
func save_dictionary_json2(FILE_NAME, _data):
	var dir = Directory.new() 

	if dir.file_exists(FILE_NAME):
		
		var file = File.new()
		
		file.open_encrypted_with_pass(FILE_NAME, File.WRITE, "r85v&D4vHw3!df3Gd")
		file.store_line(to_json(_data))
		file.close()

	
# this save json data where full path is known.
func save_dictionary_json3(_path, _data):
	var file = File.new()
			
	file.open_encrypted_with_pass(_path, File.WRITE, "r85v&D4vHw3!df3Gd")
	file.store_string(to_json(_data))
	file.close()


# this func creates an array of directory and file from path. this func is used to get every file at path and every file within sub-directories within path then that data is placed in either the directory array or file array.
func get_dir_files(_path: String, _save:bool = true):	
	var dir: = Directory.new() 
	
	if _save == true:
		var _sub_folder_temp = _path.split("/")
		Variables._sub_folder = _sub_folder_temp[_sub_folder_temp.size() - 2]
		
	var _d = dir.open(_path)
	
	if dir.file_exists(_path):
		Variables._file_paths.append(_path)
		
	else:
		# Initializes the stream used to list all files and directories using the get_next() function, closing the currently opened stream if needed. Once the stream has been processed, it should typically be closed with list_dir_end().
		_d = dir.list_dir_begin(true,  true)
				
		while(true):
			# Returns the next element (file or directory) in the current directory (including . and .., unless skip_navigational was given to list_dir_begin()).          
			var subpath := dir.get_next()
						
			if subpath.empty():
				break
			
			if dir.dir_exists(subpath):
				if subpath != "":
					Variables._folder_names.append(subpath)
			
			elif dir.file_exists(subpath):
				if subpath != "":
					Variables._file_names.append(subpath)
			
			# go back to this func and try again.
			# the game crashed at this line? maybe delete everything inside the magic/data directory.
			get_dir_files(_path.plus_file(subpath), false)
			
		dir.list_dir_end()


# rename file or directory.
func _rename_file_or_directory(_is_dir, _old_filename, _new_filename):
	var dir = Directory.new() 

	dir.rename(_old_filename, _new_filename)
	
	if _is_dir == false:
		if !dir.file_exists(_new_filename):
			print("file not existing.")
	else:
		if !dir.dir_exists(_new_filename):
			print("directory not existing.")


# Below is a complete solution for recursively getting all files and folders under a root folder.
# Return all filenames and directories (with full filepaths) under root path.
func get_dir_contents(rootPath: String) -> Array:
	var dir = Directory.new() 
	var files = []
	var directories = []
	
	# continue on thru if the path is valid.
	if dir.open(rootPath) == OK:
		# Initializes the stream used to list all files and directories using the get_next() function, closing the currently opened stream if needed. Once the stream has been processed, it should typically be closed with list_dir_end().
		dir.list_dir_begin(true, false)
		
		_add_dir_contents(dir, files, directories)
	
	else:
		push_error("An error occurred when trying to access the path.")
	
	return [files, directories]
	
# Recursively list and add all filenames and directories with full paths to their respective arrays.
# this func is not called directly. get_dir_contents calls this func.	
func _add_dir_contents(_dir: Directory, files: Array, directories: Array):
	var file_name = _dir.get_next()

	while (file_name != ""):
		var path = _dir.get_current_dir() + "/" + file_name
		
		# Returns whether the current item processed with the last get_next() call is a directory . and .. are considered directories).
		if _dir.current_is_dir():
			var subDir = Directory.new()
			subDir.open(path)
			
			# Initializes the stream used to list all files and directories using the get_next() function, closing the currently opened stream if needed. Once the stream has been processed, it should typically be closed with list_dir_end().
			subDir.list_dir_begin(true, true)
			directories.append(path)
			
			# reeneter this func to try to find another folder. else, search for a file. 
			_add_dir_contents(subDir, files, directories)
		else:
			files.append(path)
		
		# Returns the next element (file or directory) in the current directory (including . and .., unless skip_navigational was given to list_dir_begin()).
		file_name = _dir.get_next()

	_dir.list_dir_end()


# once all the json object dictionaires are loaded, they are saved to one big file for faster game loading.
func populate_json_dictionaries(_load:bool = false):
	Json.make_directories()
	
	# if that one file exists then load that data into the json Json.d which holds all builder object dictionary data.
	var _path = "user://saved_data/builder_dictionaries_" + str(Builder._config.game_id) + ".txt"
	
	if _load == true:
		var file = File.new()	
		if file.file_exists(_path):
			Json.d = Filesystem.load_dictionary_json2(_path)
			_path = ""
		file.close()
		
	if _path != "":
		# populate all json directories except the mobs directory, placing the json data into the Json.d var.
		for _i in Json.d[str(Builder._config.game_id)].keys():
			Json.refresh_dictionaries(Variables._project_path + "/builder/objects/data/" + str(Builder._config.game_id + 1) + "/" + _i + "/")
		
		Filesystem.save_dictionary_json3("user://saved_data/builder_dictionaries_" + str(Builder._config.game_id) + ".txt", Json.d)


func delete_builder_playing_data(var path):
	var dir = Directory.new() 
	var _err
	
	if dir.file_exists(path):
		_err = dir.remove(path)
			
		if _err != 0:
				printerr("could not remove " + str(path))
				

# this creates the sub-directories where the game id are saved abd kiaded from.
func _make_saved_data_directories():
	var _dir = Directory.new() 
	
	if !_dir.dir_exists("user://saved_data"):
		_dir.make_dir("user://saved_data")
	
	# values are min, max, in steps.
	for _i in range (Variables._game_id_max_value + 1):
		if !_dir.dir_exists("user://saved_data" + str(_i)):
			_dir.make_dir("user://saved_data/" + str(_i))
			_dir.make_dir("user://saved_data/" + str(_i) + "/maps")
			_dir.make_dir("user://saved_data/" + str(_i) + "/builder")
		
		else:
			break


# this calls a func to load the builder data then a builder var is assigned to that loaded data.
func builder_load_data():	
	var _temp = Filesystem.load_dictionary("user://saved_data/builder_data_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt")
	
	if _temp != null:
		Builder._data = _temp
	
	Builder_playing._data = Builder._data.duplicate(true)
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/builder_config.txt")
	
	if _temp != null:
		Builder._config = _temp
	
	Builder_playing._config = Builder._config.duplicate(true)
	
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/builder_event_puzzles_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt")
	
	if _temp != null:
		Builder._event_puzzles.data = _temp
	
	Builder_playing._event_puzzles.data = Builder._event_puzzles.data.duplicate(true)
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/builder_event_tasks_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt")
	
	if _temp != null:
		Builder._event_tasks.data = _temp
	
	Builder_playing._event_tasks.data = Builder._event_tasks.data.duplicate(true)
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/builder_event_parent_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt")
	
	if _temp != null:
		Builder._event_parent = _temp
	
	Builder_playing._event_parent = Builder._event_parent.duplicate(true)
				
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/builder_event_story_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt")
	
	if _temp != null:
		Builder._event_story.data = _temp
	
	Builder_playing._event_story.data = Builder._event_story.data.duplicate(true)
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/builder_next_event_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt")
	
	if _temp != null:
		Builder._next_event = _temp
	
	Builder_playing._next_event = Builder._next_event.duplicate(true)
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/builder_event_locked_doors_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt")
	
	if _temp != null:
		Builder._event_locked_doors.data = _temp
	
	Builder_playing._event_locked_doors.data = Builder._event_locked_doors.data.duplicate(true)
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/builder_event_inventory_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt")
	
	if _temp != null:
		Builder._event_inventory.data = _temp
	
	Builder_playing._event_inventory.data = Builder._event_inventory.data.duplicate(true)
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/builder_dictionary_artifacts_" + str(Builder._config.game_id) + ".txt")
	
	if _temp != null:
		Builder._dictionary_artifacts.data = _temp
	
	Builder_playing._dictionary_artifacts.data = Builder._dictionary_artifacts.data.duplicate(true)
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/builder_audio_music_" + str(Builder._config.game_id) + ".txt")
	
	if _temp != null:
		Builder._audio_music.data = _temp
	
	Builder_playing._audio_music.data = Builder._audio_music.data.duplicate(true)
	
	
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/builder_starting_skills_" + str(Builder._config.game_id) + ".txt")
	
	if _temp != null:
		Builder._starting_skills = _temp 
		
	Builder_playing._starting_skills = Builder._starting_skills.duplicate(true)	
		
	
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/builder_library_cell_items_" + str(Builder._config.game_id) + ".txt")
	
	if _temp != null:
		Builder._library_cell_items.data = _temp 
		
	Builder_playing._library_cell_items = Builder._library_cell_items.duplicate(true)	
	
	
	
	Builder_playing._event_inventory.data 				= Builder._event_inventory.data.duplicate(true)

	Builder_playing._event_locked_doors.data 			= Builder._event_locked_doors.data.duplicate(true)

	Builder_playing._event_puzzles.data 				= Builder._event_puzzles.data.duplicate(true)

	Builder_playing._event_story.data 					= Builder._event_story.data.duplicate(true)

	Builder_playing._event_tasks.data					= Builder._event_tasks.data.duplicate(true)

	Builder_playing._dictionary_artifacts.data			= Builder._dictionary_artifacts.data.duplicate(true)

	Builder_playing._audio_music.data					= Builder._audio_music.data.duplicate(true)


# these are the builder vars used while playing. these vars are loaded here from disk.
func builder_playing_load_data():	
	var _temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/event_puzzles.txt")
	
	if _temp != null:
		Builder_playing._event_puzzles.data = _temp
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/event_tasks.txt")
	
	if _temp != null:
		Builder_playing._event_tasks.data = _temp
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/event_parent.txt")
	
	if _temp != null:
		Builder_playing._event_parent = _temp
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/event_story.txt")
	
	if _temp != null:
		Builder_playing._event_story.data = _temp
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/next_event.txt")
	
	if _temp != null:
		Builder_playing._next_event = _temp
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/event_locked_doors.txt")
	
	if _temp != null:
		Builder_playing._event_locked_doors.data = _temp
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/event_inventory.txt")
	
	if _temp != null:
		Builder_playing._event_inventory.data = _temp
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/artifacts.txt")
	
	if _temp != null:
		Builder_playing._dictionary_artifacts.data  = _temp
		
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/music.txt")
	
	if _temp != null:
		Builder_playing._audio_music.data = _temp
	
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/dictionary_starting_skills.txt")
	
	if _temp != null:
		Builder_playing._starting_skills = _temp
	
	
	_temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/builder_library_cell_items.txt")
	
	if _temp != null:
		Builder_playing._library_cell_items.data = _temp


# save all builder data.
func builder_save_data():
	Filesystem.save("user://saved_data/builder_event_tasks_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_tasks.data)	
	
	Filesystem.save("user://saved_data/builder_event_story_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_story.data)
	
	Filesystem.save("user://saved_data/builder_event_puzzles_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_puzzles.data)
	
	Filesystem.save("user://saved_data/builder_event_locked_doors_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_locked_doors.data)
	
	Filesystem.save("user://saved_data/builder_event_inventory_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_inventory.data)
	
	Filesystem.save("user://saved_data/builder_data_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._data)
	
	Filesystem.save("user://saved_data/builder_config.txt", Builder._config)
		
	Filesystem.save("user://saved_data/builder_event_parent_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_parent)
	
	Filesystem.save("user://saved_data/builder_next_event_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._next_event)
	
	Filesystem.save("user://saved_data/builder_dictionary_artifacts_" + str(Builder._config.game_id) + ".txt", Builder._dictionary_artifacts.data)
	
	Filesystem.save("user://saved_data/builder_audio_music_" + str(Builder._config.game_id) + ".txt", Builder._audio_music.data)
	
	Filesystem.save("user://saved_data/builder_starting_skills_" + str(Builder._config.game_id) + ".txt", Builder._starting_skills)
	
	Filesystem.save("user://saved_data/builder_library_cell_items_" + str(Builder._config.game_id) + ".txt", Builder._library_cell_items.data)
	
	
# these are the builder vars used while playing. these vars are loaded here from disk.
func builder_playing_save_data():
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/event_tasks.txt", Builder_playing._event_tasks.data)	
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/event_story.txt", Builder_playing._event_story.data)
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/event_puzzles.txt", Builder_playing._event_puzzles.data)
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/event_locked_doors.txt", Builder_playing._event_locked_doors.data)
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/event_inventory.txt", Builder_playing._event_inventory.data)
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/event_parent.txt", Builder_playing._event_parent)
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/next_event.txt", Builder_playing._next_event)
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/artifacts.txt", Builder_playing._dictionary_artifacts.data)
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/music.txt", Builder_playing._audio_music.data)
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/dictionary_starting_skills.txt", Builder_playing._starting_skills)
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/builder/builder_library_cell_items.txt", Builder_playing._library_cell_items.data)



func _delete_game_data():
	var dir = Directory.new() 
	
	var _list = Filesystem.get_dir_contents("user://saved_data/" + str(Variables._id_of_saved_game))
	
	# list[0] = files. list[1] = directories.
	for _i in _list[0]:
		dir.remove(_i)
	
	var _err = dir.remove("user://saved_data/is_this_new_data.txt")
	
	if _err != 0:
		printerr("could not remove is_this_new_data.txt")
			
	
func _copy_game_data():
	var dir = Directory.new() 
	
	var _list = Filesystem.get_dir_contents("user://saved_data/" + str(Variables._id_of_loaded_game))
	
	
	var _from = []
	var _to = []
	
	
	for _f in _list[0]:
		_from.append(_f)
		
		var _str = _f.replace("user://saved_data/" + str(Variables._id_of_loaded_game), "user://saved_data/" + str(Variables._id_of_saved_game))
		_to.append(_str)
	
	# list[0] = files. list[1] = directories.
	for _i in range (_from.size()):
		
		# copy files from game loaded id to game saved id.
		var _err = dir.copy(_from[_i], _to[_i])
	
		if _err != 0:
			printerr(_from + " Could not copy game data")


# no import file needed. also can save png files this way.
func _load_external_image(path, _num:int = 1):
	_image.append([])
	
	# the amount of _image_texture elements is always the same size as the _image var
	var _i = _image.size() - 1
	
	_image[_i] = Image.new()
	_image[_i].load(path)
	
	var _size = 32 * _num
	
	_image[_i].resize(_size, _size, _image_quality)
	
	_image_texture.append([])
	_image_texture[_i] = ImageTexture.new()
	_image_texture[_i].create_from_image(_image[_i])
	
	return _image_texture[_i]
