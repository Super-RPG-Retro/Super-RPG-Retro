"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


@onready var _game_id_spin_box := $Container/Grid/GameIDspinbox

@onready var _game_title_line_edit := $Container/Grid/Grid3/GameTitleLineEdit

@onready var _menu = null

@onready var _confirm_update_mobs_dialog := $ConfirmUpdateMobsDialog

@onready var _confirm_update_artifacts_dialog := $ConfirmUpdateArtifactsDialog


func _ready():
	Variables._at_scene = Enum.Scene.Builder
	Variables._scene_title = "Builder: Project Home."
	
	if Settings._system.music == true:
		Common._music_play(Builder._audio_music.data.file_name[5], 5, false)
		Variables._last_known_music_id = 5
		
	_game_id_spin_box.value = Builder._config.game_id 
	_on_GameIDspinbox_value_changed(_game_id_spin_box.value)
		
	
	if _menu == null:
		_menu = load("res://2d/source/scenes/builder/menu.tscn").instantiate()
		add_child( _menu )
		
		
func _input(event):	
	if event.is_action_pressed("ui_escape", true):
		var _s = get_tree().change_scene_to_file("res://3d/scenes/Gridmap.tscn")
			
	
func _on_UseCustomGame_toggled(button_pressed):
	Builder._config.use_custom_game = button_pressed
	
	Common._game_title()

	
func _on_GameIDspinbox_value_changed(value):
	_game_title_line_edit.text = Builder._config.game_title[value]
	
	if value > 0:
		_game_title_line_edit.editable = true
	elif Variables._is_build_mode == true:
		_game_title_line_edit.editable = false
		
	
	Builder._config.game_id = value
	

func _on_GameTitleLineEdit_text_changed(new_text):
	Builder._config.game_title[Builder._config.game_id] = new_text
	
	
func _on_GameTitle_mouse_exited():
	var a = InputEventKey.new()
	a.keycode = KEY_ENTER
	a.pressed = true # change to false to simulate a key release
	Input.parse_input_event(a)
	
	Builder._config.game_title[Builder._config.game_id] = _game_title_line_edit.text
	

func _on_GameTitle_focus_exited():
	var a = InputEventKey.new()
	a.keycode = KEY_ENTER
	a.pressed = true
	Input.parse_input_event(a)
	
	Builder._config.game_title[Builder._config.game_id] = _game_title_line_edit.text
	

func _on_Node2D_tree_exiting():
	_game_id_spin_box.queue_free()
	_game_title_line_edit.queue_free()
	
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()

func _return_to_main_menu():
	var _s = get_tree().change_scene_to_file("res://3d/scenes/Gridmap.tscn")


func _on_UpdateMobsButton_pressed():
	_confirm_update_mobs_dialog.popup_centered()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_UpdateArtifactsButton_pressed():
	_confirm_update_artifacts_dialog.popup_centered()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		

func _on_mobs_AcceptDialog_confirmed():
	_empty_mobs_directory()
	_copy_files_to_mobs_directory()

# remove files and directories from the "mobs" directory because we are about to copy enabled mobs from mobs1 and mobs2 directory to the mobs directory. the reason is because, mobs directory is sorted based on dungeon numbers and level numbers. when loading a 2d level, if at level 2, only the mobs from that second directory is loaded into memory.
func _empty_mobs_directory():
	var _list = Filesystem.get_dir_contents(Variables._project_path + "/builder/objects/data/" + str(Builder._config.game_id + 1) + "/mobs/")
	
	# list[0] = files. list[1] = directories.
	for _i in _list[0]:
		if FileAccess.file_exists(_i):
			DirAccess.remove_absolute(_i)
				
	# this will remove level directories only because dungeon dictionaries are discovered first and placed in the array list at the beginning, so only empty dictionaries will be removed. therefore, this code is looped twice so to delete all directories.
	for _n in range (4):
		for _i in _list[1]:
			DirAccess.open(_i)
			if DirAccess.get_open_error() == OK:
				var _dir = DirAccess.open(_i)
				_dir.remove(_i)
	
		
	_list = Filesystem.get_dir_contents(Variables._project_path + "/builder/objects/images/dictionaries/" + str(Builder._config.game_id + 1) + "/mobs/")
	
	for _i in _list[0]:
		if FileAccess.file_exists(_i):
			DirAccess.remove_absolute(_i)
	
	# a value of 4 makes sure that everything is removed.
	for _n in range (4):
		for _i in _list[1]:
			DirAccess.open(_i)
			if DirAccess.get_open_error() == OK:
				var _dir = DirAccess.open(_i)
				_dir.remove(_i)
	

# gets the file_paths, file_names and folder_names for mobs1 and mobs2 then loads the json data into the mobs1 and mobs2 directory. then later a search for each json file to check if the enabled data equals true. those mobs files will be added to the mobs directory not mobs1 nor mobs2. the mobs directory will have only the mobs for that level when playing the game. the reason is for faster game loading. instead on loading all the mobs, most of which will not be used, we will be loading just the mobs for that level at each game level load.
func _copy_files_to_mobs_directory():
	Json.make_directories()	
	
	# get paths and file names for directory mobs1 and mobs2.
	for _dictionary_number in range (1, 3):
		Json.refresh_dictionaries(Variables._project_path + "/builder/objects/data/" + str(Builder._config.game_id + 1) + "/mobs"+ str(_dictionary_number) +"/")
		for _dn in range (8): # dungeon number
			for _ln in range (100): # level number
				for _fn in range (Variables._file_names.size()):		
					var _file_name = Variables._file_names[_fn].split("/")
					
					# if this mobs should be at this dungeon and at this level of the dungeon.
					if _dn >= Json.d[str(Builder._config.game_id)]["mobs"+ str(_dictionary_number)][_file_name[1]].At_dungeon_from && _dn <= Json.d[str(Builder._config.game_id)]["mobs"+ str(_dictionary_number)][_file_name[1]].At_dungeon_to && _ln >= Json.d[str(Builder._config.game_id)]["mobs"+ str(_dictionary_number)][_file_name[1]].At_level_from && _ln <= Json.d[str(Builder._config.game_id)]["mobs"+ str(_dictionary_number)][_file_name[1]].At_level_to:
						if Json.d[str(Builder._config.game_id)]["mobs"+ str(_dictionary_number)][_file_name[1]].Enabled == true:
							Variables._image_textures = Variables._file_paths.duplicate()
							
							# THIS FILE CANNOT BE SHORTENED ANYMORE BECAUSE THE DATA AND IMAGE DIRECTORIES EACH HAVE A DIFFERENT DIRECTORY STRUCTURE
							# dungeon number data directory.
							for _sub in range (2):
								var _str = "data"
								if _sub == 1:
									_str = "images/dictionaries"
									
								_check_make_dir(Variables._project_path + "/builder/objects/"+ _str +"/" + str(Builder._config.game_id + 1) + "/mobs/" + str(_dn))
									
								# dungeon level number data directory.
								_check_make_dir(Variables._project_path + "/builder/objects/"+ _str +"/" + str(Builder._config.game_id + 1) + "/mobs/" + str(_dn) + "/" + str(_ln))
									
								# a file will be placed inside this directory named "data".
								var _file_directory = Variables._project_path + "/builder/objects/"+ _str +"/" + str(Builder._config.game_id + 1) + "/mobs/" + str(_dn) + "/" + str(_ln) + "/" + _file_name[0]
								_check_make_dir(_file_directory)	
								
								# copy file to mobs data directory.
								if _sub == 0:
									DirAccess.copy_absolute(Variables._file_paths[_fn], _file_directory + "/" + _file_name[1] + ".json")
									
									if !FileAccess.file_exists(_file_directory + "/" + _file_name[1] + ".json"):
										printerr("failed to copy file to " +  _file_directory + "/" + _file_name[1] + ".json")
										
							# file will be placed inside this image directory.	
							var _file_directory2 = Variables._project_path + "/builder/objects/images/dictionaries/" + str(Builder._config.game_id + 1) + "/mobs/" + str(_dn) + "/" + str(_ln) + "/" + _file_name[0] + "/" + _file_name[1]
							_check_make_dir(_file_directory2)
							
							# Replaces occurrences of a case-sensitive substring with the given one inside the string.
							Variables._image_textures[_fn] = Variables._image_textures[_fn].replace(".json", "/1.png")
							Variables._image_textures[_fn] = Variables._image_textures[_fn].replace("/builder/objects/data/", "/builder/objects/images/dictionaries/")
							
							DirAccess.copy_absolute(Variables._image_textures[_fn], _file_directory2 + "/1.png")
							if !FileAccess.file_exists(_file_directory2 + "/1.png"):
								printerr("failed to copy file to " +  _file_directory2 + "/1.png")
							


func _check_make_dir(_path):
	if !DirAccess.dir_exists_absolute(_path):
		DirAccess.make_dir_absolute(_path)


func _on_MenuDungeons_tree_exiting():
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()


func _on_artifacts_AcceptDialog_confirmed():
	_empty_artifacts_directory()
	_copy_files_to_artifacts_directory()
	

func _empty_artifacts_directory():
	var _list = Filesystem.get_dir_contents(Variables._project_path + "/builder/artifacts/")
	
	# list[0] = files. list[1] = directories.
	for _i in _list[0]:
		var _file = FileAccess.open(_i, FileAccess.READ)
		_file.remove(_i)
	
	# this will remove level directories only because dungeon dictionaries are discovered first and placed in the array list at the beginning, so only empty dictionaries will be removed. therefore, this code is looped (4) so to delete all folders.
	for _n in range (4):
		for _i in _list[1]:
			var _dir = DirAccess.open(_i)
			_dir.remove(_i)
	
		
	_list = Filesystem.get_dir_contents(Variables._project_path + "/builder/artifacts/")
	
	for _i in _list[0]:
		var _file = FileAccess.open(_i, FileAccess.READ)
		_file.remove(_i)
	
	# code is looped (4) so to delete all folders.
	for _n in range (4):
		for _i in _list[1]:
			var _dir = DirAccess.open(_i)
			_dir.remove(_i)
	
	
func _copy_files_to_artifacts_directory():
	# grab 50 artifacts. break out of loop when this var reaches 50.
	var _num = 0
	var _stop:bool = false # used to break out of loop.
	
	for _i in range (50):
		Builder._dictionary_artifacts.data.file_name[_i] = ""
		Builder._dictionary_artifacts.data.file_path_json[_i] = ""
		Builder._dictionary_artifacts.data.image_texture[_i] = ""
		Builder._dictionary_artifacts.data.directory_name[_i] = ""
		
		Builder._dictionary_artifacts.data.owned[_i] = false
		Builder._dictionary_artifacts.data.is_active[_i] = false
	
		Builder._dictionary_artifacts.data.Charisma[_i] = 0
		Builder._dictionary_artifacts.data.Constitution[_i] = 0
		Builder._dictionary_artifacts.data.Defense[_i] = 0
		Builder._dictionary_artifacts.data.Dexterity[_i] = 0
		Builder._dictionary_artifacts.data.Intelligence[_i] = 0
		Builder._dictionary_artifacts.data.Luck[_i] = 0
		Builder._dictionary_artifacts.data.Perception[_i] = 0
		Builder._dictionary_artifacts.data.Strength[_i] = 0
		Builder._dictionary_artifacts.data.Willpower[_i] = 0
		Builder._dictionary_artifacts.data.Wisdom[_i] = 0
		
	for _dictionary_number in Json._s.keys():
		if _dictionary_number != "mobs":
			
			Json.refresh_dictionaries(Variables._project_path + "/builder/objects/data/" + str(Builder._config.game_id + 1) + "/"+ str(_dictionary_number) +"/")
			for _fn in range (Variables._file_names.size()):
				var _file_name = Variables._file_names[_fn].split("/")
				
				var _file_directory
				# does this dictionary have the is_artifact var set to true?
				if Json.d[str(Builder._config.game_id)][str(_dictionary_number)][_file_name[1]].Is_artifact == true:
					_num += 1
					Variables._image_textures = Variables._file_paths.duplicate()
					
					# THIS FILE CANNOT BE SHORTENED ANYMORE BECAUSE THE DATA AND IMAGE DIRECTORIES EACH HAVE A DIFFERENT DIRECTORY STRUCTURE
					# dungeon number data directory.
					for _sub in range (2):
						var _str = "data"
						if _sub == 1:
							_str = "images/dictionaries"
							
						_check_make_dir(Variables._project_path + "/builder/artifacts/")
							
						# file will be placed inside this data directory.
						_file_directory = Variables._project_path + "/builder/artifacts/" + _file_name[0]
						_check_make_dir(_file_directory)	
						
						# copy file to artifacts root directory.
						if _sub == 0:
							var dir = DirAccess.open(Variables._file_paths[_fn])
							dir.copy(Variables._file_paths[_fn], _file_directory + "/" + _file_name[1] + ".json")
							
							if !dir.file_exists(_file_directory + "/" + _file_name[1] + ".json"):
								printerr("failed to copy file to " +  _file_directory + "/" + _file_name[1] + ".json")
								
					# file will be placed inside this image directory.	
					var _file_directory2 = Variables._project_path + "/builder/artifacts/" + _file_name[0] + "/" + _file_name[1]
					_check_make_dir(_file_directory2)
					
					# Replaces occurrences of a case-sensitive substring with the given one inside the string.
					Variables._image_textures[_fn] = Variables._image_textures[_fn].replace(".json", "/1.png")
					Variables._image_textures[_fn] = Variables._image_textures[_fn].replace("/builder/objects/data/", "/builder/objects/images/dictionaries/")
					
					var dir = DirAccess.open(Variables._image_textures[_fn])	
					dir.copy(Variables._image_textures[_fn], _file_directory2 + "/1.png")
					if !dir.file_exists(_file_directory2 + "/1.png"):
						printerr("failed to copy file to " +  _file_directory2 + "/1.png")
						
					Builder._dictionary_artifacts.data.file_name[_num-1] = _file_name[1]
					Builder._dictionary_artifacts.data.file_path_json[_num-1] = _file_directory + "/" + _file_name[1] + ".json"
					Builder._dictionary_artifacts.data.image_texture[_num-1] = _file_directory2 + "/1.png"	
					Builder._dictionary_artifacts.data.directory_name[_num-1] = _dictionary_number	
										
					if _num >= 50:
						_stop = true
						
				if _stop == true:
					break
	
			if _stop == true:
				break
	
		if _stop == true:
			break
	

