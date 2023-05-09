"""
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# vars are placed here when they cannot be placed in amy other singleton. they are used game wide, simular to triggers.
extends Node

# stops player from moving when player first enters the library.
var _player_stop_moving:bool = true

# camera rotation.
var _player_target_rotation = 0

# simulate a keyboard key press. used to register the value in a spinbox.
var a = InputEventKey.new()

# how many game turns these items will be in effect. this var is set at potion_impair_vision()
var _potion_impair_vision_turns = 0
var _potion_healing_turns = 0
var _potion_poison_turns = 0
var _potion_mana_turns = 0

# this is used at game help to play the correct music.
var _last_known_music_id = 0

# music are played at these scenes.
var _music_scenes = {
	"0": "Main menu.",
	"1": "Dungeon crawl.",
	"2": "Store.",
	"3": "Battle.",
	"4": "Battle ended.",
	"5": "Builder.",
	"6": "Library.",
	"7": "Game help.",
	"8": "puzzle room.",
}

# this dictionary is used has a selectable list at builder and used at scenes to load then play the music.
var _music = {
	"0": "ballad.ogg",
	"1": "bassoons-and-harpsichord.ogg",
	"2": "double-trios.ogg",
	"3": "harpsichord-piece.ogg",
	"4": "Lute-and-recorder-ballad.ogg",
	"5": "minstrel-dance.ogg",
	"6": "minuet-like-mozart.ogg",
	"7": "plainchant-recorder-trio.ogg",
	"8": "wind-trio.ogg",
	"9": "medieval-quest.ogg",
	"10": "dragon-quest.ogg",
	"11": "dragon-slayer.ogg",
	"12": "fair-camelot.ogg",
	"13": "into-battle.ogg",
	"14": "game-music2.mid",
}

# stats name.
var s:Dictionary = {
	"0": "Charisma",
	"1": "Constitution",
	"2": "Defense",
	"3": "Dexterity",
	"4": "Intelligence",
	"5": "Luck",
	"6": "Perception",
	"7": "Strength",
	"8": "Willpower",
	"9": "Wisdom",
}

# stats description.
var s_desc:Dictionary = {
	"0": "Charisma aka Presence, Charm, Social.",
	"1": "Constitution aka Stamina, Endurance, Vitality, Recovery.",
	"2": "Defense aka Resistance, Fortitude, Resilience.",
	"3": "Dexterity aka Agility, Reflexes, Quickness.",
	"4": "Intelligence aka Intellect, Mind, Knowledge.",
	"5": "Luck aka Fate, Chance.",
	"6": "Perception aka Alertness, Awareness, Cautiousness.",
	"7": "Strength aka Body, Might, Brawn, Power.",
	"8": "Willpower aka Sanity, Personality, Ego, Resolve.",
	"9": "Wisdom aka Spirit, Wits, Psyche, Sense.",
}

# this is the max value of the game id's at main menu SpidBox node.
var _game_id_max_value = 99

# this var does not get reset back to -1. it is used to save the pressed state of the checkbox to builder.
var _num_first_rune_selected = -1

# this holds the current index number of the item list.
var _item_list_current_index = 0
var _item_list_current_scroll_value = 0

# if this var is true, a request to reset level was made and this var is then used to place the player at the same position player was at before the magic was casted.
var _reset_player:bool = false
var _reset_player_position: Vector2

# what type is the node? is it player, mobs, item, floor...
var _type = []

# the name of the node.
var _name = []

# this is for the high_score scene. the first element is the player position at the high score table, followed by the name of the player, the score the player had and how many move turns made in that game.
var _high_score_names = 	["Bob", "Stan", "Sam", "", "", "", "", "", "", ""]
var _high_score_scores = 	[30, 20, 10, 0, 0, 0, 0, 0, 0, 0]
var _high_score_turns = 	[20, 40, 50, 0, 0, 0, 0, 0, 0, 0]

var camera = null
var _block_id:int = -1
var _block_id_old:int = -1

# this is the values of all puzzle blocks in the puzzle room.
onready var _puzzle_room_block_values:Array = [
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]

var select_json_dictionary_singly:bool = false

# if true then game is being played in build mode without godot. if false then game is loaded by pressing the arrow button at godot app.
var _is_build_mode:bool = false

# set this value no greater than 8. this is the number of games that can be created at builder. data/images dirs at builder_data dir will be created until this number is reached. see builder_data where project.godot file is located at file explorer. games total is minus 1 from this value. so at builder, you can change which game you want to edit.
# remember to add "&& directory.dir_exists(Variables._project_path + "/builder/objects/data/#") to the booy_splash_progress_bar .gd file at func _ready, where # is the value, if you change this value. if changing this value to 5 then there needs to be 5 condition checks at func _ready. also change GameIDspinbox node at prject.home.gd file
var _total_builder_data_directories = 1

# this is the path to the root of project. path does not start with res:// but instead the hard drive letter that the project is located at. path does not end with a slash.
var _project_path:String = ""

# this is the extra padding after the text of a menu item.
var _menu_padding: String = "                "

# display the rune help scene, displaying the selected rune.
var _rune_help = null
var _rune_buying = null
var _rune_total = 0

# name of the rune currently selected when clicking the rune.
var _rune_current_selected_name = ""
var _inventory_current_selected_name = ""

# at the magic_panel scene, this is the number of the rune currently selected. a value of - 1 means no runes are selected.
var _rune_currently_selected = - 1
var _inventory_currently_selected = - 1

# this is the current group selected. if "Self" is the current group and "/r+" is the next command at client panel, then "Attack" will be the current selected group.
var _rune_current_group_selected = 1
var _inventory_current_group_selected = 1

# how many different groups are there in runes. currently three. self, attack and support.
var _rune_group_total = 3
var _inventory_group_total = 3

# this is true when player dies. Used to stop mobs to player damage and used to display the game over dialog.
var _game_over: bool = true

# true if going down a dungeon level.
var _going_down_level = true

# This is the location of the down ladder at the current floor where the player is located,
var _ladder_down = Vector2(0, 0)

# a value of 1 means the dungeon is the first dungeon. a value of 2 means second dungeon.
var _dungeon_number: int = 0

# there are 99 levels in a dungeon.
var _level_number = 0

# Player will stand still but everything else can be in an active state for the amount of turns set in this var. max 1000 turns. "/w5" refers to 5 turns. If the player is next to a mob that moves, the mob will move 5 turns then stop.
var _wait_a_turn: int = 0

# used to jump to the command scene.
var _trigger_commands = null

# this is a list of keys that can be used while playing the game.
var _game_help = null

# this is the tile number. The number before the comma is the x coords.
var _dungeon_coordinates = "0,0"

# location starts at n for north.
var _compass = "N"

# This var is set when player enters the 2d dungeon from 3d.
var _compass_last_known_for_3d = "N"
var _compass_update = true

# at boot splash if this var is false then the image will not be displayed. this avoids a crash where the directory might not exist,
var _is_directory_ok:bool = false

# when the play button is clicked, this var is set to true so that at the settings scene, the music can stop playing.
var _stop_settings_music: bool = false

# this is used to toggle the focus of the _input_client
var _keyboard_tab_pressed: bool = false

# is child scene open? When a child scene is open, this var needs to be set to true. it is set to false when child scene closes. The reason is because without this var, pressing the ESC key will close program instead of child scene.
var _child_scene_open: bool = false;

# when true the listen button will be triggered.
var _trigger_listen_button: bool = false;

# after the enum Builder_dictionary is set to this var, a match statement is used with this var to determibe if for example, mobs code or weapon code should be outputted,
var _dictionary_name: String = ""
var _dictionary_index: int = 0

# main map's mouse cursor position.
var _mouse_cursor_position = Vector2(0, 0)

# this is the id refers to the saved panel.
var _id_of_saved_game: int = 0

# if this value does not equal Variables._id_of_saved_game, the stats total will be updated.
var _id_of_saved_game_temp:int = -1

var _is_saved_id_panel_visible:bool = false

# this is the last saved game id. this var will be used to load that data from file.
var _id_of_loaded_game: int = 0
var _id_of_loaded_game_temp:int = -1
var _is_loaded_id_panel_visible:bool = false

# this var is used to determine if the current game data should delete the Saved ID visibility map data. If this var is true then all data from Saved ID will be deleted prior to saving it, or if the data should overwrite only the stats.
var _is_this_new_data:bool = true


# the time displayed in hours, minutes and seconds.
var _time: = ""

# this is used to change between library and dungeon while _config.start_3d sets this value when game loads.
var _at_library = false

# is the client connected to server (host)
var _host_is_connected = false

# parent scene called this child scene. when clicking the top-right corner "x" of this scene, data is processed then sent back to the parent node. this var is used with Enum.Select_items to determine which data to send back.
var select_items_data_to_return:int = 0

# the value of Enum.Scene is assigned to this var. When closing the child header, which is shared by many scene, using the mouse we can jump to the correct code by using this var.
var _at_scene: int = 0

# if true, code using this var can ignore a wait_a_turn.
var _bypass_wait_a_turn = false

# when this var reaches 0, the invisible rune will not have an effect on player.
var _rune_invisible_turns = 0

# when this var reaches 0, the haste rune will be all used. mobs will then walk normally.
var _rune_haste_turns = 0

# is a strong or regular haste rune casted and still in effect.
var _is_haste_enabled = false

# if true then it is day, else it is night. this changes the direction of the _time_day_raw_value and _time_night_raw_value, for example, instead of adding 0.001 to a value, it will be minused.
var _time_is_day: bool = true
var _hour = 0

# this is the title text at top left of scene.
var _scene_title = ""

# when the escape key is pressed, this var will trigger the event to display the dialog.
var _trigger_escape_dialog: bool = false

# if different_floor_tiles var is true, corridor will use floor tile and rooms will use floor_rooms. when different_floor_tiles is false, both corridor and rooms will use floor tile. therefore, this value will either be 2 for floor or 7 for floor_rooms. note that if changing the id of these tiles at timemap (no need to do so) then these values will need to be changed. values are set to this var at game_ui ready() func.
var _floor_rooms_tile_value: int = 0

# when searching for json files at the Filesystem._rename_file_or_directory func, the directories are scanned and all filenames from those directories are populated into these vars. these vars are then used to display the json data in the form of a dictionaries and then the Variables._file_names is used to grab the sprite textures.
# get all files within path and including all files within subfolders.
var _file_paths = []

# directory just inside of builder_data, such as, gold, weapon.
var _sub_folder: = ""

# this dupicates the _file_paths and then uses the replaced command to change the data into png code. eg, .json to .php.
var _image_textures = []
# used by json sort button.
var _image_textures_sorted = []
# used to set _image_textures back to the state it was before entering the scene. this is needed because after using the sort button, the _image_textures changes its values and the next sort would not give a correct result without this var.
var _image_textures_default = []

# name of the file found at Filesystem.get_dir_files(). that func stores data into the Variables._file_paths and Variables._image_textures and then this var takes a short version name of the Variables._file_paths path so that geting the dictionary from that data is possible.

# remember that the file_names var has part of the folder as that name, so rat is really animals/rat. the reason is so we know where that filename is stored at.
var _file_names = []
var _file_names_sorted = []
var _file_names_default = []

# this is used to change the state of the CheckButton at a builder scene.
var _event_id = [] # 0: not selected. 1: selected.

# hard drive directory names.
var _folder_names = []

# dont edit this value. this var is populated at game scene. it is used in a loop to set other vars.
var enemy_total_in_game


func _ready():
	# if true then app is running in normal mode. clicked the button at top right corner of godot console.
	_project_path = ProjectSettings.globalize_path("res://").get_base_dir()
	Variables._is_build_mode = false

	# else, app is running in build mode. we built the game in release mode or debug mode then ran the exe file.
	if _project_path == "":
		_project_path = OS.get_executable_path().get_base_dir()
		Variables._is_build_mode = true

	_project_path += "/bundles"


func clear_null():
	_trigger_commands = null
	_game_help = null
	_rune_help = null
	_rune_buying = null

func reset_vars():
	clear_null()

	_rune_total = 0
	_rune_current_selected_name = ""
	_rune_currently_selected = -1
	_rune_current_group_selected = 1
	_rune_group_total = 3

	_inventory_current_selected_name = ""
	_inventory_currently_selected = -1
	_inventory_current_group_selected = 1
	_inventory_group_total = 3

	_game_over = true
	_going_down_level = true
	_ladder_down = Vector2(0, 0)
	#_dungeon_coordinates = "0,0" # reset at main menu.
	#_compass = "N" # reset at main menu.
	#_compass_last_known_for_3d = "N" # reset at main menu.
	#_compass_update = true # reset at main menu.
	#_dungeon_number = 0 # reset at main menu.
	_wait_a_turn = 0
	_stop_settings_music = false
	_keyboard_tab_pressed = false
	_child_scene_open = false;
	_trigger_listen_button = false
	_mouse_cursor_position = Vector2(0, 0)
	#_id_of_loaded_game = 1 # reset at boot splash.
	_time = ""
	_at_library = false
	#_host_is_connected = false # reset at main menu.
	_bypass_wait_a_turn = false
	_rune_invisible_turns = 0
	_rune_haste_turns = 0
	_is_haste_enabled = false
	_time_is_day = true
	_hour = 0
	_trigger_escape_dialog = false
	_floor_rooms_tile_value = 0
	_dictionary_name = ""

