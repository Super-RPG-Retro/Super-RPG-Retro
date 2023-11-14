"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# here the builder object and magic code will check if their none system directories exist. if those directories do not exist then code will create them. system data will be copied to those directories. also, at user directory, files will be created for faster loading, the next time at boot splash.

extends Node


# true when ready to go to main menu. this value is false until all data has been processed and when all timers have timeout.
var _can_go_to_main_menu:= false

# this modulates the "press start" text.
var _pressed_start_modulate:= 1.0

@onready var _progress_bar:= $Panel/ProgressBar

# timer to start pulling data from the builder objects directory.
@onready var _timer_objects_display_panel:= $TimerObjectsDisplayPanel

@onready var _timer_magic_display_panel:= $TimerMagicDisplayPanel

var _total_magic_files_in_directory := 0

# if true then the magic code at _process() will be read.
var _do_magic_directory := true

# these increment the progress bar value. when value is 402, the next data directory will load.
var _reading_data_dir := false
var _reading_magic_dir := true

# changes the alpha of the progress bar.
var _modulate := 0.0 

# this var increments until it reaches the value of Variables._total_builder_data_directories. When value has been reached then the main menu will load.
var _next_builder_data_directory := 0

var _start_button_clicked := 0


func _ready():
	# if this is true then all directories have been created, there is no need to do anything else. go to main menu.
	if DirAccess.dir_exists_absolute(Variables._project_path + "/builder/magic/data/1") == true and FileAccess.file_exists("user://saved_data/builder_magic_" + str(Builder._config.game_id) + ".txt") == true: # and DirAccess.dir_exists_absolute(Variables._project_path + "/builder/magics/data/2") and DirAccess.dir_exists_absolute(Variables._project_path + "/builder/magics/data/3") and DirAccess.dir_exists_absolute(Variables._project_path + "/builder/magics/data/4") and DirAccess.dir_exists_absolute(Variables._project_path + "/builder/magics/data/5") and DirAccess.dir_exists_absolute(Variables._project_path + "/builder/magics/data/6") and DirAccess.dir_exists_absolute(Variables._project_path + "/builder/magics/data/7") and DirAccess.dir_exists_absolute(Variables._project_path + "/builder/magics/data/8"):
		$Panel.modulate = Color(1, 1, 1, 0)
		
		_show_start_button()
		
	else:
		# this will go to a timer func which will build the magic var, to be used to create the builder_magic.txt file.
		_timer_magic_display_panel.start()
		
	
func _process_objects_directory():
	if DirAccess.dir_exists_absolute(Variables._project_path + "/builder/objects/data/1"):
		$Panel.modulate = Color(1, 1, 1, 0)
		
	else:
		_timer_objects_display_panel.start()
	
	
	if DirAccess.dir_exists_absolute(Variables._project_path + "/builder/objects/images/dictionaries/1"):
		$Panel.modulate = Color(1, 1, 1, 0)
	
	else:
		# go to this func to create the res://...builder/object/ images and data directories.
		_timer_objects_display_panel.start()
	
	if _timer_objects_display_panel.time_left == 0:
		_show_start_button()
		
	
func _physics_process(_delta):
	if _start_button_clicked != 0:
		_start_button_clicked += 1
		
	if _start_button_clicked >= 5:
		_go_to_main_menu()
	
	if _total_magic_files_in_directory == Json._magic.size():
		if _reading_data_dir == true:
			_reading_magic_dir = false
	
	if _do_magic_directory == true:
		# show the progress of magic by updating the progress bar.
		if _timer_magic_display_panel.time_left > 0 and _modulate < 1:
			_modulate += 0.025
			
			$Panel.modulate = Color(1, 1, 1, _modulate)
		
		# if there are no more files for magic to process then the json object files will be processed.
		# use this value for magic.
		elif _progress_bar.value >= 400 and _total_magic_files_in_directory == Json._magic.size():
			_next_builder_data_directory = 0
			#_progress_bar.value = 0
			_modulate = 0
			_do_magic_directory = false
			
			# short delay to show the splash image before processing the res://...builder/object files.
			var t = Timer.new()
			t.set_wait_time(0.7)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			await t.timeout
			
			Filesystem.save_dictionary_json3("user://saved_data/builder_magic_" + str(Builder._config.game_id) + ".txt", Json._magic)
			
			# process the res://...builder/object json directories.
			_process_objects_directory()
		
			
	if _next_builder_data_directory == 2 and _progress_bar.value >= 402: # 402 = progress bar at 100 percent. don't change this value.
		# this is needed so that _process() func does not read this code block again.
		_next_builder_data_directory += 1
		_show_start_button()

	if _can_go_to_main_menu == true and _start_button_clicked == 0:
		if _pressed_start_modulate > 0:
			_pressed_start_modulate -= 0.1
			
		if _pressed_start_modulate <= 0:
			_pressed_start_modulate = 1
			
		$PressStart.modulate = Color(1, 1, 1, _pressed_start_modulate)
	
	
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
			
			var _timer = Timer.new()
			_timer.wait_time = 0.001
			_timer.connect("timeout", Callable(self, "_on_timer_timeout")) 
			add_child(_timer)
			_timer.start()
			
			# stop to update the progress bar.
			await _timer.timeout
			_timer.stop()
			_timer = null
			
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
					
					if _reading_magic_dir == true:
						var _file = file_name.trim_suffix(".json")
						# if true then the magic var was read correctly. store that parsed data by updating the key of the json._magic dictionary.
						if Json._magic[str(_file)].has("Group") == false:
							Json._magic[str(_file)] = _data
							
						_total_magic_files_in_directory += 1
		
								
				# then encrypt it so that nobody can edit it.
				var  _file = FileAccess.open_encrypted_with_pass(_dir_to + "/" + 
				# this password must be the same when reading the file.
				file_name, FileAccess.WRITE, "r85v&D4vHw3!df3Gd")
				_file.store_line(JSON.stringify(_data))
				_file.close()

			file_name = directory.get_next()
	
	else:
		push_warning("Error copying " + _dir_from + " to " + _dir_to)
	
	# this code is needed because there could be more then one directory number to create. see: Variables._total_builder_data_directories 
	if _do_magic_directory == true:
		_timer_magic_display_panel.start()
	else:
		_timer_objects_display_panel.start()
		
	# the magic files in their directory are all processed when this condition is true.
	if _total_magic_files_in_directory == Json._magic.size():
		Filesystem.save_dictionary_json3("user://saved_data/builder_magic_" + str(Builder._config.game_id) + ".txt", Json._magic)
			
		_reading_magic_dir = false
			
	
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
			
			var _timer = Timer.new()
			_timer.wait_time = 0.001
			_timer.connect("timeout", Callable(self, "_on_timer_timeout")) 
			add_child(_timer)
			_timer.start()
			
			await _timer.timeout
			_timer.stop()
			_timer = null
			
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

	if _do_magic_directory == true:
		_timer_magic_display_panel.start()
	else:
		_timer_objects_display_panel.start()
	

func _on_timer_timeout():
	# _progress_bar values are only an estimate because currently code cannot get count of files in directories.
	if _reading_magic_dir == true: 
		_progress_bar.value += 26.5
	
	elif _reading_data_dir == true:
		_progress_bar.value += 0.5
	
	else:
		_progress_bar.value += 0.15


func _on_timer_magic_display_panel_timeout():	
	# Creates a target directory and all necessary intermediate directories in its path, by calling make_dir() recursively.
	for _i in range (1, Variables._total_builder_data_directories + 1):
		if not DirAccess.dir_exists_absolute(Variables._project_path + "/builder/magic/data/"+ str(_i)):
			# this displays the progress text.
			$Panel/Label.text = "Creating magic "+ str(_i) + "/" + str(Variables._total_builder_data_directories) + " directories."
			_progress_bar.value = 0
			_reading_magic_dir = true
			
			# copying magic files from the magic system directory then pastes those files into the magic data directory.
			copy_directory_recursively(Variables._project_path + "/builder/magic/system", Variables._project_path + "/builder/magic/data/"+ str(_i))
				
			break
				

func _on_timer_objects_display_panel_timeout():	
	# Creates a target directory and all necessary intermediate directories in its path, by calling make_dir() recursively.
	for _i in range (1, Variables._total_builder_data_directories + 1):
		if not DirAccess.dir_exists_absolute(Variables._project_path + "/builder/objects/data/"+ str(_i)):
			$Panel/Label.text = "Creating data "+ str(_i) + "/" + str(Variables._total_builder_data_directories) + " directories."
			_progress_bar.value = 0
			_reading_data_dir = true
			
			# copying object data files from the builder object directories then pastes those files into the builder object data directories.
			copy_directory_recursively(Variables._project_path + "/builder/objects/system/data", Variables._project_path + "/builder/objects/data/"+ str(_i))
			
			# if here, then increment this var. if Variables._total_builder_data_directories is greater then this vars value then another call to this func will be done.
			if DirAccess.dir_exists_absolute(Variables._project_path + "/builder/objects/images/dictionaries/"+ str(_i)):
				_next_builder_data_directory += 1
			
			break
	
		elif not DirAccess.dir_exists_absolute(Variables._project_path + "/builder/objects/images/dictionaries/"+ str(_i)):
			
			$Panel/Label.text = "Creating image "+ str(_i) + "/" + str(Variables._total_builder_data_directories) + " directories."
			_progress_bar.value = 0
			_reading_data_dir = false
			# next, copy the res://...builder/object/system/images that the json dictionary files use and encrypt them to the new location.
			copy_image_directory_recursively(Variables._project_path + "/builder/objects/system/images/dictionaries", Variables._project_path + "/builder/objects/images/dictionaries/"+ str(_i))
			
			break	
			
		_next_builder_data_directory += 1
					

func _show_start_button():
	# short delay to show the splash image before changing scenes.
	var t = Timer.new()
	t.set_wait_time(0.3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	await t.timeout

	# free timer from memory.
	t.queue_free()
	
	# load the magic data and then place it into the json file.
	Json._magic = {}
	Json._magic = Filesystem.load_dictionary_json2("user://saved_data/builder_magic_" + str(Builder._config.game_id) + ".txt")
	
	# once all the json object dictionaires are loaded, they are saved to one file for faster game loading.
	Filesystem.populate_json_dictionaries(true)
		
	_can_go_to_main_menu = true
	$Panel.visible = false
	$PressStart.visible = true
