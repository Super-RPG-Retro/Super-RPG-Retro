"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

onready var _username_value_label = $Background/UsernameValueLabel
onready var _xp_value_label = $Background/xpValueLabel
onready var _xp_next_value_label = $Background/xpNextValueLabel

onready var _stats_text_all_column1_label = $Background/StatsTextAllColumn1Label
onready var _stats_text_all_column2_label = $Background/StatsTextAllColumn2Label
onready var _stats_value_all_column1_label = $Background/StatsValueAllColumn1Label
onready var _stats_value_all_column2_label = $Background/StatsValueAllColumn2Label

onready var _health_bar = $Background/HealthBar
onready var _health_percentage = $Background/HealthPercentage
onready var _health_text = $Background/HealthText

onready var _magic_bar = $Background/MagicBar
onready var _magic_percentage = $Background/MagicPercentage
onready var _mana_text = $Background/MagicText


func _ready():	
	stats_saved_text_all_update()
	stats_saved_value_all_update()
	
	var _t: float = P.character_number["0"]["_stats_saved"].HP
	var _t_max: float = P.character_number["0"]["_stats_saved"].HP_max
	_health_percentage.text = str(int((_t / _t_max) * 100)) + "%"
	
	_magic_bar.max_value = P.character_number["0"]["_stats_saved"].MP_max * P.character_number["0"]["_stats_saved"].Level
	
	_t = P.character_number["0"]["_stats_saved"].MP
	_t_max = P.character_number["0"]["_stats_saved"].MP_max
	_magic_percentage.text = str(int((_t / _t_max) * 100)) + "%"
	
	
func _process(_delta):
	_health_bar.max_value = P.character_number["0"]["_stats_saved"].HP_max
	_on_HealthBar_value_changed(P.character_number["0"]["_stats_saved"].HP)
	
	var _t: float = P.character_number["0"]["_stats_saved"].HP
	var _t_max: float = P.character_number["0"]["_stats_saved"].HP_max
	_health_percentage.text = str(int((_t / _t_max) * 100)) + "%"
	
	_health_text.text = str(_t).pad_zeros(4) + "/" + str(_t_max).pad_zeros(4)
	
	_magic_bar.max_value = P.character_number["0"]["_stats_saved"].MP_max
	_on_MagicBar_value_changed(P.character_number["0"]["_stats_saved"].MP)
		
	_t = P.character_number["0"]["_stats_saved"].MP
	_t_max = P.character_number["0"]["_stats_saved"].MP_max
	_magic_percentage.text = str(int((_t / _t_max) * 100)) + "%"
	
	_mana_text.text = str(_t).pad_zeros(4) + "/" + str(_t_max).pad_zeros(4)
	
func stats_saved_text_all_update():
	
	var i = -1
	_stats_text_all_column1_label.bbcode_enabled = true
	_stats_text_all_column2_label.bbcode_enabled = true
	
	for d in P.character_number["0"]["_stats_saved"].keys():
		i += 1
		if i <= 5:
			if d == "Gold":
				d = ""
							
			_stats_text_all_column1_label.bbcode_text += "[right]" + str(d) + "[/right]\n"
		else:
			if d == "Level":
				d = ""
			
			_stats_text_all_column2_label.bbcode_text += "[right]" + str(d) + "[/right]\n"
			
	_on_HealthBar_value_changed(P.character_number["0"]["_stats_saved"].HP)
	_on_MagicBar_value_changed(P.character_number["0"]["_stats_saved"].MP)


func stats_saved_empty():
	self.visible = false
	Variables._is_saved_id_panel_visible = false	
	
func stats_saved_value_all_update():
	call_deferred("stats_saved_value_all_update2")
	self.visible = true
	Variables._is_saved_id_panel_visible = true

# this func is called when the game id value is changed at the main menu. this updates the game data saved panel.
func stats_saved_value_all_update2():	
	_username_value_label.text = P.character_number["0"]["_stats_saved"].Username + " - " + P.character_name["0"]
	
	_xp_value_label.text = str(P.character_number["0"]["_stats_saved"].XP)
	_xp_next_value_label.text = str(P.character_number["0"]["_stats_saved"].XP_next)
	
	# display xp_next at stats.
	if P.character_number["0"]["_stats_saved"].Level < 99:
		_xp_next_value_label.text = str(P._xp_level[P.character_number["0"]["_stats_saved"].Level]) 
	
	
	var i = -1
	_stats_value_all_column1_label.bbcode_enabled = true
	_stats_value_all_column2_label.bbcode_enabled = true
	
	_stats_value_all_column1_label.bbcode_text = ""
	_stats_value_all_column2_label.bbcode_text = ""
	
	for d in P.character_number["0"]["_stats_saved"].values():
		i += 1
		if i <= 5:
			if i == 0:
				_stats_value_all_column1_label.bbcode_text += "\n"
			else:
				_stats_value_all_column1_label.bbcode_text += str(d).pad_zeros(3) + "\n"
		else:
			if i == 6:
				_stats_value_all_column2_label.bbcode_text += "\n"
			else:
				_stats_value_all_column2_label.bbcode_text += str(d).pad_zeros(3) + "\n"

	_health_text.text = str(P.character_number["0"]["_stats_saved"].HP).pad_zeros(4) + "/" + str(P.character_number["0"]["_stats_saved"].HP_max).pad_zeros(4)
	_mana_text.text = str(P.character_number["0"]["_stats_saved"].MP).pad_zeros(4) + "/" + str(P.character_number["0"]["_stats_saved"].MP_max).pad_zeros(4)
	

func _on_HealthBar_value_changed(value):
	_health_bar.texture_progress = Preload.bar_blue
	
	if value < _health_bar.max_value * 0.7:
		_health_bar.texture_progress = Preload.bar_yellow
	
	if value < _health_bar.max_value * 0.35:
		_health_bar.texture_progress = Preload.bar_red
		
	_health_bar.value = value
	
func _on_MagicBar_value_changed(value):
	_magic_bar.value = value
	
