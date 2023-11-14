"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


func _ready():
	Variables._at_scene = Enum.Scene.Settings_game
	Variables._scene_title = "Settings Game."
	
	# load settings game file.
	var _temp = Filesystem.load_dictionary("user://saved_data/" + str(Variables._id_of_saved_game) + "/settings_game.txt")
		
	if _temp != null:
		Settings._game = _temp
	
	get_node("Container").set_follow_focus(true)	
	get_node("Container/Grid/UseClock").grab_focus()
	get_node("Container/Grid/GridChild/DifficultySpinbox").value = Settings._game.difficulty_level
	
	# set the pressed state of the buttons/spinboxes.
	if Settings._game.clock == false:
		get_node("Container/Grid/UseClock").set_pressed(false)
	
	if Settings._game.respawn_direct_sight == false:
		get_node("Container/Grid/RespawnDirectSight").set_pressed(false)
	
	if Settings._game.visibility_map == true:
		get_node("Container/Grid/VisibilityMap").set_pressed(true)
	
	if Settings._game.show_mobs_when_door_closed == false:
		get_node("Container/Grid/ShowMobsDoorClosed").set_pressed(false)
		
	if Settings._game.show_item_when_door_closed == false:
		get_node("Container/Grid/ShowItemDoorClosed").set_pressed(false)
		
	if Settings._game.room_ceiling == false:
		get_node("Container/Grid/RoomCeiling").set_pressed(false)
	
	if Settings._game.normal_doors_exist == false:
		get_node("Container/Grid/NormalDoorsExist").set_pressed(false)
		
	if Settings._game.different_floor_tiles == false:
		get_node("Container/Grid/DifferentFloorTiles").set_pressed(false)
		
	if Settings._game.use_battle_system == false:
		get_node("Container/Grid/UseBattleSystem").set_pressed(false)
			
	if Settings._game.down_ladder_always_shown == false:
		get_node("Container/Grid/DownLadderAlwaysShown").set_pressed(false)
		
	if Settings._game.return_to_last_level == false:
		get_node("Container/Grid/ReturnToLastLevel").set_pressed(false)

	if Settings._game.can_continue_saved_game == false:
		get_node("Container/Grid/CanContinueSavedGame").set_pressed(false)
			
	get_node("Container/Grid/GridChild2/MobsDeadDistanceSpinbox").value = Settings._game.mobs_dead_distance
	
	get_node("Container/Grid/GridChild3/RespawnTurnElapsesSpinbox").value = Settings._game.respawn_turn_elapses
	
	# sometimes setting one config feature will disable or enable another config feature.
	keep_mobs_in_room()
	different_floor_tiles()
	normal_doors_exist()


func keep_mobs_in_room():
	if Settings._game.keep_mobs_in_room == false:
		get_node("Container/Grid/DifferentFloorTiles").disabled = false
		get_node("Container/Grid/KeepMobsInRoom").set_pressed(false)
	else:
		get_node("Container/Grid/DifferentFloorTiles").set_pressed(true)
		get_node("Container/Grid/DifferentFloorTiles").disabled = true
	

func different_floor_tiles():
	if Settings._game.different_floor_tiles == false:
		get_node("Container/Grid/DifferentFloorTiles").set_pressed(false)
		get_node("Container/Grid/RoomCeiling").disabled = true
	else:
		get_node("Container/Grid/DifferentFloorTiles").set_pressed(true)
		get_node("Container/Grid/RoomCeiling").disabled = false
		
	
func normal_doors_exist():
	if Settings._game.normal_doors_exist == false:
		get_node("Container/Grid/RoomCeiling").disabled = true
		get_node("Container/Grid/RoomCeiling").set_pressed(false)
	elif Settings._game.different_floor_tiles == true:
		get_node("Container/Grid/RoomCeiling").disabled = false


func _input(event):
	# listen for ESC to exit app
	if(event.is_pressed()):
		if (event.is_action_pressed("ui_escape", true)):
			var _s = get_tree().change_scene_to_file("res://2d/source/scenes/main_menu/main_menu.tscn")


func _gui_input(event):
	# this registers a keypress in case the user is at a spinbox and editing that spinbox value using the keyboard. The problem is that without this code, changing the value without pressing enter key would not save that new value when exiting that scene.
	if Variables._at_scene == Enum.Scene.Settings_game:
		Common._scancode_if_pressed_enter(event)
	
	
func _on_respawn_direct_sight_Enabled_toggled(button_pressed):
	Settings._game.respawn_direct_sight = button_pressed	
			

func _on_visibility_Map_Enabled_toggled(button_pressed):
	Settings._game.visibility_map = button_pressed	
	

func _return_to_main_menu():
	var _s = get_tree().change_scene_to_file("res://2d/source/scenes/main_menu/main_menu.tscn")


func _on_difficulty_spinbox_value_changed(value):
	Settings._game.difficulty_level = value		
	
	
func _on_show_mobs_door_closed_Enabled_toggled(button_pressed):
	Settings._game.show_mobs_when_door_closed = button_pressed
	

func _on_show_item_door_closed_Enabled_toggled(button_pressed):
	Settings._game.show_item_when_door_closed = button_pressed
	
	
func _on_RoomCeiling_Enabled_toggled(button_pressed):
	Settings._game.room_ceiling = button_pressed
	

# Replace with function body.
func _on_normal_doors_exist_Enabled_toggled(button_pressed):
	Settings._game.normal_doors_exist = button_pressed
	normal_doors_exist()
	

func _on_different_floor_tiles_Enabled_toggled(button_pressed):
	Settings._game.different_floor_tiles = button_pressed
	different_floor_tiles()
	
	
func _on_keep_mobs_in_room_Enabled_toggled(button_pressed):
	Settings._game.keep_mobs_in_room = button_pressed
	keep_mobs_in_room()
	
	
func _on_mobs_dead_distance_spinbox_value_changed(value):
	Settings._game.mobs_dead_distance = value		
	Filesystem.save("user://saved_data/" + str(Variables._id_of_saved_game) + "/settings_game.txt", Settings._game)


func _on_respawn_turn_elapses_spinbox_value_changed(value):
	Settings._game.respawn_turn_elapses = value		
	
	
func _on_use_battle_system_Enabled_toggled(button_pressed):
	Settings._game.use_battle_system = button_pressed
	different_floor_tiles()
	
	
func _on_down_ladder_always_shown_Enabled_toggled(button_pressed):
	Settings._game.down_ladder_always_shown = button_pressed
	

func _on_time_system_toggled(button_pressed):
	Settings._game.clock = button_pressed


func _on_return_to_last_level_Enabled_toggled(button_pressed):
	Settings._game.return_to_last_level = button_pressed
	

func _on_Node2D_tree_exiting():
	Filesystem.save("user://saved_data/" + str(Variables._id_of_saved_game) + "/settings_game.txt", Settings._game)


func _on_continue_saved_game_Enabled_toggled(button_pressed):
	Settings._game.can_continue_saved_game = button_pressed
