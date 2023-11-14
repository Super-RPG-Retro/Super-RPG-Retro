"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# PC.gd. player stats variables.
# MAX stat value should not go beyond 999, or else the code will trancate it back to 999.

#HD = willpower. ev = Dexterity. hp = hit points. ac - defence. 

extends Node


# player characters.
var character_name := {
	"0": "Maxim",
	"1": "Tia",
	"2": "Dekar",
	"3": "Guy",
	"4": "Selan",
	"5": "Lexis",
	"6": "Artea",	
		
}

# c = player character number.
var character_stats := {
	"0": {},	
	"1": {},
	"2": {},
	"3": {},
	"4": {},
	"5": {},
	"6": {},
}

# current character number.
var _number := 0

# player's class.
var class_list := {
	"0": "Archer",
	"1": "Druid",
	"2": "Knight",
	"3": "Paladin",
	"4": "Rogue",
	"5": "Sorcerer",
	"6": "Warrior",
}

# player stats and stats_saved directories will be created from this directory.
var _stats_data := {
		"Class": 		"",
		"Strength":		0,
		"Defense": 		0,
		"Constitution": 0,
		"Dexterity": 	0,
		"Intelligence": 0,
		"Level": 		0,
		"Charisma": 	0,
		"Wisdom": 		0,
		"Willpower": 	0,
		"Perception": 	0,
		"Luck": 		0,
		"Username": 	"Athena",
		"HP_max": 		_hp_max,
		"HP": 			_hp,
		"MP_max": 		_mp_max,
		"MP": 			_mp,
		"XP": 			_xp,
		"XP_next": 		_xp_next,
		
	}

# player's "loaded" stats refers to data for the "saved" panel at main menu screen. stats equals starting stats plus starting stats plus object stats.
var _loaded			:= {}

# player's "saved" stats refers to data for the "saved" panel at main menu screen.
var _saved			:= {}
var	_name			:= ""

# short form of stat names, so that coding is easer. later, save these vars to dictionary, so a game save can be made.
var	_cha			:= 0
var	_con			:= 0
var	_def			:= 0
var	_dex			:= 0
var	_int			:= 0
var	_luc			:= 0
var	_per			:= 0
var	_str			:= 0
var	_wil			:= 0
var	_wis			:= 0

var	_hp_max			:= 20
var	_hp 			:= 20
var	_mp_max 		:= 0
var	_mp 			:= 0
var	_xp 			:= 0
var	_xp_next 		:= 34
var	_level 			:= 0 # current level of player.

# this holds the player's experience points per level.
var _xp_level := []

var _move_speed := 0


func _ready():
	for _id in range (character_stats.size()):
		character_stats[str(_id)] = { 
			_loaded = {},
			_saved = {}
		 }

	
func reset():
	_name = _loaded.Username
	
	_cha		= _loaded.Charisma
	_con 		= _loaded.Constitution
	_def 		= _loaded.Defense
	_dex 		= _loaded.Dexterity
	_int 		= _loaded.Intelligence
	_luc 		= _loaded.Luck
	_per 		= _loaded.Perception
	_str 		= _loaded.Strength
	_wil 		= _loaded.Willpower
	_wis 		= _loaded.Wisdom
	

# do not reorder because that would change the order of this stats text at the player_stats scene.
func _starting_skills(_id):
	var _starting_dictionary = {
		"Class": 		"",
		"Username": 	"Athena",
		
		"HP_max": 		Builder._starting_skills.HP_max[_id],
		"HP": 			Builder._starting_skills.HP[_id],
		"MP_max": 		Builder._starting_skills.MP_max[_id],
		"MP": 			Builder._starting_skills.MP[_id],
		"XP": 			Builder._starting_skills.XP[_id],
		"XP_next": 		Builder._starting_skills.XP_next[_id],
		
		"Strength": 	Builder._starting_skills.Strength[_id],
		"Defense": 		Builder._starting_skills.Defense[_id],
		"Constitution": Builder._starting_skills.Constitution[_id],
		"Dexterity": 	Builder._starting_skills.Dexterity[_id],
		"Intelligence": Builder._starting_skills.Intelligence[_id],
		"Level": 		Builder._starting_skills.Level[_id],
		"Charisma": 	Builder._starting_skills.Charisma[_id],
		"Wisdom": 		Builder._starting_skills.Wisdom[_id],
		"Willpower": 	Builder._starting_skills.Willpower[_id],
		"Perception": 	Builder._starting_skills.Perception[_id],
		"Luck": 		Builder._starting_skills.Luck[_id],
		
	}

		
	return _starting_dictionary

	
func _update_character_stats_loaded():
	for _id in range (character_stats.size()):
		_loaded = _starting_skills(_id)
		character_stats[str(_id)]["_loaded"].merge(_loaded, true)
	
	reset()
	
	get_tree().call_group("main_loop", "clamp_p_vars")


func _update_character_stats_saved():
	for _id in range (character_stats.size()):
		_saved = _starting_skills(_id)
		character_stats[str(_id)]["_saved"].merge(_saved, true)
		
	
	get_tree().call_group("main_loop", "clamp_p_vars_saved")
	
	
func reset_var():
	_move_speed = 0
	
	_update_character_stats_loaded()
	_update_character_stats_saved()

	reset()
	
	
func xp_table():
	_xp_level.clear()
	_xp_level.push_back(0)
	
	for _i in range(1, 999):
		_xp_level.push_back(int(float(_i * _i * _i / 2.0 * 12.0 / 0.5)) + 17)
		
		_xp_level[_i] += int(_xp_level[_i] * (float(0.2 * Settings._game.difficulty_level)))
		
		
	#print(_xp_level)
