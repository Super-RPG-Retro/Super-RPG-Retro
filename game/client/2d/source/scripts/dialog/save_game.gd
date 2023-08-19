"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


@onready var _confirmation_dialog := $ConfirmationDialog


func _ready():
	_confirmation_dialog.grab_focus()
	_confirmation_dialog.visible = false
	_confirmation_dialog.popup_centered()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# without this code the rune summary panel would be seen above this dialog when the mouse cursor moves.
func _process(_delta):
	if visible == true:
		get_tree().call_group("magic_panel", "rune_summary_visible_false")
		get_tree().call_group("inventory_panel", "inventory_summary_visible_false")
		get_tree().call_group("game_ui", "hide_parent_nodes")
		get_tree().call_group("tile_summary", "unit_text_clear")
		

func save_game():
	Variables._child_scene_open = false
	
	# put stats into one dictionary then save data in binary format so that nobody can edit that file.
	Common._update_stats_last_player(P._number)
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/loaded_username.txt", P.character_stats[str(P._number)]["_loaded"].Username)
		
	#save stats
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/stats.txt", P.character_stats)
	
	for _i in range (7):
		P.character_stats[str(_i)]["_saved"] = P.character_stats[str(_i)]["_loaded"]
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_loaded_game) + "/hud.txt", Hud._loaded)	
	Hud._saved = Hud._loaded

	get_tree().call_group("move", "update_visibility_map")
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_saved_game) + "/settings_game.txt", Settings._game)
	
	Filesystem.builder_playing_save_data()
	

func _on_ConfirmationDialog_confirmed():
	if _confirmation_dialog != null:
		_confirmation_dialog.visible = false

	save_game()
	Variables._child_scene_open = false
	get_tree().call_group("input_client", "_on_LineEdit_mouse_entered")

func _on_ConfirmationDialog_hide():
	Variables._child_scene_open = false
	# focus the line edit node.
	get_tree().call_group("input_client", "_on_LineEdit_mouse_entered")
	

