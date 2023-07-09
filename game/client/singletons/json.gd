"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# for player's stats, P._stats_data. 
# this file has all none-player dictionaries.
		
extends Node
# this data is sent to the server when user presses the send button.
# this data is sent to the client.
# sender:				either the name "server" or the name of someone at client.
# text:					the message content.
# item_list:			a comma separated list of users.
var _client_text: Dictionary = {
	"sender": 			{},
	"text": 			{},
	"item_list":		{},	
} 

# all mobs are here. json file is at root of project. 
# this dictionary is not at builder. at builder, clicking the update mobs button will copy all enabled mobs from the mobs1 and mobs2 dictionaries into this dictionary. the result is very fast 2d game loading because only the mobs for that level is loaded.
var mobs: Dictionary = {} #used in game.


# Earth Elemental:	Strong against water.	Weak against fire
# Air Element: 		Strong against earth. 	Weak against earth.
# Fire Element: 	Strong against cold.	Weak against water
# Water Element:	Strong against fire.	Weak against air.

# a list of runes currently in game. 
# dice			1d6 = 1 dice with a value of 1 to 6. Eg, a dice roll could hit for a value of 1 to 6.
# turns			how many turns before the rune is no more used.
# location		where the rune will cast to. Eg, a value of self means rune will be used on self.
# animation		the sprite to use when casting the rune.
# field			field runes stay at the dungeon for so many turns, while none-field runes are instant. 0: instant. 1: field.
# group 		"self" rune is used on self.
#				"attack" rune is used on mobs.
#				"support" rune is used on object.
# Level 	 	refers to what level is needed to buy that rune.
	
var _magic = {
	"blind":					{},
	"chaos":					{},
	"lock":						{},
	"poison":					{},
	"stop":						{},
	"slow":						{},
	"avoid":					{},
	"sleep":					{},
	"miracle":					{},
	"minor_healing": 			{},
	"small_fire": 				{},	
	"mud_pack": 				{},
	"chill_touch": 				{},	
	"light_healing": 			{},
	"find_weakness": 			{},	
	"light": 					{},	
	"flame_strike": 			{},	
	"poison_field": 			{},	
	"physical_strike": 			{},	
	"magic_shield": 			{},
	"cure_poison": 				{},
	"ruin_magic_shield": 		{},	
	"haste": 					{},
	"food": 					{},	
	"ice_strike": 				{},	
	"fire_field": 				{},	
	"great_light": 				{},	
	"peace": 					{},	
	"berserker": 				{},	
	"destroy_field": 			{},	
	"fire_wave": 				{},	
	"ice_wave": 				{},	
	"strong_haste": 			{},
	"intense_healing": 			{},
	"creature_illusion": 		{},	
	"stalagmite": 				{},	
	"poison_bomb": 				{},	
	"ultimate_light": 			{},	
	"wild_growth": 				{},	
	"soulfire": 				{},	
	"fireball": 				{},	
	"super_fire_field": 		{},	
	"stone_shower": 			{},
	"icicle": 					{},	
	"cure_burning": 			{},
	"ultimate_healing": 		{},
	"magic_wall": 				{},
	"invisible": 				{},
	"mud_pack_attack": 			{},	
	"strong_ice_wave": 			{},	
	"sudden_death": 			{},	
	"venom": 					{},	
	"paralyse": 				{},	
	"curse": 					{},	
	"ultra_earth_strike": 		{},
	"ultra_fire_strike": 		{},
	"ultra_air_strike": 		{},	
	"ultra_ice_strike": 		{},
	"sap_strength": 			{},	
	"restoration": 				{},
	"reset_level":				{},
	
}

# at builder, items can be added to directories. that will change the structor of it and there will be problems with reusing the same data. a scene could have a directory count of 100 but the correct value is 101. therefore, this clears all directory. at builder, data will be created on the fly.
var _s:Dictionary = {	 
	"mobs": 	{}, #  this mobs directory must never be coded to be accessed at builder from the menu called directory.
	"mobs1": 	{},
	"mobs2": 	{},
	"weapon":	{},
	"armor":	{},
	"book": 	{},
	"gold": 	{},
	"scroll":	{},
	"ring": 	{},
	"food": 	{},
	"wand":		{},
	"amulet":	{}
}


# mobs1 and mobs2 are not used at 2d dungeon. they are only used at builder. they are used at builder only for very fast loading and because they are organized based on difficulty. mobs1 are easier than mobs2.
# mobs that is enabled to be placed at dungeon level is copied to the mobs dictionary at initiation time at builder.
var mobs1: Dictionary 	= {} # not used in game. 
var mobs2: Dictionary 	= {} # not used in game.
var weapon: Dictionary 	= {}
var armor: Dictionary 	= {}
var book: Dictionary 	= {}
var gold: Dictionary 	= {}
var scroll: Dictionary 	= {}
var ring: Dictionary 	= {}
var food: Dictionary 	= {}
var wand: Dictionary 	= {}
var amulet: Dictionary 	= {}

# NOTE: also add the new dictionary at Enum.Builder_dictionary and here at func refresh_dictionaries.
var d:Dictionary = {
		"0": {},
		"1": {},
		"2": {},
		"3": {},
		"4": {},
		"5": {},
		"6": {},
		"7": {},
	}

func _ready():
	var dir = Directory.new()
	if not dir.dir_exists("res://bundles/builder/magic/data"):
		dir.make_dir("res://bundles/builder/magic/data")
		
	if not dir.dir_exists("res://bundles/builder/artifacts"):
		dir.make_dir("res://bundles/builder/artifacts")
						
	if not dir.dir_exists("res://bundles/builder/objects/data"):
		dir.make_dir("res://bundles/builder/objects/data")
		
	if not dir.dir_exists("res://bundles/builder/objects/images"):
		dir.make_dir("res://bundles/builder/objects/images")	
	
	if not dir.dir_exists("res://bundles/builder/objects/images/dictionaries"):
		dir.make_dir("res://bundles/builder/objects/images/dictionaries")
	
	# after downloading the archive from the Super-RPG-Retro repository at github, the empty builder folders do not exist so they have to be created here.
	if not dir.dir_exists("res://bundles/builder/objects/system/data/mobs"):
		dir.make_dir("res://bundles/builder/objects/system/data/mobs")
	
	if not dir.dir_exists("res://bundles/builder/objects/system/images/dictionaries/mobs"):
		dir.make_dir("res://bundles/builder/objects/system/images/dictionaries/mobs")
	
	make_directories()
	
	
# at builder, items can be added to directories. that will change the structor of it and there will be problems with reusing the same data. a scene could have a directory count of 100 but the correct value is 101. therefore, this clears all directory. at builder, data will be created on the fly.
func make_directories():
	# id is the dictionary number. d is the dictionary. there are Variables._total_builder_data_directories dictionaries at directory builder_data at hard drive.
	for _id in range (Variables._total_builder_data_directories):
		d[str(_id)] = {}
		
		d[str(_id)].merge(_s)
			
		
# dictionaries are loaded one level at a time.
func refresh_dictionaries(_path, _get_names:bool = false):
	Filesystem.FILE_PATH = _path
	var _mobs_names = []
	
	# when searching for a file at hard drive, this is the sprite file path and texture path of the data.
	Variables._file_paths.clear()
	Variables._file_names.clear()
	Variables._file_names_sorted.clear()
	Variables._folder_names.clear()
	Variables._image_textures.clear()
	Variables._image_textures_sorted.clear()
	
	# gets the filenames from that folder
	Filesystem.get_dir_files(_path)
	Variables._file_names = Variables._file_paths.duplicate(true)
		
	# output all files in this var.
	var _i = -1
	for _f in Variables._file_paths:
		_i += 1
		
		# _fn is a duplicate of Variables._file_paths. this cuts the path down so only the folder plus filename remains.
		Variables._file_names[int(str(_i).pad_zeros(2))] =	Variables._file_names[int(str(_i).pad_zeros(2))].replace(_path, "")
		Variables._file_names[int(str(_i).pad_zeros(2))] =	Variables._file_names[int(str(_i).pad_zeros(2))].replace(".json", "")
		
		
	# for each filename found at harddrive, load the data from harddrive into that dictionary mobs.
	for _n in Variables._folder_names:	
		for _f in Variables._file_names:
			if _n in _f && _f.replace(_n + "/", "") != "":
				for _id in range (Variables._total_builder_data_directories):
					
					if _path == Variables._project_path + "/builder/objects/data/"+ str(Builder._config.game_id + 1) +"/mobs/" + str(Builder._data.dungeon_number + 1) + "/" + str(Builder._data.level_number + 1) + "/":
						d[str(_id)].mobs[_f.replace(_n + "/", "")] = Filesystem.load_dictionary_json(_f)
												
						if _get_names == true:
							_mobs_names.push_back(_f.replace(_n + "/", ""))
									
					#_id is the json directory where the items are in, such as, book, gold, ring and weapon.
					else:				
						for _q in d[str(_id)].keys():
							# d refers to the dictionary var. _f is the folder inside of _id such as animals/adders.
							if _path == Variables._project_path + "/builder/objects/data/"+ str(Builder._config.game_id + 1) +"/" + str(_q) + "/":
								d[str(_id)][str(_q)][_f.replace(_n + "/", "")] = Filesystem.load_dictionary_json(_f)
				
	# remove a file name without a folder.
	for _file in Variables._file_names:
		if not "/" in _file:
			Variables._file_names.erase(_file)
	
	if _get_names == true:
		return _mobs_names
	
