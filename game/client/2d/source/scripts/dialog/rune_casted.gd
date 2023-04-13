"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

onready var _accept_dialog = $AcceptDialog


func _ready():
	_accept_dialog.grab_focus()
	_accept_dialog.popup_centered()
	_accept_dialog.visible = false


# without this code the rune summary panel would be seen above this dialog when the mouse cursor moves.
func _process(_delta):
	if visible == true:
		get_tree().call_group("magic_panel", "rune_summary_visible_false")
		get_tree().call_group("inventory_panel", "inventory_summary_visible_false")
		get_tree().call_group("game_ui", "hide_parent_nodes")
		get_tree().call_group("tile_summary", "unit_text_clear")
		

func _input(event):
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.is_action_pressed("ui_left_mouse_click") || (event.is_action_pressed("ui_accept", true)):
		if _accept_dialog.visible == true:
			Variables._child_scene_open = false
			
			get_tree().call_group("magic_panel", "_on_timer_rune_select_visibility")
		
			_accept_dialog.visible = false

