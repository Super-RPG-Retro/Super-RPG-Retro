"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

onready var _game_data_text = $GameData/stats/Text
onready var _background = $Background

onready var _game_data_loaded = $GameDataLoaded/Stats/Text
onready var _game_data_saved = $GameDataSaved/Stats/Text



func _ready():
	Variables._at_scene = Enum.Scene.Main_Menu
	Variables._scene_title = "Welcome to Super RPG Retro."
	
	Preload._init()
	
	Variables._child_scene_open = true
	Variables._at_library =  Settings._system.start_3d
	Variables._dungeon_coordinates = "0,0"
	Variables._compass = "N"
	Variables._compass_last_known_for_3d = "N"
	Variables._compass_update = true
	Variables._host_is_connected = false
	
	# load the settings system file.
	var _temp = Filesystem.load_dictionary("user://saved_data/settings_system.txt")
	
	if _temp != null:
		Settings._system = _temp 
		
	if Settings._system.randomize_2d_maze == true:
			Settings._system.seed_current = Common.get_random_number()
	
	Common._music_play()
	#Builder.reset_config()
	#Builder._all_init()	
	#Builder.all_array_append()
	Filesystem.builder_load_data()
	Common._game_title()
	
func _process(_delta):
	_game_data_loaded.text = "Loaded ID " + str(Variables._id_of_loaded_game).pad_zeros(2) + ".   Statistics " + str(P._stats_loaded.Strength + P._stats_loaded.Defense + P._stats_loaded.Constitution + P._stats_loaded.Dexterity + P._stats_loaded.Intelligence + P._stats_loaded.Charisma + P._stats_loaded.Wisdom + P._stats_loaded.Willpower + P._stats_loaded.Perception + P._stats_loaded.Luck).pad_zeros(4) + "."

	_game_data_saved.text = "Saved ID " + str(Variables._id_of_saved_game).pad_zeros(2) + ".   Statistics " + str(P._stats_saved.Strength + P._stats_saved.Defense + P._stats_saved.Constitution + P._stats_saved.Dexterity + P._stats_saved.Intelligence + P._stats_saved.Charisma + P._stats_saved.Wisdom + P._stats_saved.Willpower + P._stats_saved.Perception + P._stats_saved.Luck).pad_zeros(4) + "."
	
	
func _input(event):	
	# listen for ESC to exit app
	if(event.is_pressed()):
		if (event.is_action_pressed("ui_escape", true)):
			get_tree().quit() 
			
func _quit():
	OS.execute(".//super_rpg_retro_end_task.bat", [], false)
	get_tree().quit() 


# Changing this value will change the game id value. This value is saved as part of the saved filename. a value of 2 means that game number 2 can be saved, loaded or deleted. 
func _on_SpinBox_value_changed(value):
	Variables._id_of_loaded_game = value


func _on_high_scores_Button_pressed():
	var _s = get_tree().change_scene("res://2d/source/scenes/high_scores.tscn")


func _on_builder_data_Button_pressed():
	var _s = get_tree().change_scene("res://2d/source/scenes/builder/project/home.tscn")
	

func _on_credits_Button_pressed():
	var _s = get_tree().change_scene("res://2d/source/scenes/credits.tscn")

	
func enable_settings_game_scene():
	$SettingsGame.visible = true


func disable_settings_game_scene():
	$SettingsGame.visible = false


func _on_settings_system_Button_pressed():
	var _s = get_tree().change_scene("res://2d/source/scenes/settings/system.tscn")
	

func _on_settings_game_Button_pressed():
	var _s = get_tree().change_scene("res://2d/source/scenes/settings/game.tscn")

