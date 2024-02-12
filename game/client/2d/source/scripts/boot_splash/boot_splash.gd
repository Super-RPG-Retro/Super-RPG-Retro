"""
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


# true when ready to go to main menu. this value is false until all data has been processed and when all timers have timeout.
var _can_go_to_main_menu:= false

# this modulates the "press start" text.
var _pressed_start_modulate:= 1.0

var thread = Thread.new()

var _start_button_clicked := 0

# if true then the magic code at _process() will be read.
var _do_magic_directory := true


func _ready():
	# this creates the sub-directories where the game id are saved and readed from.
	Filesystem._make_saved_data_directories()

	PC._update_character_stats_loaded()
	PC._update_character_stats_saved()
	PC.reset()

	# generate the xp levels.
	PC.xp_table()

	Common._game_title()
	Builder.reset_config()

	# TODO are these init needed.
	# initiate all builder data.
	Builder._all_init()
	
	#if not FileAccess.file_exists("user://saved_data/builder_config.txt"):
	Builder.all_array_append()	

	thread.start(_process_data)


func _physics_process(_delta):
	if _start_button_clicked != 0:
		_start_button_clicked += 1
		
	if _start_button_clicked >= 5:
		_go_to_main_menu()

	if _can_go_to_main_menu == true and _start_button_clicked == 0:
		if _pressed_start_modulate > 0:
			_pressed_start_modulate -= 0.1
			
		if _pressed_start_modulate <= 0:
			_pressed_start_modulate = 1
			
		$PressStart.modulate = Color(1, 1, 1, _pressed_start_modulate)
		
	if _can_go_to_main_menu == true and $PressStart.visible == false:
		_show_start_button()
		

func _input(event):	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT or event.is_action_pressed("ui_accept", true):
		if _can_go_to_main_menu == true:
			$PressStart.modulate = Color(1, 1, 1, 1)
		
			_start_button_clicked = 1


func _go_to_main_menu():
		var _s = get_tree().change_scene_to_file("res://2d/source/scenes/main_menu/main_menu.tscn")


# for the json files...
# copy a res:// directory plus all files inside that directory to the same directory at user://
func copy_directory_recursively(_dir_from: String, _dir_to: String) -> void:
	# Creates a target directory and all necessary intermediate directories in its path, by calling make_dir() recursively.
	if DirAccess.dir_exists_absolute(_dir_from):
		var directory = DirAccess.open(_dir_from)
		directory.make_dir_recursive(_dir_to)
	
	# Initializes the stream used to list all files and directories using the get_next() function, closing the currently opened stream if needed.
	DirAccess.open(_dir_from)
	if DirAccess.get_open_error() == OK:
		var directory = DirAccess.open(_dir_from)
		directory.list_dir_begin()
		
		# Returns the next element (file or directory) in the current directory
		var file_name = directory.get_next()
		
		# continue if file or directory exists.
		while (file_name != "" and file_name != "." and file_name != ".." and file_name != "desktop.ini"):
			
			Variables._progress_bar_current_value += 1
			
			# reenter this func if this is a directory.
			# Returns whether the current item processed with the last get_next() call is a directory.
			if directory.current_is_dir():
				copy_directory_recursively(_dir_from + "/" + file_name, _dir_to + "/" + file_name)
			
			# copy a file, not a directory.
			else:
				directory.copy(_dir_from + "/" + file_name, _dir_to + "/" + file_name)
				
				# get the content of the file...
				var _data = {}
				
				if FileAccess.file_exists(_dir_to + "/" + file_name):
					var _o = FileAccess.open(_dir_to + "/" + file_name, FileAccess.READ)
					var text = _o.get_as_text()
					var test_json_conv = JSON.new()
					
					test_json_conv.parse(text)
					_data = test_json_conv.get_data()
					
					if _do_magic_directory == true:
						var _file = file_name.trim_suffix(".json")
						# if true then the magic var was read correctly. store that parsed data by updating the key of the json._magic dictionary.
						if Json._magic[str(_file)].has("Group") == false:
							Json._magic[str(_file)] = _data
		
								
				# then encrypt it so that nobody can edit it.
				var  _file = FileAccess.open_encrypted_with_pass(_dir_to + "/" + 
				# this password must be the same when reading the file.
				file_name, FileAccess.WRITE, "r85v&D4vHw3!df3Gd")
				_file.store_line(JSON.stringify(_data))
				_file.close()

			file_name = directory.get_next()
	
	else:
		push_warning("Error copying " + _dir_from + " to " + _dir_to)
			
	
func copy_image_directory_recursively(_dir_from: String, _dir_to: String) -> void:
	# Creates a target directory and all necessary intermediate directories in its path, by calling make_dir() recursively.
	if DirAccess.dir_exists_absolute(_dir_from):
		var directory = DirAccess.open(_dir_from)
		directory.make_dir_recursive(_dir_to)
	
	# Initializes the stream used to list all files and directories using the get_next() function, closing the currently opened stream if needed.
	DirAccess.open(_dir_from)
	if DirAccess.get_open_error() == OK:
		var directory = DirAccess.open(_dir_from)
		directory.list_dir_begin()
		
		# Returns the next element (file or directory) in the current directory
		var file_name = directory.get_next()
		
		# continue if file or directory exists.
		while (file_name != "" and file_name != "." and file_name != ".."):
			
			Variables._progress_bar_current_value += 1
			
			# reenter this func if this is a directory.
			# Returns whether the current item processed with the last get_next() call is a directory.
			if directory.current_is_dir():
				copy_image_directory_recursively(_dir_from + "/" + file_name, _dir_to + "/" + file_name)
			
			# copy a file, not a directory.
			else:
				var _err = directory.copy(_dir_from + "/" + file_name, _dir_to + "/" + file_name)
			
				if _err != OK:
					print("Error copying image to resource path. Code " + str(_err))
				
			file_name = directory.get_next()
	
	else:
		push_warning("Error copying " + _dir_from + " to " + _dir_to)


func _process_data():	
	# Creates a target directory and all necessary intermediate directories in its path, by calling make_dir() recursively.
	for _i in range (1, Variables._total_builder_data_directories + 1):
		if not DirAccess.dir_exists_absolute(Variables._project_path + "/builder/magic/data/"+ str(_i)):
			# get the total files and dirs to be copied.
			var p = Filesystem.get_dir_contents(Variables._project_path + "/builder/magic/system/")

			Variables._progress_bar_max_value = p[0].size() + p[1].size()

			# this displays the progress text.
			Variables.label_above_progress_bar_current_value = "Creating magic "+ str(_i) + "/" + str(Variables._total_builder_data_directories) + " directories."
			
			# copying magic files from the magic system directory.
			copy_directory_recursively(Variables._project_path + "/builder/magic/system", Variables._project_path + "/builder/magic/data/"+ str(_i))
			
			# TODO should Builder._config.game_id be str(_i)?
			# the magic files in their directory are all processed when this condition is true.
			if Variables._progress_bar_current_value == Json._magic.size():
				Filesystem.save_dictionary_json3("user://saved_data/builder_magic_" + str(Builder._config.game_id) + ".txt", Json._magic)
			
			OS.delay_msec(200)

			Variables.label_above_progress_bar_current_value = ""
			Variables._progress_bar_current_value = 0

	_do_magic_directory = false
			

	# Creates a target directory and all necessary intermediate directories in its path, by calling make_dir() recursively.
	for _i in range (1, Variables._total_builder_data_directories + 1):
		if not DirAccess.dir_exists_absolute(Variables._project_path + "/builder/objects/data/"+ str(_i)):
			# get the total files and dirs to be copied.
			var p = Filesystem.get_dir_contents(Variables._project_path + "/builder/objects/system/data/")

			Variables._progress_bar_max_value = p[0].size() + p[1].size()

			Variables.label_above_progress_bar_current_value = "Creating data "+ str(_i) + "/" + str(Variables._total_builder_data_directories) + " directories."
			
			# copying object data files from the builder object directories then pastes those files into the builder object data directories.
			copy_directory_recursively(Variables._project_path + "/builder/objects/system/data", Variables._project_path + "/builder/objects/data/"+ str(_i))

			OS.delay_msec(200)

			Variables.label_above_progress_bar_current_value = ""
			Variables._progress_bar_current_value = 0
			
	
		if not DirAccess.dir_exists_absolute(Variables._project_path + "/builder/objects/images/dictionaries/"+ str(_i)):
			var p = Filesystem.get_dir_contents(Variables._project_path + "/builder/objects/system/images/dictionaries/")

			Variables._progress_bar_max_value = p[0].size() + p[1].size()

			Variables.label_above_progress_bar_current_value = "Creating image "+ str(_i) + "/" + str(Variables._total_builder_data_directories) + " directories."
		
			# next, copy the res://...builder/object/system/images that the json dictionary files use and encrypt them to the new location.
			copy_image_directory_recursively(Variables._project_path + "/builder/objects/system/images/dictionaries", Variables._project_path + "/builder/objects/images/dictionaries/"+ str(_i))

			OS.delay_msec(200)

			Variables.label_above_progress_bar_current_value = ""
			Variables._progress_bar_current_value = 0

	_can_go_to_main_menu = true


func _show_start_button():
	# load the magic data and then place it into the json file.
	Json._magic = {}
	Json._magic = Filesystem.load_dictionary_json2("user://saved_data/builder_magic_" + str(Builder._config.game_id) + ".txt")
	
	# once all the json object dictionaires are loaded, they are saved to one file for faster game loading.
	Filesystem.populate_json_dictionaries(true)
		
	$PressStart.visible = true

