"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


@onready var _game_id_spin_box := $Container/Grid/Grid2/GameIDspinbox
@onready var _confirm_dialog := $ConfirmDialog
@onready var _menu = null


func _ready():
	Variables._at_scene = Enum.Scene.Builder
	Variables._scene_title = "Builder: Project Reset Game."
	
	_confirm_dialog.popup_centered()
	_confirm_dialog.visible = false

	_game_id_spin_box.value = Builder._config.game_id 
	
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
	Builder._config.game_id = value
	

func _on_Node2D_tree_exiting():
	_game_id_spin_box.queue_free()
	
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()

func _return_to_main_menu():
	var _s = get_tree().change_scene_to_file("res://3d/scenes/Gridmap.tscn")


func _on_Button_reset_pressed():
	_confirm_dialog.dialog_text = "Reset all game data with an ID of " + str(Builder._config.game_id) + ". No undo!"
	_confirm_dialog.visible = true
	

func _on_confirm_dialog_confirmed():
	Builder.reset_game(Builder._config.game_id)
	var _s = get_tree().change_scene_to_file("res://2d/source/scenes/builder/project_data.tscn")
