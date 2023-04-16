"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# P.gd. player stats variables.
# MAX stat value should not go beyond 999, or else the code will trancate it back to 999.

#HD = willpower. ev = Dexterity. hp = hit points. ac - defence. 

extends Node

# player characters.
var character_name:Dictionary = {
	"0": "Maxim",
	"1": "Artea",
	"2": "Dekar",
	"3": "Guy",
	"4": "Lexis",
	"5": "Selan",
	"6": "Tia",	
		
}

# c = player character number.
var character_number = {
	"0": {},	
	"1": {},
	"2": {},
	"3": {},
	"4": {},
	"5": {},
	"6": {},
}

# player's class.
var class_list = {
	"0": "Archer",
	"1": "Druid",
	"2": "Knight",
	"3": "Paladin",
	"4": "Rogue",
	"5": "Sorcerer",
	"6": "Warrior",
}

# player stats and stats_saved directories will be created from this directory.
var _stats_data = {
		"Class": "",
		"Strength": 0,
		"Defense": 0,
		"Constitution": 0,
		"Dexterity": 0,
		"Intelligence": 0,
		"Level": 1,
		"Charisma": 0,
		"Wisdom": 0,
		"Willpower": 0,
		"Perception": 0,
		"Luck": 0,
		"Username": "Athena",
		"HP_max": hp_max,
		"HP": hp,
		"MP_max": mp_max,
		"MP": mp,
		"XP": 0,
		"XP_next": 0,
		
	}

# player's "loaded" stats refers to data for the "saved" panel at main menu screen. stats equals starting stats plus starting stats plus object stats.
var _stats_loaded = {}

# player's "saved" stats refers to data for the "saved" panel at main menu screen.
var _stats_saved = {}


var	_name

# short form of stat names, so that coding is easer. later, save these vars to dictionary, so a game save can be made.
var	_cha
var	_artifact_cha
var	_con
var	_artifact_con
var	_def
var	_artifact_def
var	_dex
var	_artifact_dex
var	_int
var	_artifact_int
var	_luc
var	_artifact_luc
var	_per
var	_artifact_per
var	_str
var	_artifact_str
var	_wil
var	_artifact_wil
var	_wis
var	_artifact_wis

var	_hp_max
var	_hp
var	_mp_max
var	_mp
var	_xp
var	_xp_next
var	_level # current level of player.

var hp = 20
var hp_max = 20
var mp = 20
var mp_max = 20

# this holds the player's experience points per level.
var _xp_level = []

var _move_speed = 0


func _ready():
	for _id in range (8):
		character_number[str(_id)] = { 
			_stats_loaded = {},
			_stats_saved = {}
		 }

	
func reset():
	_name = _stats_loaded.Username
	_cha		= _stats_loaded.Charisma
	_artifact_cha	= Builder._dictionary_artifacts.data.Charisma
	_con 		= _stats_loaded.Constitution
	_artifact_con 	= Builder._dictionary_artifacts.data.Constitution
	_def 		= _stats_loaded.Defense
	_artifact_def 	= Builder._dictionary_artifacts.data.Defense
	_dex 		= _stats_loaded.Dexterity
	_artifact_dex 	= Builder._dictionary_artifacts.data.Dexterity
	_int 		= _stats_loaded.Intelligence
	_artifact_int 	= Builder._dictionary_artifacts.data.Intelligence
	_luc 		= _stats_loaded.Luck
	_artifact_luc 	= Builder._dictionary_artifacts.data.Luck
	_per 		= _stats_loaded.Perception
	_artifact_per 	= Builder._dictionary_artifacts.data.Perception
	_str 		= _stats_loaded.Strength
	_artifact_str 	= Builder._dictionary_artifacts.data.Strength
	_wil 		= _stats_loaded.Willpower
	_artifact_wil 	= Builder._dictionary_artifacts.data.Willpower
	_wis 		= _stats_loaded.Wisdom
	_artifact_wis 	= Builder._dictionary_artifacts.data.Wisdom
	
	_hp_max 	= _stats_loaded.HP_max
	_hp 		= _stats_loaded.HP
	_mp_max 	= _stats_loaded.MP_max
	_mp 		= _stats_loaded.MP
	_xp 		= _stats_loaded.XP
	_xp_next	= _stats_loaded.XP_next
	_level 		= _stats_loaded.Level
	_move_speed = _move_speed


func _starting_statistics(_id):
	var _starting_dictionary = {
		"Class": "",
		"Strength": Builder._starting_statistics.Strength[_id],
		"Defense": Builder._starting_statistics.Defense[_id],
		"Constitution": Builder._starting_statistics.Constitution[_id],
		"Dexterity": Builder._starting_statistics.Dexterity[_id],
		"Intelligence": Builder._starting_statistics.Intelligence[_id],
		"Level": 1,
		"Charisma": Builder._starting_statistics.Charisma[_id],
		"Wisdom": Builder._starting_statistics.Wisdom[_id],
		"Willpower": Builder._starting_statistics.Willpower[_id],
		"Perception": Builder._starting_statistics.Perception[_id],
		"Luck": Builder._starting_statistics.Luck[_id],
		"Username": "Athena",
		"HP_max": hp_max,
		"HP": hp,
		"MP_max": mp_max,
		"MP": mp,
		"XP": 0,
		"XP_next": 0,
		
	}

		
	return _starting_dictionary

	
func _reset_data():
	for _id in range (7):
		_stats_loaded = _starting_statistics(_id)
		character_number[str(_id)]["_stats_loaded"].merge(_stats_loaded, true)
	
	reset()
	
	get_tree().call_group("main_loop", "clamp_p_vars")


func _reset_saved_data():
	for _id in range (7):
		_stats_saved = _starting_statistics(_id)
		character_number[str(_id)]["_stats_saved"].merge(_stats_saved, true)
		
	
	get_tree().call_group("main_loop", "clamp_p_vars_saved")
	
	
func reset_var():
	_move_speed = 0
	
	_reset_data()
	_reset_saved_data()

	reset()

	
func xp_table():
	_xp_level.clear()
	
	for _i in range(0, 99):
		_xp_level.push_back(int((_i * _i * _i * _i * _i) * 0.999999 / 2 * 15 / 0.5))
		
		_xp_level[_i] += int(_xp_level[_i] * (float(0.2 * Settings._game.difficulty_level)))
		

	#_xp_level[1] = 2
	#_xp_level[2] = 5
	#print(_xp_level)
