"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# main menu buttons.
extends Node2D

# if true, the music will not play again until this scene reentry.
var _music_stop := false

# a message saying that after clicking the play buttom, the username is currently empty.
@onready var _empty_username_dialog := $EmptyUsernameDialog

# dialog shown after the selected game was delete.
@onready var _delete_game_dialog := $DeleteGameDialog

# confirmation before selected game is deleted.
@onready var _saved_confirmation_dialog := $SavedConfirmationDialog

# new button
@onready var _new_confirmation_dialog = $NewConfirmationDialog

# this holds the username data.
@onready var _username_line_edit = $GameDataPanel/GridContainer/GridContainer/UsernameLineEdit

# saved game id.
@onready var _saved_id = $GameDataPanel/GridContainer/GridContainer/SpinBoxSavedID

@onready var _node = get_tree().get_current_scene().get_name()


func _ready():
	P._number = 0
	P._number = int(clamp(P._number, 0, 6))
	
	_saved_id.max_value = Variables._game_id_max_value
	
	_empty_username_dialog.visible = false
	_username_line_edit.grab_focus()
	
	var _temp = null
		
	P.character_stats[str(P._number)]["_saved"].Username = P.character_stats[str(P._number)]["_loaded"].Username
	
	get_tree().call_group("stats_saved", "stats_saved_value_all_update")
	
	_temp = null	
	_temp = Filesystem.load_int("user://saved_data/id_of_saved_game.txt")
	if _temp != null:
		Variables._id_of_saved_game = _temp
	else:
		Variables._id_of_saved_game = 0
	
	_temp = Filesystem.load_int("user://saved_data/id_of_loaded_game.txt")
		
	if _temp != null:
		Variables._id_of_loaded_game = _temp
			
	else:
		Variables._id_of_loaded_game = 0
	
	if FileAccess.file_exists("user://saved_data/is_this_new_data.txt") == true:
		_temp = Filesystem.load_int("user://saved_data/is_this_new_data.txt")
		
		Variables._is_this_new_data = bool(_temp)
		
	else:
		Variables._is_this_new_data = true
	
	_on_saved_ID_spinBox_value_changed(Variables._id_of_saved_game)
	
	if Variables._is_this_new_data == true:
		_on_new_confirmation_dialog()
	
	else:
		_on_ButtonLoad_pressed(true)
	
	_username_line_edit.text = "Athena"


func _input(event):
	if (event.is_pressed()):
		if (event.is_action_pressed("ui_escape", true)):		
			_username_line_edit.focus_mode = Control.FOCUS_ALL
			_username_line_edit.grab_focus()
		
		
func _gui_input(event):			
	if(event.is_pressed()):
		if (event.is_action_pressed("ui_new", true)):
			_on_ButtonNew_pressed()
		
		if (event.is_action_pressed("ui_save", true)):
			_on_ButtonSave_pressed()
		
		if (event.is_action_pressed("ui_load", true)):
			_on_ButtonLoad_pressed()
		
		if (event.is_action_pressed("ui_delete", true)):
			_on_ButtonDelete_pressed()
		
		if (event.is_action_pressed("ui_play", true)):
			_on_ButtonPlay_pressed()
		
func _on_ButtonNew_pressed():
	Variables._id_of_loaded_game_temp = -1
	_new_confirmation_dialog.dialog_text = "New game at Game ID " + str(_saved_id.value) + "?"
		
	_new_confirmation_dialog.popup_centered()


func _on_new_confirmation_dialog():
	Variables._is_this_new_data = true
	
	Filesystem.save("user://saved_data/is_this_new_data.txt", true)	
	
	P._update_character_stats_loaded()
	
	P._xp_next = P._xp_level[P._level + 1]
	P.character_stats[str(P._number)]["_loaded"].XP_next = P._xp_next
	P.character_stats[str(P._number)]["_loaded"].Username = _username_line_edit.text
	P.character_stats[str(P._number)]["_saved"].Username = _username_line_edit.text	
	
	get_tree().call_group("stats_loaded", "stats_value_all_update")
	get_tree().call_group("stats_loaded", "stats_empty")
		
# later rename .res to .user. res uses the programs folder while .user uses the system folder. note that user:// will not work everywhere. iOS and Android won't allow it at all. you could define the prefix in a global variable and then use user:// for testing and user:// when exporting.
func _on_ButtonSave_pressed():
	Variables._id_of_saved_game_temp = -1
	Variables._id_of_loaded_game_temp = -1
	
	var _temp = null
	_temp = Filesystem.load_dictionary("user://saved_data/is_this_new_data.txt")
	
	if _temp != null:
		Variables._is_this_new_data = _temp
	
	if Variables._is_loaded_id_panel_visible == false:
		P._xp_next = P._xp_level[P._level + 1]
		P.character_stats[str(P._number)]["_loaded"].XP_next = P._xp_next
		P.character_stats[str(P._number)]["_loaded"].Username = _username_line_edit.text
		P.character_stats[str(P._number)]["_saved"].Username = _username_line_edit.text	
		
		_save_game_data()
		
	# saving to a different id so save it as new data.
	elif Variables._is_loaded_id_panel_visible == true && Variables._is_saved_id_panel_visible == false:
		Variables._is_this_new_data = false
		
		Filesystem.save("user://saved_data/is_this_new_data.txt", false)
			
		_save_game_data() 
		
	else:		
		# after clicking the dialog, code will go to the _save_game() func.
		$SaveConfirmationDialog.dialog_text = "Overwrite game data at Game ID " + str(Variables._id_of_saved_game) + "?" 
		$SaveConfirmationDialog.popup_centered()
		
func _save_game():
	# this is new game data, so delete the saved id before saving the new game data.	
	if Variables._is_this_new_data == false:
		# used for verification of deleted data.
		var _does_file_exist2
		
		# determine if file exists	
		var _does_file_exist =  FileAccess.file_exists("user://saved_data/" + str(Variables._id_of_loaded_game) + "/username.txt")
		
		if _does_file_exist == true:
			# try again to delete data.
			Filesystem._delete_game_data()
			Filesystem._copy_game_data()
			
			# determine if file was removed.
			# TODO need to display a message if this fails.
			_does_file_exist2 = FileAccess.file_exists("user://saved_data/" + str(Variables._id_of_loaded_game) + "/username.txt")
	
	_save_game_data()
	
# save the data from the loaded panel.
func _save_game_data():
	Variables._is_this_new_data = false
	
	Filesystem.save("user://saved_data/is_this_new_data.txt", false)
	
	Variables._id_of_loaded_game = Variables._id_of_saved_game
	
	Filesystem.save("user://saved_data/id_of_loaded_game.txt", Variables._id_of_loaded_game)
	
	Variables._is_this_new_data = false
	Filesystem.save("user://saved_data/is_this_new_data.txt", false)
	
	for _i in range (7):
		P.character_stats[str(_i)]["_saved"] = P.character_stats[str(_i)]["_loaded"]
	
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_saved_game) + "/username.txt", P.character_stats[str(P._number)]["_loaded"].Username)
	
	# save stats
	Filesystem.save("user://saved_data/" + str(Variables._id_of_saved_game) + "/stats.txt", P.character_stats)	
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_saved_game) + "/hud.txt", Hud._loaded)	
		
	_on_saved_ID_spinBox_value_changed(Variables._id_of_saved_game)
	
	get_tree().call_group("main_menu", "disable_settings_game_scene")
	get_tree().call_group("stats_loaded", "stats_value_all_update")
	get_tree().call_group("stats_saved", "stats_saved_value_all_update")
	
		
func _on_ButtonLoad_pressed(_bypass:bool = false):
	Variables._id_of_loaded_game_temp = -1	
	
	if _bypass == false:
		
		# determine if game exists.
		if !FileAccess.file_exists("user://saved_data/" + str(Variables._id_of_saved_game) + "/username.txt"):
			$NoGameIDexists.dialog_text = "No game exists for Game ID " + str(Variables._id_of_saved_game)
			
			$NoGameIDexists.popup_centered()
			return
		
		else:			
			Filesystem.save("user://saved_data/is_this_new_data.txt", false)	
			
			Variables._id_of_loaded_game = Variables._id_of_saved_game
			
			Filesystem.save("user://saved_data/id_of_loaded_game.txt", Variables._id_of_loaded_game)
	
			
	var _temp = null
	
	Variables._is_this_new_data = false
	
	Filesystem.save("user://saved_data/is_this_new_data.txt", false)
	
	_temp = null
	
	# load hud dictionary using the Variables._id_of_loaded_game var.
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_loaded_game) + "/hud.txt")
	
	if _temp != null:		
		Hud._loaded = _temp	
			
	_temp = null
	
	# load stats
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_saved_game) + "/hud.txt")
		
	if _temp != null:
		Hud._saved = _temp
	
	
	_temp = null
	
	# load stats dictionary using the Variables._id_of_loaded_game var.
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_loaded_game) + "/stats.txt")
	
	if _temp != null:		
		P.character_stats[str(P._number)]["_loaded"] = _temp[str(P._number)]["_loaded"]	
			
	_temp = null
	
	# load stats
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_saved_game) + "/stats.txt")
		
	if _temp != null:
		P.character_stats[str(P._number)]["_saved"] = _temp[str(P._number)]["_saved"]
			
		P._hp_max = P.character_stats[str(P._number)]["_loaded"].HP_max
		P._hp = P.character_stats[str(P._number)]["_loaded"].HP
		P._level = P.character_stats[str(P._number)]["_loaded"].Level
		P._xp = P.character_stats[str(P._number)]["_loaded"].XP
		P._xp_next = P.character_stats[str(P._number)]["_loaded"].XP_next
		
		get_tree().call_group("stats_loaded", "stats_value_all_update")
		get_tree().call_group("stats_saved", "stats_saved_value_all_update")
			
		get_tree().call_group("main_menu", "disable_settings_game_scene")
	
	# load settings game file.
	var _temp2 = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_saved_game) + "/settings_game.txt")
		
	if _temp2 != null:
		Settings._game = _temp2
		
	if Settings._game.return_to_last_level == false:
		Settings._game.level_number = 0
	else:
		Builder._data.level_number = Settings._game.level_number
	
		
func _on_ButtonDelete_pressed():
	Variables._id_of_saved_game_temp = -1
	
	# determine if file was removed
	var	_does_file_exist = FileAccess.file_exists("user://saved_data/" + str(Variables._id_of_saved_game) + "/username.txt")
	
	# only show a dialog box if there are data to delete.
	if _does_file_exist == true:	
		_saved_confirmation_dialog.dialog_text = "Delete game at Game ID " + str(Variables._id_of_saved_game) + "?"
		
		_saved_confirmation_dialog.popup_centered()


func _on_SavedConfirmationDialog_confirmed():
	var _does_file_exist
	var _does_file_exist2 # verification of data.
	
	Settings._reset_game()
	$"../SettingsGame".visible = true
	
	# determine if file exists	
	_does_file_exist = FileAccess.file_exists("user://saved_data/" + str(Variables._id_of_loaded_game) + "/username.txt")
	
	if _does_file_exist == true:
		Filesystem._delete_game_data()
		
		# determine if file was removed
		_does_file_exist2 = FileAccess.file_exists("user://saved_data/" + str(Variables._id_of_saved_game) + "/username.txt")
	
	# if file existed and was removed then show dialog box.
	if _does_file_exist2 == false:
		_delete_game_dialog.popup_centered()
		
		get_tree().call_group("stats_saved", "stats_saved_empty")


func _on_ButtonPlay_pressed():
	# determine if game exists.
	if !FileAccess.file_exists("user://saved_data/" + str(Variables._id_of_saved_game) + "/username.txt"):
		$NoGameIDexists.dialog_text = "No game exists for Game ID " + str(Variables._id_of_saved_game)
		$NoGameIDexists.popup_centered()
		return
	
		# username is empty. do not start the game.
	if Variables._is_this_new_data == true:
		_empty_username_dialog.dialog_text = "Cannot start game with no loaded data."
		_empty_username_dialog.popup_centered()
		return
	
	Variables.clear_null()
	Variables._game_over = false
	
	get_tree().call_group("settings_system", "_music_stop")		
	P.reset()
	
	# these saved visibility_map files created from the save game scene needs to be copied over other files so to correctly display the visibility map when restarting or starting a game. the reason is the visibility map is updated when using ladders or after saving a game.
	Filesystem._load_visibility_maps()
	
	# clear this because it will be populated at game.gd, once it is populated, the list will not be read again unless you reenter the game from this file.
	Json.d[str(Builder._config.game_id)]["mobs"] = {}
	
	var _temp = null
	
	# if this is a new game then start game at the starting dungeon level. to determine if this is a new game, try to load a file. if file does not exist then _temp will remain null.
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_saved_game) + "/stats.txt")
		
	if _temp == null:
		Settings._game.level_number = Builder._data.starting_level - 1
	
	Filesystem.builder_playing_load_data()
	
	var _s = get_tree().change_scene_to_file("res://2d/source/scenes/game/game_ui.tscn")
		

func _on_LineEdit_text_changed(_text):
	# get the caret position and clear the line edit. the new line edit _text will be searched using regex for valid characters.
	var old_caret_position = _username_line_edit.caret_column
	_username_line_edit.text = ""
	
	# players can only create an account using only letters and numbers. comma is used as a reserved character so no special characters are used.
	var allowed_characters = "[A-Za-z0-9_-]"
	var regex = RegEx.new()
	regex.compile(allowed_characters)
	
	# for every character in _text, update _username_line_edit but only if the character valid_character is valid.
	for valid_character in regex.search_all(_text):
		_username_line_edit.text += valid_character.get_string()

	_username_line_edit.caret_column = old_caret_position
	
	P.character_stats[str(P._number)]["_saved"].Username = _text
	

func _on_SaveConfirmationDialog_confirmed():
	_save_game()


func _on_saved_ID_spinBox_value_changed(_value):
	_saved_id.value = _value
	Variables._id_of_saved_game = _value
	Variables._id_of_saved_game_temp = -1
	
	# this is the last saved id. when the program loads or player returns to title, this data will be used to load the last saved game.
	Filesystem.save("user://saved_data/id_of_saved_game.txt", Variables._id_of_saved_game)	
	
	var _temp = null
	
	# save hud dictionary
	_temp = Filesystem.load_saved_dictionary("user://saved_data/" + str(Variables._id_of_saved_game) + "/hud.txt")
	if _temp != null:
		Hud._saved = _temp
		
	# save stats dictionary
	_temp = Filesystem.load_saved_dictionary("user://saved_data/" + str(Variables._id_of_saved_game) + "/stats.txt")
	if _temp != null:
		P.character_stats[str(P._number)]["_saved"] = _temp[str(P._number)]["_saved"]
		
		get_tree().call_group("stats_saved", "stats_saved_value_all_update")
		
		$"../SettingsGame".visible = false
		
	else:
		
		get_tree().call_group("stats_saved", "stats_saved_empty")
		
		$"../SettingsGame".visible = true		
		
	# load settings game file.
	_temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_saved_game) + "/settings_game.txt")
		
	if _temp != null:
		Settings._game = _temp
		
	else:
		Settings._reset_game()	
		
		
func _on_NoDataDialog_confirmed():
	pass	
