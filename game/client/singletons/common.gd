"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# shared functions.

extends Node

# this is all the rows from the selected ItemList.
var _d_rows = []
var _append: bool = true

var player = null


func _process(_delta):
	clamp_p_vars()
	clamp_p_vars_saved()
	

# sort the data and return it.
func _sort(_dictionary, _d_column, _item_list_current_index = 0):
	var _i = -1	
	_d_rows.clear()
	
	if Variables._file_names.size() > 0:
		if _item_list_current_index == 0:
			for _key in _dictionary.keys():
				_i += 1
										
				if _i < Variables._file_names.size():
					var _file_name = Variables._file_names[_i].split("/")
					
					_d_rows.append([_i, _file_name[1]])
					
					
			#_d_rows = Variables._file_names.duplicate()
		
		if _item_list_current_index == 1:
			_d_rows = Variables._file_names.duplicate()
			_d_rows.sort_custom(MyCustomSorter, "sort_ascending")
			
		else:
			for _key in _dictionary.keys():
				_i += 1
				
				if _i < Variables._file_names.size(): 
					_d_rows.append([_i, _dictionary[_key][_d_column]])
						
			_d_rows.sort_custom(MyCustomSorter, "sort_ascending")
		
			for _r in _d_rows:
				Variables._file_names_sorted.append( Variables._file_names[_r[0]])
				
				Variables._image_textures_sorted.append(Variables._image_textures[_r[0]])
				
			Variables._file_names = Variables._file_names_sorted.duplicate()
			Variables._image_textures = Variables._image_textures_sorted.duplicate()
				
	else:
		for _key in _dictionary.keys():
			_i += 1
			
			if _i < Json._magic.size(): 
				_d_rows.append([_i, _dictionary[_key][_d_column]])
		
		_d_rows.sort_custom(MyCustomSorter, "sort_ascending")
		
		
	return _d_rows
	

class MyCustomSorter:
	static func sort_ascending(a, b):
		if a[1] < b[1]:
			return true
		return false


func _game_title():
	if Builder._config.game_id > 0:
		OS.set_window_title("Super RPG Retro: " +  Builder._config.game_title[Builder._config.game_id])
	else:
		OS.set_window_title("Super RPG Retro.")


func _update_stats_last_player(_i):
	P.character_stats[str(_i)]["_loaded"].HP = P._hp
	P.character_stats[str(_i)]["_loaded"].HP_max = P._hp_max
	
	P.character_stats[str(_i)]["_loaded"].MP = P._mp
	P.character_stats[str(_i)]["_loaded"].MP_max = P._mp_max
	
	P.character_stats[str(_i)]["_loaded"].XP = P._xp
	P.character_stats[str(_i)]["_loaded"].XP_next = P._xp_next
	
	P.character_stats[str(_i)]["_loaded"].Charisma = P._cha
	P.character_stats[str(_i)]["_loaded"].Constitution = P._con
	P.character_stats[str(_i)]["_loaded"].Defense = P._def
	P.character_stats[str(_i)]["_loaded"].Dexterity = P._dex
	P.character_stats[str(_i)]["_loaded"].Intelligence = P._int
	P.character_stats[str(_i)]["_loaded"].Luck = P._luc
	P.character_stats[str(_i)]["_loaded"].Perception = P._per
	P.character_stats[str(_i)]["_loaded"].Strength = P._str
	P.character_stats[str(_i)]["_loaded"].Willpower = P._wil
	P.character_stats[str(_i)]["_loaded"].Wisdom = P._wis


func _init_stats_player_characters():
	for _i in range (6):
		P._hp = P.character_stats[str(_i)]["_loaded"].HP
		P._hp_max = P.character_stats[str(_i)]["_loaded"].HP_max
		
		P._mp = P.character_stats[str(_i)]["_loaded"].MP
		P._mp_max = P.character_stats[str(_i)]["_loaded"].MP_max
		
		P._xp = P.character_stats[str(_i)]["_loaded"].XP
		P._xp_next = P.character_stats[str(_i)]["_loaded"].XP_next
		
		P._cha = P.character_stats[str(_i)]["_loaded"].Charisma
		P._con = P.character_stats[str(_i)]["_loaded"].Constitution
		P._def = P.character_stats[str(_i)]["_loaded"].Defense
		P._dex = P.character_stats[str(_i)]["_loaded"].Dexterity
		P._int = P.character_stats[str(_i)]["_loaded"].Intelligence
		P._luc = P.character_stats[str(_i)]["_loaded"].Luck
		P._per = P.character_stats[str(_i)]["_loaded"].Perception
		P._str = P.character_stats[str(_i)]["_loaded"].Strength
		P._wil = P.character_stats[str(_i)]["_loaded"].Willpower
		P._wis = P.character_stats[str(_i)]["_loaded"].Wisdom

	_update_stats_player_characters(0)
	
	
func _update_stats_player_characters(_i):
	P._hp = P.character_stats[str(_i)]["_loaded"].HP				
	P._hp_max = P.character_stats[str(_i)]["_loaded"].HP_max
	
	P._mp = P.character_stats[str(_i)]["_loaded"].MP	
	P._mp_max = P.character_stats[str(_i)]["_loaded"].MP_max
	
	P._xp = P.character_stats[str(_i)]["_loaded"].XP	
	P._xp_next = P.character_stats[str(_i)]["_loaded"].XP_next
	
	P._cha = P.character_stats[str(_i)]["_loaded"].Charisma
	P._con = P.character_stats[str(_i)]["_loaded"].Constitution
	P._def = P.character_stats[str(_i)]["_loaded"].Defense
	P._dex = P.character_stats[str(_i)]["_loaded"].Dexterity
	P._int = P.character_stats[str(_i)]["_loaded"].Intelligence
	P._luc = P.character_stats[str(_i)]["_loaded"].Luck
	P._per = P.character_stats[str(_i)]["_loaded"].Perception
	P._str = P.character_stats[str(_i)]["_loaded"].Strength
	P._wil = P.character_stats[str(_i)]["_loaded"].Willpower
	P._wis = P.character_stats[str(_i)]["_loaded"].Wisdom


# Clamps value: returns a value not less than min and not more than max.
func clamp_p_vars():
	P._hp = clamp(P._hp, 0, 9999)
	P.character_stats[str(P._number)]["_loaded"].HP = clamp(P.character_stats[str(P._number)]["_loaded"].HP, 0, 9999)	
	P._hp_max = clamp(P._hp_max, 0, 9999)
	P.character_stats[str(P._number)]["_loaded"].HP_max = clamp(P.character_stats[str(P._number)]["_loaded"].HP_max, 0, 9999)
	
	P._mp = clamp(P._mp, 0, 9999)
	P.character_stats[str(P._number)]["_loaded"].MP = clamp(P.character_stats[str(P._number)]["_loaded"].MP, 0, 9999)
	P._mp_max = clamp(P._mp_max, 0, 9999)
	P.character_stats[str(P._number)]["_loaded"].MP_max = clamp(P.character_stats[str(P._number)]["_loaded"].MP_max, 0, 9999)
	
	P._xp = clamp(P._xp, 0, 99999999999999)	
	P.character_stats[str(P._number)]["_loaded"].XP = clamp(P.character_stats[str(P._number)]["_loaded"].XP, 0, 99999999999999)
	
	P._xp_next = clamp(P._xp_next, 0, 99999999999999)
	P.character_stats[str(P._number)]["_loaded"].XP_next = clamp(P.character_stats[str(P._number)]["_loaded"].XP_next, 0, 99999999999999)
	
	Hud._loaded.Gold = clamp(Hud._loaded.Gold, 0, 9999999999)
	
	Hud._loaded.Score = clamp(Hud._loaded.Score, 0, 9999999999)
	
	Hud._loaded.Turns = clamp(Hud._loaded.Turns, 0, 99999999999999)
			
	P._cha = clamp(P._cha, 0, 999)
	P.character_stats[str(P._number)]["_loaded"].Charisma = clamp(P.character_stats[str(P._number)]["_loaded"].Charisma, 0, 999)
	
	P._con = clamp(P._con, 0, 999)
	P.character_stats[str(P._number)]["_loaded"].Constitution = clamp(P.character_stats[str(P._number)]["_loaded"].Constitution, 0, 999)
	
	P._def = clamp(P._def, 0, 999)
	P.character_stats[str(P._number)]["_loaded"].Defense = clamp(P.character_stats[str(P._number)]["_loaded"].Defense, 0, 999)
		
	P._dex = clamp(P._dex, 0, 999)
	P.character_stats[str(P._number)]["_loaded"].Dexterity = clamp(P.character_stats[str(P._number)]["_loaded"].Dexterity, 0, 999)
			
	P._int = clamp(P._int, 0, 999)
	P.character_stats[str(P._number)]["_loaded"].Intelligence = clamp(P.character_stats[str(P._number)]["_loaded"].Intelligence, 0, 999)
			
	P._luc = clamp(P._luc, 0, 999)
	P.character_stats[str(P._number)]["_loaded"].Luck = clamp(P.character_stats[str(P._number)]["_loaded"].Luck, 0, 999)
			
	P._per = clamp(P._per, 0, 999)
	P.character_stats[str(P._number)]["_loaded"].Perception = clamp(P.character_stats[str(P._number)]["_loaded"].Perception, 0, 999)
	
	P._str = clamp(P._str, 0, 999)
	P.character_stats[str(P._number)]["_loaded"].Strength = clamp(P.character_stats[str(P._number)]["_loaded"].Strength, 0, 999)
			
	P._wil = clamp(P._wil, 0, 999)
	P.character_stats[str(P._number)]["_loaded"].Willpower = clamp(P.character_stats[str(P._number)]["_loaded"].Willpower, 0, 999)
	
	P._wis = clamp(P._wis, 0, 999)
	P.character_stats[str(P._number)]["_loaded"].Wisdom = clamp(P.character_stats[str(P._number)]["_loaded"].Wisdom, 0, 999)
	

func clamp_p_vars_saved():
	P.character_stats[str(P._number)]["_saved"].HP = clamp(P.character_stats[str(P._number)]["_saved"].HP, 0, 9999)
	
	P.character_stats[str(P._number)]["_saved"].HP_max = clamp(P.character_stats[str(P._number)]["_saved"].HP_max, 0, 9999)
	
	P.character_stats[str(P._number)]["_saved"].MP = clamp(P.character_stats[str(P._number)]["_saved"].MP, 0, 9999)
	
	P.character_stats[str(P._number)]["_saved"].MP_max = clamp(P.character_stats[str(P._number)]["_saved"].MP_max, 0, 9999)
		
	P.character_stats[str(P._number)]["_saved"].XP = clamp(P.character_stats[str(P._number)]["_saved"].XP, 0, 99999999999999)
	
	P.character_stats[str(P._number)]["_saved"].XP_next = clamp(P.character_stats[str(P._number)]["_saved"].XP_next, 0, 99999999999999)
	
	Hud._saved.Gold = clamp(Hud._saved.Gold, 0, 9999999999)
	
	Hud._saved.Score = clamp(Hud._saved.Score, 0, 9999999999)
	
	Hud._saved.Turns = clamp(Hud._saved.Turns, 0, 99999999999999)
	
	P.character_stats[str(P._number)]["_saved"].Strength = clamp(P.character_stats[str(P._number)]["_saved"].Strength, 0, 999)
	
	P.character_stats[str(P._number)]["_saved"].Defense = clamp(P.character_stats[str(P._number)]["_saved"].Defense, 0, 999)
	
	P.character_stats[str(P._number)]["_saved"].Constitution = clamp(P.character_stats[str(P._number)]["_saved"].Constitution, 0, 999)
	
	P.character_stats[str(P._number)]["_saved"].Dexterity = clamp(P.character_stats[str(P._number)]["_saved"].Dexterity, 0, 999)
	
	P.character_stats[str(P._number)]["_saved"].Intelligence = clamp(P.character_stats[str(P._number)]["_saved"].Intelligence, 0, 999)
	
	P.character_stats[str(P._number)]["_saved"].Charisma = clamp(P.character_stats[str(P._number)]["_saved"].Charisma, 0, 999)
	
	P.character_stats[str(P._number)]["_saved"].Wisdom = clamp(P.character_stats[str(P._number)]["_saved"].Wisdom, 0, 999)
	
	P.character_stats[str(P._number)]["_saved"].Willpower = clamp(P.character_stats[str(P._number)]["_saved"].Willpower, 0, 999)
	
	P.character_stats[str(P._number)]["_saved"].Perception = clamp(P.character_stats[str(P._number)]["_saved"].Perception, 0, 999)
	
	P.character_stats[str(P._number)]["_saved"].Luck = clamp(P.character_stats[str(P._number)]["_saved"].Luck, 0, 999)


# tile position of player.
func dungeon_coordinates(_x, _y, _bool) -> String:
	if _bool == true:
		_x = _x / 32
		_y = _y / 32
	
	var _str = str(_x) + "," + str(_y)
	
	return _str

# generate a random seed. this is used to make a 2d maze different each time a maze loads.	
func get_random_number():
	randomize()
	return randi() % 999999999
	
# id				refers to Variables._music index.
# _at_main_menu		all music from scenes not related to the main menu will set this to false.
func _music_play(_filename:String = "ballad.ogg", _id:int = 0, _at_main_menu:bool = true):
	if Settings._system.music == true:
		# this is needed so that when returning from high score or settings, the music from main menu will continue to play. this code will fail when returning from builder or from playing the game because the last known id will not be 0.
		if Variables._last_known_music_id == 0 && _at_main_menu == true && player != null && player.playing == true:
			return
			
		var _path = "res://audio/music/" + str(_filename)
		var _music := load(_path)
		
		if player != null:
			_music_stop()
			remove_child(player)
			player.free()
					
		player = AudioStreamPlayer.new()
		add_child(player)
		
		if Variables._last_known_music_id != _id || _at_main_menu == true:
			player.stream = _music
			player.play()
		
		Variables._last_known_music_id = _id


func _music_stop():
	if player != null:
		player.stop()
	

func delete_builder_playing_data():
	Filesystem.delete_builder_playing_data("user://saved_data/builder_playing_event_tasks_" + str(Variables._id_of_loaded_game) + ".txt")	
	
	Filesystem.delete_builder_playing_data("user://saved_data/builder_playing_event_story_" + str(Variables._id_of_loaded_game) + ".txt")
	
	Filesystem.delete_builder_playing_data("user://saved_data/builder_playing_event_puzzles_" + str(Variables._id_of_loaded_game) + ".txt")
	
	Filesystem.delete_builder_playing_data("user://saved_data/builder_playing_event_locked_doors_" + str(Variables._id_of_loaded_game) + ".txt")
	
	Filesystem.delete_builder_playing_data("user://saved_data/builder_playing_event_inventory_" + str(Variables._id_of_loaded_game) + ".txt")
	
	Filesystem.delete_builder_playing_data("user://saved_data/builder_playing_event_parent_" + str(Variables._id_of_loaded_game) + ".txt")
	
	Filesystem.delete_builder_playing_data("user://saved_data/builder_playing_next_event_" + str(Variables._id_of_loaded_game) + ".txt")
	
	Filesystem.delete_builder_playing_data("user://saved_data/builder_playing_artifacts_" + str(Variables._id_of_loaded_game) + ".txt")
	
	Filesystem.delete_builder_playing_data("user://saved_data/builder_playing_music_" + str(Variables._id_of_loaded_game) + ".txt")
	
	Filesystem.delete_builder_playing_data("user://saved_data/builder_playing__starting_skills_" + str(Variables._id_of_loaded_game) + ".txt")
	

# returns true if the string contains only letters.
func _is_letters(_str) -> bool:
	var regex = RegEx.new()
	var _found = false
	
	regex.compile("^[A-Za-z_]+$")
	var result = regex.search(_str)

	if result:
		_found = true
		
	return _found


# calculate how many mobs are in game and then store that value in Variables.enemy_total_in_game var. there are 8 dungeons, 0-7
func count_mobs_total_in_game():
	for _dn in range (8):
		# there are 99 levels in each dungeon.
		for _dl in range (99):
			Variables.enemy_total_in_game += Builder._data.mobs_total[Builder._config.game_id][_dn][_dl]


func directory_names(ID:int):
	match ID:
		0:
			Variables._dictionary_name = Enum.Builder_dictionary.keys()[Enum.Builder_dictionary.mobs1]
		
		1:
			Variables._dictionary_name = Enum.Builder_dictionary.keys()[Enum.Builder_dictionary.mobs2]
			
		2:
			Variables._dictionary_name = Enum.Builder_dictionary.keys()[Enum.Builder_dictionary.amulet]
		
		3:
			Variables._dictionary_name = Enum.Builder_dictionary.keys()[Enum.Builder_dictionary.armor]
			
		4:
			Variables._dictionary_name = Enum.Builder_dictionary.keys()[Enum.Builder_dictionary.book]
			
		5:
			Variables._dictionary_name = Enum.Builder_dictionary.keys()[Enum.Builder_dictionary.food]
		
		6:
			Variables._dictionary_name = Enum.Builder_dictionary.keys()[Enum.Builder_dictionary.gold]
		
		7:
			Variables._dictionary_name = Enum.Builder_dictionary.keys()[Enum.Builder_dictionary.ring]
		
		8:
			Variables._dictionary_name = Enum.Builder_dictionary.keys()[Enum.Builder_dictionary.scroll]
		
		9:
			Variables._dictionary_name = Enum.Builder_dictionary.keys()[Enum.Builder_dictionary.wand]			
		
		10:
			Variables._dictionary_name = Enum.Builder_dictionary.keys()[Enum.Builder_dictionary.weapon]
		
			
func _exit_tree():
	queue_free()
