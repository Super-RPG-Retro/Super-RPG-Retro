"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


@onready var _accept_dialog := $AcceptDialog


func _ready():
	_accept_dialog.grab_focus()
	_accept_dialog.popup_centered()
	Variables._trigger_escape_dialog = false
	

# without this code the rune summary panel would be seen above this dialog when the mouse cursor moves.
func _process(_delta):
	if visible == true:
		get_tree().call_group("game_ui", "hide_cursor")
		get_tree().call_group("game_ui", "hide_tile_summary")
		get_tree().call_group("tile_summary", "unit_text_clear")
		

func _on_ConfirmDialog_confirmed():
	_accept_dialog.visible = false	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Settings._system.randomize_2d_maze == true:
		Settings._system.seed_current = Common.get_random_number()
	
	Variables.reset_vars()
	PC.reset_var()
	Clock.reset_vars()
	
	# this is needed here, so that the player stats panel shows the str, def, con, etc.
	Variables._at_scene = Enum.Scene.Main_Menu
	
	var _scene = get_tree().change_scene_to_file("res://2d/source/scenes/main_menu/main_menu.tscn")

	
