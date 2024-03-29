"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


@onready var _game_data_text := $GameData/stats/Text

@onready var _game_data_loaded := $GameDataLoaded/Stats/Text
@onready var _game_data_saved := $GameDataSaved/Stats/Text

@onready var _credits := $Credits


func _ready():
	Variables._at_scene = Enum.Scene.Main_Menu
	Variables._scene_title = "Welcome to Super RPG Retro."
	
	Variables._at_library =  Settings._system.start_3d
	Variables._dungeon_coordinates = "0,0"
	Variables._compass = "N"
	Variables._compass_last_known_for_3d = "N"
	Variables._compass_update = true
	Variables._host_is_connected = false
	
	#Filesystem.builder_load_data()
	Common._game_title()
	Common._init_stats_player_characters() 
	
	# load the settings system file.
	var _temp = Filesystem.load_dictionary("user://saved_data/settings_system.txt")
	
	if _temp != null:
		Settings._system = _temp 
		
	if Settings._system.randomize_2d_maze == true:
			Settings._system.seed_current = Common.get_random_number()
	
	Filesystem.load_music_data()
	Common._music_play(Builder._audio_music.data.file_name[0], 0, true)
	
	
func _process(_delta):
	if Variables._id_of_loaded_game_temp != Variables._id_of_loaded_game:
		var _str = Common._skills_loaded_total()
		
		_game_data_loaded.text = "Loaded ID " + str(Variables._id_of_loaded_game).pad_zeros(2) + ".  Skills " + _str
		
		get_tree().call_group("stats_loaded", "_update_stats")
		
		Variables._id_of_loaded_game_temp = Variables._id_of_loaded_game
	
	if Variables._id_of_saved_game != Variables._id_of_saved_game_temp:
		var _str = Common._skills_saved_total()
		
		_game_data_saved.text = "Saved ID " + str(Variables._id_of_saved_game).pad_zeros(2) + ".  Skills " + _str 
		get_tree().call_group("stats_saved", "_update_stats")
		
		Variables._id_of_saved_game_temp = Variables._id_of_saved_game
		
		if get_node(".").visible == false:
			_credits.grab_focus()
			get_node(".").visible = true
		
		
func _input(event):	
	# listen for ESC to exit app
	if(event.is_pressed()):
		if (event.is_action_pressed("ui_escape", true)):
			var _s = OS.execute(".//super_rpg_retro_end_task.bat", [], [], false)
			_quit() 


func _quit():
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/stats.txt", PC.character_stats)
	
	var _s = OS.execute(".//super_rpg_retro_end_task.bat", [], [], false)
	#get_tree().quit() 


# Changing this value will change the game id value. This value is saved as part of the saved filename. a value of 2 means that game number 2 can be saved, loaded or deleted. 
func _on_SpinBox_value_changed(value):
	Variables._id_of_loaded_game = value


func _on_high_scores_Button_pressed():
	var _s = get_tree().change_scene_to_file("res://2d/source/scenes/main_menu/high_scores.tscn")


func _on_builder_data_Button_pressed():
	Filesystem.builder_load_data()

	var _s = get_tree().change_scene_to_file("res://2d/source/scenes/builder/project/home.tscn")
	

func _on_credits_Button_pressed():
	var _s = get_tree().change_scene_to_file("res://2d/source/scenes/main_menu/credits.tscn")

	
func enable_settings_game_scene():
	$SettingsGame.visible = true


func disable_settings_game_scene():
	$SettingsGame.visible = false


func _on_settings_system_Button_pressed():
	var _s = get_tree().change_scene_to_file("res://2d/source/scenes/settings/system.tscn")
	

func _on_settings_game_Button_pressed():
	var _s = get_tree().change_scene_to_file("res://2d/source/scenes/settings/game.tscn")

