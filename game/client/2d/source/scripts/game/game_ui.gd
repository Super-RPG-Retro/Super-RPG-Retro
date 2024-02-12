"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Control

class_name GameUI

var _show_tile_summary := true

# hold the walk sounds in an array.
var _walk_sounds := []
var _goodbye_mob_sounds := []
var _door_sounds := []
var _puzzle_sounds := []

# an array index of sounds.
var _walk_index = []

# the library. the 3d maze similar to lagacy of the ancients.
@onready var _3d_library = null
@onready var _3d_scene = preload("res://3d/scenes/game_ui.tscn")
# artifacts are needed to enter doors of the 3d maze.
@onready var _artifacts = null

# main 2d maze map where the player is at.
@onready var _2d_main_map = null

var _cursor := "WorldViewport/GameWorld/Player/Cursor"

# mini map of the main map. Located at bottom-right corner of screen.
@onready var _2d_mini_map = null

# this shows the coordinates and player level value at the top of screen.

# potions picked up. such as health, poison. if picking up a second potion, that potion's health will be added to the first potions total. so if picking up health and health heals for 10 turns then the next potion will add to that total. the amount to heal would be for 20 turns. each potion will expire after so many turns and each turn that player moves will have the effect of all potions at the potion panel
@onready var _hud = null

@onready var _potion_scene = null

# scene that shows the chat nodes.
@onready var _client = null
var _client_size = "MarginContainer/VBoxContainer/Client/Panel/VBoxContainer"

@onready var _player_controls = null

# panel at top-right corner of screen that shows the player's statitics, such as, health, gold and XP.
@onready var _player_stats = null

# the magic panel displayed just below the stats panel.
@onready var _magic_panel = null

@onready var _inventory_panel = null

# if enabled, after a rune has been casted.
@onready var _rune_casted_dialog = null

# displays the game over dialog.
@onready var _game_over_dialog = null
@onready var _game_over_dialog_scene = preload("res://2d/source/scenes/dialog/game_over.tscn")
# displays the save game dialog.
@onready var _save_game_dialog = null
@onready var _save_game_dialog_scene = preload("res://2d/source/scenes/dialog/save_game.tscn")

# hover the mouse overtop of the main map, will show tile information. right clicking a map tile will display an overview of that tile, such as the player's full stats or information of a wall,
@onready var _tile_summary = null
var _tile_image = "ScrollContainer/GridContainer/Label/TileImage"

# this event is triggered when pressing the escape button at game_world and when there are no nodes open, such as game help.
@onready var _escape_dialog = null

# display the battle scene if enabled.
@onready var _battle = null

var _display_overview := true


func _ready():
	Variables._at_scene = Enum.Scene.Game_UI
	Variables._compass = "N"
	
	if Settings._game.different_floor_tiles == true:
		Variables._floor_rooms_tile_value = Enum.Tile.Floor_rooms
	else:
		Variables._floor_rooms_tile_value = Enum.Tile.Floor
	
	Variables._rune_total = 0
	
	for key in Json._magic:
		Variables._rune_total += 1
	
	Variables._rune_total -= 1
	
	play_game_ui_music()
	
	if Settings._system.ambient == true:
		get_tree().call_group("game_audio", "play_ambient")
	
	Variables._wait_a_turn = 0
		
	add_scenes()
	
	Variables._game_over = false
	show_nodes()
		
	_walk_sounds = [Preload._walk_1, Preload._walk_2]
	
	_goodbye_mob_sounds = [Preload._goodbye_mob_1, Preload._goodbye_mob_2, Preload._goodbye_mob_3, Preload._goodbye_mob_4, Preload._goodbye_mob_5, Preload._goodbye_mob_6, Preload._goodbye_mob_7, Preload._goodbye_mob_8, Preload._goodbye_mob_9, Preload._goodbye_mob_10, Preload._goodbye_mob_11, Preload._goodbye_mob_12, Preload._goodbye_mob_13, Preload._goodbye_mob_14, Preload._goodbye_mob_15, Preload._goodbye_mob_16, Preload._goodbye_mob_17, Preload._goodbye_mob_18]
	
	_door_sounds = [Preload._door_open_0, Preload._door_open_1, Preload._door_open_2, Preload._door_open_3, Preload._door_open_4, Preload._door_open_5, Preload._door_open_6, Preload._door_open_7]
	
	_puzzle_sounds = [Preload._puzzle_block_move, Preload._puzzle_failed, Preload._puzzle_success]

	get_tree().call_group("tile_summary", "unit_text")
	

func _process(_delta):
	if Variables._game_over == true:
		if _game_over_dialog == null:
			_game_over_dialog = _game_over_dialog_scene.instantiate()
			add_child(_game_over_dialog)
			return

	# select a random walking sound.
	# do not put this code in "InputEventMouseMotion" or else there will be a null error.
	_walk_index = randi() % 2 
	var _walk = _walk_sounds[_walk_index]

	# return to main menu after clicking the ok button on the popup dialog.
	if Variables._trigger_escape_dialog == true:		 
		if _escape_dialog != null:
			remove_child(_escape_dialog)
			_escape_dialog = null
				
		elif _escape_dialog == null:
			_escape_dialog = Preload._escape_dialog_scene.instantiate()
			add_child(_escape_dialog)
		
		Variables._trigger_escape_dialog = false
		
	if Variables._rune_currently_selected == -1:
		_2d_main_map.get_node(_cursor).animation = "unit"
		
	# show or hide the cursor depending on the location of the mouse cursor
	if Variables.mouse_at_viewport == false or Variables._wait_a_turn == -1:
		_2d_main_map.get_node(_cursor).visible = false
		_2d_main_map.get_node(_cursor).animation = "unit"
		
		_2d_main_map.get_node("WorldViewport/GameWorld/Unit")._timer_object_coordinate.stop()
		
		_tile_summary.get_node("TileSummary").visible = false
		_tile_summary.get_node("MouseSummary").visible = false
	
	# place the clock here so that it is always running.
	Clock.cycle()
		

func _input(event):
	if event is InputEventScreenDrag or event is InputEventMouseButton:
		Variables._mouse_cursor_position.x = get_global_mouse_position().x
		Variables._mouse_cursor_position.y = get_global_mouse_position().y
	
	if Variables._trigger_commands == Enum.Trigger_commands.Game_help: 
		Variables._trigger_commands = null
		Variables._game_help.visible = true

	
func _gui_input(event):
	if Variables._game_over == true:
		return
	
	if Variables._at_library == false:
		tile_summary_input(event) 
	
	if event is InputEventMouseButton and event.double_click and event.button_index == MOUSE_BUTTON_LEFT and Variables._rune_currently_selected != -1:
		Variables._rune_currently_selected = -1
		
		_show_tile_summary = false
		
		# hide the rune casting locations.
		get_tree().call_group("rune_casting", "rune_position_hide")
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and Variables._rune_currently_selected != -1 and _2d_main_map.get_node(_cursor).animation == "unit":
		get_tree().call_group("rune_casting", "rune_position_show")
		
	# rune had just been casted. hide the guild at main map then minus 1 from rune total.
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and Variables._rune_currently_selected != -1 and _2d_main_map.get_node(_cursor).animation == "rune":
		get_tree().call_group("rune_casting", "rune_position_hide")
		
		Json._magic[Variables._rune_current_selected_name]["Stack_amount"] -= 1
		Variables._rune_currently_selected = -1
		
		get_tree().call_group("rune_casted", "cast_at_object_self")
		
		
	# listen for ESC to exit app
	if(event.is_pressed()):
		if(event.is_action_pressed("ui_escape", true)):
			Variables._trigger_escape_dialog = true	

			
	if Variables._trigger_commands == Enum.Trigger_commands.small_main_map_toggle_size: 
		Settings._system.small_main_map = !Settings._system.small_main_map
		resize_main_scene()		
		
		get_tree().call_group("client_events", "resize_item_list")
	
	elif Variables._trigger_commands == Enum.Trigger_commands.Unit_description and _show_tile_summary == true:
		get_tree().call_group("unit_description", "tile_overview")
	
	elif Variables._trigger_commands == Enum.Trigger_commands.Debug: 
		printerr(Variables._rune_current_selected_name + "\r\n" + "Rune Group: " + str(Variables._rune_current_group_selected) + "\r\n" + "Rune Number: " + str(Variables._rune_currently_selected) + "\r\n" + "Seed: " + str(Settings._system.seed_current) + "\r\n" + "Game time: " + Variables._time + "\r\n")

	if Variables._trigger_commands != Enum.Trigger_commands.Unit_description:
		Variables._trigger_commands = Enum.Trigger_commands.Nothing


func rune_dialog_display(_text, _title):
	_rune_casted_dialog.get_node("AcceptDialog").dialog_text = _text
	_rune_casted_dialog.get_node("AcceptDialog").title = _title.replace("_", " ")
	_rune_casted_dialog.get_node("AcceptDialog").visible = true

func scene_3d():
	if Variables._at_library == true:
		if _3d_library == null:
			_3d_library = _3d_scene.instantiate()
			add_child(_3d_library)
			
		_3d_library.visible = true
		
		Variables._compass = Variables._compass_last_known_for_3d
		
		_2d_main_map.visible = false
		_2d_mini_map.visible = false
		_tile_summary.visible = false
		_artifacts.visible = true
		_player_controls.visible = false
		
		play_library_music()
		
		
func play_library_music():
	if Settings._system.music == true:
		Common._music_play(Builder_playing._audio_music.file_name[6], 6, false)
		Variables._last_known_music_id = 6
			
func scene_2d():
	if _2d_main_map.visible == false:
		if _3d_library != null:
			_3d_library.visible = false	
				
		_2d_main_map.visible = true
		_2d_mini_map.visible = true
		_tile_summary.visible = true
		_artifacts.visible = false
		
		show_nodes()
		get_tree().call_group("game_ui", "play_game_ui_music")
		
				
# add instances of scenes to this scene.
func add_scenes():
	if Variables._at_library == false:	
		if _2d_main_map == null:
			_2d_main_map = get_node("2dMainMap")
		
		_2d_main_map.visible = true
		
		
	if Variables._at_library == true:
		_2d_main_map.visible = false
	
	
	if Variables._at_library == true:
		if _2d_main_map != null:
			_2d_main_map.visible = false
	
	
	if _hud == null:	
		_hud = get_node("Hud")
	_hud.visible = true
	
	
	if _potion_scene == null:	
		_potion_scene = get_node("PotionScene")
	_potion_scene.visible = true
	
	
	if _client == null:
		_client =  get_node("ClientScene")
	_client.visible = true

		
	if _player_controls == null:
		_player_controls = get_node("PlayerControls")
	_player_controls.visible = true
	
	
	if _2d_mini_map == null:
		_2d_mini_map = _2d_main_map.duplicate(15)
		add_child(_2d_mini_map)
		
		
		_2d_mini_map.set_position(Vector2( 672, 424 ))
		_2d_mini_map.set_size(Vector2( 173, 72 ))
		_2d_mini_map.get_node("WorldViewport").set_size(Vector2( 344, 168 ))
		_2d_mini_map.get_node("WorldViewport/GameWorld/Player/Camera2D").set_zoom(Vector2( 0.25, 0.25 ))
		
	
	resize_main_scene()

	
	if _artifacts == null:
		_artifacts = get_node("ArtifactsScene")
	_artifacts.visible = true
		
	
	if Variables._at_library == false:
		if _artifacts != null:
			_artifacts.visible = false
	
			
	if _player_stats == null:
		_player_stats = get_node("PlayerStatsPanel")
	_player_stats.visible = true
		
	
	if _magic_panel == null:
		_magic_panel = get_node("MagicPanel")
	
	_magic_panel.visible = true


	if _inventory_panel == null:
		_inventory_panel = get_node("InventoryPanel")

	_inventory_panel.visible = true

		
	if _tile_summary == null:
		_tile_summary = get_node("TileSummary")
	
	_tile_summary.visible = true

		
	if Variables._at_library == true:
		if _tile_summary != null:
			_tile_summary.visible = false
		
		
	if Variables._game_help == null:
		Variables._game_help = get_node("GameHelpScene")
		Variables._game_help.visible = false
	
		
	if Variables._at_library == true:
		if Variables._game_help != null:
			Variables._game_help.visible = false

	
	if Variables._rune_help == null:
		Variables._rune_help = get_node("RuneHelpScene")
		Variables._rune_help.visible = false
		
	
	if Variables._rune_buying == null:
		Variables._rune_buying = get_node("RuneBuyingScene")
		Variables._rune_buying.visible = false
	
	
	if _rune_casted_dialog == null:
		_rune_casted_dialog = get_node("RuneCastedDialog")
		_rune_casted_dialog.visible = false

	
	if _battle == null:
		_battle = get_node("BattleScene")
		_battle.visible = false
		
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Settings._system.start_3d == true:
		scene_3d()
	else:
		scene_2d()

func save_game():
	if _save_game_dialog != null:
		remove_child(_save_game_dialog)
	
	_save_game_dialog = _save_game_dialog_scene.instantiate()
	add_child(_save_game_dialog)	
		
	_save_game_dialog.get_node("ConfirmationDialog").visible = true
	
	
# main scene is small_main_map, show_player_controls and show_client_panel.
func resize_main_scene():
	# set main map's height full to scene if both navigation and client panel are disabled.
	if Settings._system.show_player_controls == false and Settings._system.show_client_panel == false or Settings._system.small_main_map == false and Settings._system.show_player_controls == false and Settings._system.show_client_panel == false:
		_2d_main_map.get_node(".").size.y = 352 + 200
		_2d_main_map.get_node("WorldViewport").size.y = 352 + 200
		
		_player_controls.visible = false
		_client.visible = false
	
	else:
		# if only show_player_controls is false.
		if Settings._system.small_main_map == true and Settings._system.show_player_controls == false and Settings._system.show_client_panel == true:
			_2d_main_map.get_node(".").size.y = 352 - 64
			_2d_main_map.get_node("WorldViewport").size.y = 352 - 64
		
			_client.get_node("MarginContainer/VBoxContainer/Client/Panel").position.y = - 128
			_client.get_node("MarginContainer/VBoxContainer/Client/Panel/VBoxContainer/HBoxContainer").custom_minimum_size.y = 103 + 128
			
			_player_controls.visible = false
		
		# if only show_player_controls is true. small_main_map feature is ignored when this is true.
		elif Settings._system.show_player_controls == true and Settings._system.show_client_panel == false:
			_2d_main_map.get_node(".").size.y = 352 + 132
			_2d_main_map.get_node("WorldViewport").size.y = 352 + 132
		
			_player_controls.get_node(".").position.y = 132
			_client.visible = false
			
		
		# if only show_client_panel is true.
		elif Settings._system.small_main_map == false and Settings._system.show_player_controls == false and Settings._system.show_client_panel == true:
			_client.get_node("MarginContainer/VBoxContainer/Client/Panel").position.y = - 64
			_client.get_node("MarginContainer/VBoxContainer/Client/Panel/VBoxContainer/HBoxContainer").custom_minimum_size.y = 103 + 64
			
			_player_controls.visible = false
	
	Filesystem.save("user://saved_data/" + str(Variables._id_of_saved_game) + "/settings_game.txt", Settings._game)
	
	
func hide_cursor():
	if Variables._at_library == true:
		return
	
	_2d_main_map.get_node(_cursor).visible = false
	
	
func show_nodes():	
	_magic_panel.get_node("Runes/BG").visible = true
	_magic_panel.get_node("Runes/RuneBGoverlay").visible = true
	_magic_panel.get_node("Runes/Title").visible = true
	
	_inventory_panel.get_node("Inventory/BG").visible = true
	_inventory_panel.get_node("Inventory/InventoryBGoverlay").visible = true
	_inventory_panel.get_node("Inventory/Title").visible = true


# player stands still but everything else is active for 1 game turn when this func is called.
func wait_turn():
	get_tree().call_group("game_world", "try_move", 0, 0)

# this func closes the overview node when the mouse is clicked and hides both the tile text and mouse summary when the tile overview is shown.
func tile_summary_input(event):
	# play a sound if at the main map.
	if event is InputEventMouseButton and _2d_main_map.get_node(_cursor).visible == true and _2d_main_map.get_node(_cursor).animation == "unit":
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Variables._bypass_wait_a_turn == false:
			if Settings._system.sound == true:
				$Audio/SoundClick.play()
	
	# play a sound after selecting a spell when casting it at the main map.
	elif event is InputEventMouseButton and _2d_main_map.get_node(_cursor).visible == true and _2d_main_map.get_node(_cursor).animation == "rune":
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Variables._bypass_wait_a_turn == false:
			if Settings._system.sound == true:
				$Audio/SoundClick.play()
			
			get_tree().call_group("rune_casting", "create_rune_casting_units")
	
		
	# do a wait turn or do action at puzzle block if at that tile.	
	if event.is_action_pressed("ui_z_key", true) and Variables._bypass_wait_a_turn == false:
		get_tree().call_group("move", "process_puzzle_blocks") 
		get_tree().call_group("move", "process_icons") 
			
	# do a wait turn or do action at puzzle block if at that tile.
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and Variables._bypass_wait_a_turn == false and Variables._mouse_cursor_position.x <= 657:
		Variables._wait_a_turn = 1
		get_tree().call_group("client", "_on_TimerGameTurn_timeout") 
			
	# go to the tile overview panel if double click mouse button was clicked.	
	elif event is InputEventMouseButton and event.double_click and event.button_index == MOUSE_BUTTON_LEFT and Variables._rune_currently_selected == -1 and _display_overview == true:
		_2d_main_map.get_node("WorldViewport/GameWorld/Unit")._timer_object_coordinate.stop()
		_2d_main_map.get_node(_cursor).visible = false
			
		if _show_tile_summary == true:
			hide_tile_summary()
			Variables._trigger_commands = Enum.Trigger_commands.Unit_description
			
		
	if Variables._keyboard_tab_pressed == false:
		Variables._bypass_wait_a_turn = false
		
	else:
		Variables._bypass_wait_a_turn = true
		Variables._wait_a_turn = -2

	_display_overview = true
	
	if event is InputEventMouseMotion:
		Variables._wait_a_turn = -2
		hide_tile_summary()
		
		# the display of the Cursor, UnitText and MouseSummary nodes. 	
		if Variables._at_library == false and Variables.mouse_at_viewport == true:
			call_deferred("cursor")
	
	# if tile overview panel is displayed, close it after a right mouse button is clicked.
	if (event.is_pressed()):
		if event.is_action_pressed("ui_escape", true):
			if Variables._trigger_commands == Enum.Trigger_commands.Unit_description:
				# clear event scancode, so elsewhere the keypress will not trigger.
				if event.is_action_pressed("ui_escape", true):
					event.keycode = 0

				tile_summary_overview()
					
	# hide the mouse cursor, if the overview panel is displayed.
	if _tile_summary != null:
		if _tile_summary.get_node("ScrollContainer/GridContainer").visible == true:
			_2d_main_map.get_node(_cursor).visible = false

	_show_tile_summary = true
	

func tile_summary_overview():
	get_tree().call_group("game_world", "unit_description")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "tile_summary", "unit_text_clear")
					
	Variables._trigger_commands = Enum.Trigger_commands.Nothing
	_display_overview = false
	
	_tile_summary.get_node("ScrollContainer").visible = false
	_tile_summary.get_node("SceneHeader").visible = false
	
	_tile_summary.get_node("ScrollContainer/GridContainer/Label").text = ""


func cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# the name of the tile displayed at main map.
	_tile_summary.get_node("TileSummary").visible = true
	_2d_main_map.get_node(_cursor).visible = true
	
	if Variables._rune_currently_selected != -1:
		_2d_main_map.get_node(_cursor).animation = "rune"
			
	if Variables._at_library == false:
		get_tree().call_group("game_world", "unit_description")
		

# change the image of the object. tiles.gd calls this func.
# _texture: 		the object's texture, sprite image.
# _is_player:	is this object a player or a mob?
func mouse_command_image(_texture, _is_player: bool):
	if _is_player == true:
		if PC._number == 0:
			_tile_summary.get_node(_tile_image).hframes = 3
		else:
			_tile_summary.get_node(_tile_image).hframes = 1
		
	else:
		_tile_summary.get_node(_tile_image).hframes = 1	
	
	_tile_summary.get_node(_tile_image).texture = _texture

func hide_tile_summary():
	_2d_main_map.get_node("WorldViewport/GameWorld/Unit")._timer_object_coordinate.stop()
	
	_tile_summary.get_node("MouseSummary").visible = false
	
			
func _music_stop():
	Common._music_stop()


# play the music when entering this scene. music is looped.
func play_game_ui_music():
	if Settings._system.music == true:
		Common._music_play(Builder_playing._audio_music.file_name[1], 1, false)
			

# clean memory. user is either quitting to windows or returning to main menu.	
func _on_main_tree_exiting():
	call_deferred("remove_child", _3d_library)
	call_deferred("remove_child", _2d_main_map)
	call_deferred("remove_child", _client)
	call_deferred("remove_child", _player_controls)
	call_deferred("remove_child", _2d_mini_map)
	call_deferred("remove_child", _player_stats)
	call_deferred("remove_child", _magic_panel)
	call_deferred("remove_child", _inventory_panel)
	call_deferred("remove_child", Variables._game_help)
	call_deferred("remove_child", Variables)
	call_deferred("remove_child", Json)

	call_deferred("queue_free", _3d_library)
	call_deferred("queue_free", _2d_main_map)
	call_deferred("queue_free", _client)
	call_deferred("queue_free", _player_controls)
	call_deferred("queue_free", _2d_mini_map)
	call_deferred("queue_free", _player_stats)
	call_deferred("queue_free", _magic_panel)
	call_deferred("queue_free", _inventory_panel)
	call_deferred("queue_free", Variables._game_help)
	call_deferred("queue_free", Variables)
	call_deferred("queue_free", Json)

	queue_free()


