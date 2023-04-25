"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

onready var _game_over_dialog = $GameOverDialog
onready var _data_removed_dialog = $DataRemovedDialog
var _timer = Timer.new()

func _ready():
	_game_over_dialog.grab_focus()
	_game_over_dialog.popup_centered()
	_data_removed_dialog.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# without this code the rune summary panel would be seen above this dialog when the mouse cursor moves.
func _process(_delta):
	if visible == true:
		get_tree().call_group("magic_panel", "rune_summary_visible_false")
		get_tree().call_group("inventory_panel", "inventory_summary_visible_false")
		get_tree().call_group("game_ui", "hide_parent_nodes")
		get_tree().call_group("tile_summary", "unit_text_clear")
		

func _on_AcceptDialog_modal_closed():
	close()


func _on_AcceptDialog_popup_hide():
	close()
	
	
func close():
	if Variables._game_over == true:
		if _game_over_dialog != null:
			_game_over_dialog.visible = false
						
			if Settings._system.randomize_2d_maze == true:
				Settings._system.seed_current = Common.get_random_number()
			
			_save_data()
			

func _save_data():
	# save settings game.	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/settings_game.txt", Settings._game)
	
	# load the high score data.
	Filesystem.load_array_high_scores()
	
	# if user's stats score is within the top 10 high scores.
	for _i in range (10):
		if Hud._loaded.Score > Variables._high_score_scores[_i]:
			Variables._high_score_names.insert(_i, P.character_stats[str(P._number)]["_loaded"].Username)
			Variables._high_score_scores.insert(_i, Hud._loaded.Score)
			Variables._high_score_turns.insert(_i, Hud._loaded.Turns)
			
			break
			
	Filesystem.save_array_high_scores()
	
	# player lost game. clear score data from player's recent game so that player cannot resume a saved game using that score data because it would be to easy to get another high score.
	Hud._loaded.Score = 0
	
	if Settings._game.can_continue_saved_game == true:
		_on_DataRemoved_AcceptDialog_popup_hide()
		return
	
	var _does_file_exist
	var _does_file_exist2 # verification of data.
	
	# determine if file exists	
	var _file = File.new()
	_does_file_exist = _file.file_exists("user://saved_data/" + str(Variables._id_of_loaded_game) + "/username.txt")
	
	if _does_file_exist == true:
		# game is over. it is important to remove game from hard drive so that there are no conflicting visibility maps when playing a new game using the same game id.
		Filesystem._delete_game_data()
		
		# determine if file was removed
		_does_file_exist2 = _file.file_exists("user://saved_data/" + str(Variables._id_of_saved_game) + "/username.txt")
	
	# if file existed and was removed then show dialog box.
	if _does_file_exist == true && _does_file_exist2 == false:
		_timer.wait_time = 0.2
		_timer.connect("timeout", self, "_on_timer_timeout") 
		add_child(_timer)
		_timer.start()
		
		yield(_timer, "timeout")
		_timer.stop()
		_timer = null
		
		_data_removed_dialog.dialog_text = "Successfully removed game from hard drive."
		_data_removed_dialog.popup_centered()
		
	else:
		_timer.wait_time = 0.2
		_timer.connect("timeout", self, "_on_timer_timeout") 
		add_child(_timer)
		_timer.start()
		
		yield(_timer, "timeout")
		_timer.stop()
		_timer = null
		
		_data_removed_dialog.dialog_text = "Data could not be deleted from hard drive."
		_data_removed_dialog.popup_centered()



func _on_DataRemoved_AcceptDialog_popup_hide():
	Variables.reset_vars()
	P.reset_var()
	Clock.reset_vars()
	
	# this is needed to show the stats_loaded panel correctly.
	Variables._at_scene = Enum.Scene.Main_Menu

	var _s = get_tree().change_scene("res://2d/source/scenes/main_menu.tscn")


func _on_timer_timeout():
	pass
