"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

func _ready():
	Variables._at_scene = Enum.Scene.Settings_system
	Variables._scene_title = "Settings System."
	
	get_node("Container").set_follow_focus(true)		
	get_node("Container/Grid/Music").grab_focus()
	
	# set the pressed state of the buttons/spinboxes.
	if Settings._system.music == false:
		get_node("Container/Grid/Music").set_pressed(false)
	else:
		Common._music_play()
		
		
	if Settings._system.randomize_2d_maze == false:
		get_node("Container/Grid/Randomize2dMaze").set_pressed(false)
		get_node("Container/Grid/GridChild/GameSeedSpinbox").editable = true
		get_node("Container/Grid/GridChild/GameSeedSpinbox").value = Settings._system.seed_current
	else:
		if Variables._game_over == true:
			get_node("Container/Grid/GridChild/GameSeedSpinbox").editable = false
			
			# set the value of the spinbox to a random value then set the Settings._system.seed_current var to that value.
			get_node("Container/Grid/GridChild/GameSeedSpinbox").value = Common.get_random_number()
			Settings._system.seed_current = get_node("Container/Grid/GridChild/GameSeedSpinbox").value
		
	if Settings._system.sound == false:
		get_node("Container/Grid/Sound").set_pressed(false)
	else:
		_on_Sound_toggled(true)
		
	if Settings._system.ambient == false:
		get_node("Container/Grid/Ambient").set_pressed(false)
	else:
		_on_Ambient_toggled(true)
	
	if Settings._system.small_client_panel == false:
		get_node("Container/Grid/MiniClient").set_pressed(false)
		
	if Settings._system.hide_chat_features == true:
		get_node("Container/Grid/HideChatFeatures").set_pressed(true)
				
	if Settings._system.rune_guides == false:
		get_node("Container/Grid/RuneGuides").set_pressed(false)
		
	if Settings._system.automatic_rune_casting == true:
		get_node("Container/Grid/AutomaticRuneCasting").set_pressed(true)
	
	if Settings._system.use_large_tiles == false:
		get_node("Container/Grid/UseLargeTiles").set_pressed(false)
		
	if Settings._system.remove_extra_stone_walls == false:
		get_node("Container/Grid/RemoveExtraStoneWalls").set_pressed(false)

	if Settings._system.remove_level_border == true:
		get_node("Container/Grid/RemoveLevelBorder").set_pressed(true)
		
	hide_stone_wall()
	
	get_node("Container/Grid/GridChild3/PlayerStatsPanelSizeSpinbox").value = Settings._system.player_stats_panel_size
	

	get_node("Container/Grid/GridChild2/CorridorLengthSpinBox").value = Settings._system.corridor_length_between_rooms
	
	
func _process(_delta):
	if Variables._stop_settings_music == true || Variables._game_over == false:
		Variables._stop_settings_music = false
		
		Common._music_stop()
		return
	
		
func _input(event):	
	# this registers a keypress in case the user is at a spinbox and editing that spinbox value using the keyboard. The problem is that without this code, changing the value without pressing enter key would not save that new value when exiting that scene.
	if Variables._at_scene == Enum.Scene.Settings_system:
		Common._scancode_if_pressed_enter(event)
		
	
	# listen for ESC to exit app
	if(event.is_pressed()):
		if (event.is_action_pressed("ui_escape", true)):
			var _s = get_tree().change_scene("res://2d/source/scenes/main_menu.tscn")
		
			
func _on_MusicEnabled_toggled(button_pressed):
	Settings._system.music = button_pressed
	
	if button_pressed == false:
		Common._music_stop()
	else:
		Common._music_play()
	

func _on_randomize_2d_maze_Enabled_toggled(button_pressed):
	Settings._system.randomize_2d_maze = button_pressed
	get_node("Container/Grid/GridChild/GameSeedSpinbox").editable = !button_pressed
	
	if Settings._system.randomize_2d_maze == true:
		Settings._system.seed_current = Common.get_random_number()
		get_node("Container/Grid/GridChild/GameSeedSpinbox").value = Settings._system.seed_current


func _on_Sound_toggled(button_pressed):
	Settings._system.sound = button_pressed
	
	if button_pressed == true:
		$Sound.stream = load("res://audio/sound/click.ogg")
		$Sound.play()	


func _on_Ambient_toggled(button_pressed):
	Settings._system.ambient = button_pressed

	if button_pressed == true:
		$AmbientWind.stream = load("res://audio/ambient/wind.ogg")
		$AmbientWater.stream = load("res://audio/ambient/water.ogg")
		
		if $AmbientWind.playing == false || $AmbientWater.playing == false:
			randomize()
			
			# these random values after % are in seconds. this statement says to play either from the beginning of the sound to the track that is 175 seconds from the start. before adding the seconds value, determine if that sound have a length that long.
			$AmbientWind.play(randi() % 175)
			$AmbientWater.play(randi() % 33)
	
	else:
		$AmbientWind.stop()
		$AmbientWater.stop()


func _on_mini_client_Enabled_toggled(button_pressed):
	Settings._system.small_client_panel = button_pressed	
	

func _on_hide_chat_features_Enabled_toggled(button_pressed):
	Settings._system.hide_chat_features = button_pressed	
	
	
func _on_GameSeedSpinbox_value_changed(value):
	Settings._system.seed_current = value		
	
	
func _on_rune_guides_Enabled_toggled(button_pressed):
	Settings._system.rune_guides = button_pressed			
	

func _return_to_main_menu():
	var _s = get_tree().change_scene("res://2d/source/scenes/main_menu.tscn")


func _on_automatic_rune_casting_Enabled_toggled(button_pressed):
	Settings._system.automatic_rune_casting = button_pressed
	

func _on_hide_stone_walls_Enabled_toggled(button_pressed):
	Settings._system.hide_stone_walls = button_pressed
	hide_stone_wall()
	

# when stone walls toggle button is enabled, other settings need their values changed. for example, no need to toggle the "remove extra stone walls" feature when this feature is enabled.
func hide_stone_wall():
	if Settings._system.hide_stone_walls == true:
		get_node("Container/Grid/HideStoneWalls").set_pressed(true)
		
		get_node("Container/Grid/RemoveExtraStoneWalls").set_pressed(false)
		
		get_node("Container/Grid/RemoveExtraStoneWalls").disabled = true
		
		get_node("Container/Grid/RemoveLevelBorder").set_pressed(false)
		
		get_node("Container/Grid/RemoveLevelBorder").disabled = true
		
	else:	
		get_node("Container/Grid/RemoveExtraStoneWalls").disabled = false
		
		get_node("Container/Grid/RemoveLevelBorder").disabled = false	
	

func _on_remove_extra_stone_walls_Enabled_toggled(button_pressed):
	Settings._system.remove_extra_stone_walls = button_pressed
	

func _on_remove_level_border_Enabled_toggled(button_pressed):
	Settings._system.remove_level_border = button_pressed
	

func _on_use_large_tiles_Enabled_toggled(button_pressed):
	Settings._system.use_large_tiles = button_pressed
	

func _on_corridor_length_between_rooms_SpinBox_value_changed(button_pressed):
	Settings._system.corridor_length_between_rooms = button_pressed
	

func _on_player_stats_panel_size_Spinbox_value_changed(button_pressed):
	Settings._system.player_stats_panel_size = button_pressed
	

func _on_Node2D_tree_exiting():
	Filesystem.save("user://saved_data/settings_system.txt", Settings._system)
