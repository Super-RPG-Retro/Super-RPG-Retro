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

onready var _magic_bar = $Background/MagicBar
onready var _magic_percentage = $Background/MagicPercentage

onready var _player_gain_a_level = null

# health "min / max" values
onready var _health_text = $Background/HealthText
onready var _mana_text = $Background/MagicText
  

func _ready():
	P._reset_data() # sets the vars to the player in use. 
	
	if Variables._at_scene == Enum.Scene.Game_UI:
		$ButtonExit.visible = true
		
	_health_bar.max_value = P.character_number[str(P._number)]["_stats_loaded"].HP_max
	_health_bar.value = P.character_number[str(P._number)]["_stats_loaded"].HP
	
	_magic_bar.max_value = P.character_number[str(P._number)]["_stats_loaded"].MP_max
	_magic_bar.value = P.character_number[str(P._number)]["_stats_loaded"].MP

	stats_text_all_update()
	stats_value_all_update()
	
	player_stats_panel_size()
	
		
func _input(event):
	Variables._mouse_cursor_position.x = get_global_mouse_position().x
	Variables._mouse_cursor_position.y = get_global_mouse_position().y
	
	# this is for the small panel. if arrow up button is clicked then stats name, xp, etc is shown. if down arrow button is clicked then str, def, con, etc is shown.
	if event is InputEventMouseButton && event.is_action_pressed("ui_left_mouse_click") && Variables._child_scene_open == false || event is InputEventMouseButton && event.is_action_pressed("ui_left_mouse_click") && Variables._child_scene_open == true && Variables._at_scene == Enum.Scene.Main_Menu:
		#left side of scene.
		if Variables._mouse_cursor_position.x <= 512 && self.visible == true || Variables._at_scene != Enum.Scene.Main_Menu:
			if get_node("Background/ArrowUp").has_focus():
				P._number += 1
				# update small health bar.
				get_tree().call_group("player_damage", "damage_player", 0)
			
			if get_node("Background/ArrowDown").has_focus():
				P._number -= 1
				# update small health bar.
				get_tree().call_group("player_damage", "damage_player", 0)
			
			P._number = clamp(P._number, 0, 6)
				
			if get_node("Background/ArrowUp").has_focus() == true || get_node("Background/ArrowDown").has_focus() == true:
				if Settings._system.sound == true:
					if $SoundClick.is_playing() == false:
						$SoundClick.play()
			
				
			_health_bar.max_value = P.character_number[str(P._number)]["_stats_loaded"].HP_max
			_health_bar.value = P.character_number[str(P._number)]["_stats_loaded"].HP
			
			_magic_bar.max_value = P.character_number[str(P._number)]["_stats_loaded"].MP_max
			_magic_bar.value = P.character_number[str(P._number)]["_stats_loaded"].MP
			
			stats_text_all_update()
			stats_value_all_update()
			
			# change the player's texture on main map.
			get_tree().call_group("player", "_change_texture")
			
					
func player_stats_panel_size():
	if Variables._at_scene == Enum.Scene.Game_UI:
		if Settings._system.player_stats_panel_size == 0:
			get_node("Background").margin_bottom = 123
			get_node("Background/StatsTextAllColumn1Label").visible = false
			get_node("Background/StatsValueAllColumn1Label").visible = false
			get_node("Background/StatsTextAllColumn2Label").visible = false
			get_node("Background/StatsValueAllColumn2Label").visible = false
	
		elif Settings._system.player_stats_panel_size <= 2:
			get_node("Background").rect_size.y = 268
			
			get_node("Background/StatsTextAllColumn1Label").visible = true
			get_node("Background/StatsValueAllColumn1Label").visible = true
			get_node("Background/StatsTextAllColumn2Label").visible = true
			get_node("Background/StatsValueAllColumn2Label").visible = true
		
		elif Settings._system.player_stats_panel_size == 3:
			get_node("Background").rect_size.y = 402
			
			get_node("Background/StatsTextAllColumn1Label").visible = true
			get_node("Background/StatsValueAllColumn1Label").visible = true
			get_node("Background/StatsTextAllColumn2Label").visible = true
			get_node("Background/StatsValueAllColumn2Label").visible = true
	
	else:
		get_node("Background/StatsTextAllColumn1Label").visible = true
		get_node("Background/StatsValueAllColumn1Label").visible = true
		get_node("Background/StatsTextAllColumn2Label").visible = true
		get_node("Background/StatsValueAllColumn2Label").visible = true


func damage():	
	var _t: float = P._hp
	var _t_max: float = P._hp_max
	_health_percentage.text = str(int((_t / _t_max) * 100)) + "%"

	_health_text.text = str(_t).pad_zeros(4) + "/" + str(_t_max).pad_zeros(4)

	_on_HealthBar_value_changed(P._hp)
	
	_t = P._mp
	
	_t_max = 0
	_magic_percentage.text = "0%"
	
	if P._mp_max > 0:
		_t_max = P._mp_max
		_magic_percentage.text = str(int((_t / _t_max) * 100)) + "%"

	_mana_text.text = str(_t).pad_zeros(4) + "/" + str(_t_max).pad_zeros(4)
	
	_on_MagicBar_value_changed(P._mp)
	
	
func stats_text_all_update():	
	var i = -1
	_stats_text_all_column1_label.bbcode_enabled = true
	_stats_text_all_column2_label.bbcode_enabled = true
	
	for d in P.character_number[str(P._number)]["_stats_loaded"].keys():
		i += 1
		if i <= 5:
			if d == "Class":
				d = ""
							
			_stats_text_all_column1_label.bbcode_text += "[right]" + str(d) + "[/right]\n"
		else:
			if d == "Level":
				d = ""
			
			_stats_text_all_column2_label.bbcode_text += "[right]" + str(d) + "[/right]\n"
	
	_on_HealthBar_value_changed(P.character_number[str(P._number)]["_stats_loaded"].HP)
	_on_MagicBar_value_changed(P.character_number[str(P._number)]["_stats_loaded"].MP)

	
func stats_empty():
	self.visible = false
	Variables._is_loaded_id_panel_visible = false


# updates the player's stats panel. 
func stats_value_all_update(_x: int = 0): #_p = player number.
	self.visible = true
	Variables._is_loaded_id_panel_visible = true
	
	if _x > 0:
		P._xp += _x
	
	var _found = false
	
	# determine is player advances to the next level.
	for _i in range(0, 99):
		if 	P._xp >= P._xp_level[_i] && _i > P._level - 1:
			
			# destroy level up scene so that its dialog can be displayed at the ready() func, the next time its newed.			  
			if _player_gain_a_level != null:
				remove_child(_player_gain_a_level)
				_player_gain_a_level = null
			
			# display the level up dialog.
			if _player_gain_a_level == null:
				_player_gain_a_level = load("res://2d/source/scenes/player_gained_a_level.tscn").instance()
				add_child(_player_gain_a_level)
				
			_player_gain_a_level.visible = true
			_found = true
			
				
	if _found == false && _player_gain_a_level != null:
		_player_gain_a_level.visible = false
	
	# display xp_next at stats.
	if P.character_number[str(P._number)]["_stats_loaded"].Level < 99:
		_xp_next_value_label.text = str(P._xp_level[P._level])	
	
	# display the username on the stats panel.	
	if get_node("Background/UsernameValueLabel") != null && P.character_number[str(P._number)]["_stats_loaded"].Username != "":
		_username_value_label = get_node("Background/UsernameValueLabel")
		_username_value_label.text = P.character_number[str(P._number)]["_stats_loaded"].Username[0].to_upper() + P.character_number[str(P._number)]["_stats_loaded"].Username.substr(1,-1) + " - " + P.character_name[str(P._number)]
	
	# display the xp on the stats panel.
	_xp_value_label.text = str(P._xp)
	_xp_next_value_label.text = str(P._xp_next)
	
	# prepare to display the rest of the stats, such as, str, def, int.
	P.character_number[str(P._number)]["_stats_loaded"].Level = P._level
	
	var i = -1
	_stats_value_all_column1_label.bbcode_enabled = true
	_stats_value_all_column2_label.bbcode_enabled = true
	
	_stats_value_all_column1_label.bbcode_text = ""
	_stats_value_all_column2_label.bbcode_text = ""
	
	# add the stats values, such as, str value, def value.
	for d in P.character_number[str(P._number)]["_stats_loaded"].values():
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
				
	# display the health and health max.
	if get_node("Background/HealthText") != null:
		_health_text = get_node("Background/HealthText")
		_health_text.text = str(P.character_number[str(P._number)]["_stats_loaded"].HP).pad_zeros(4) + "/" + str(P.character_number[str(P._number)]["_stats_loaded"].HP_max).pad_zeros(4)
	
	# healthbar	
	var _t: float = P.character_number[str(P._number)]["_stats_loaded"].HP
	var _t_max: float = P.character_number[str(P._number)]["_stats_loaded"].HP_max
	_health_percentage.text = str(int((_t / _t_max) * 100)) + "%"
	
	_on_HealthBar_value_changed(P.character_number[str(P._number)]["_stats_loaded"].HP)
	
	
	
	# display the health and health max.
	if get_node("Background/MagicText") != null:
		_mana_text = get_node("Background/MagicText")
		_mana_text.text = str(P.character_number[str(P._number)]["_stats_loaded"].MP).pad_zeros(4) + "/" + str(P.character_number[str(P._number)]["_stats_loaded"].MP_max).pad_zeros(4)
	
	# Magicbar	
	_t = P.character_number[str(P._number)]["_stats_loaded"].MP
	_magic_percentage.text = "0%"
	
	_t_max = 0
	if P.character_number[str(P._number)]["_stats_loaded"].MP_max > 0:
		_t_max = P.character_number[str(P._number)]["_stats_loaded"].MP_max
		_magic_percentage.text = str(int((_t / _t_max) * 100)) + "%"
	
		_on_MagicBar_value_changed(P.character_number[str(P._number)]["_stats_loaded"].MP)
	
	
func _on_HealthBar_value_changed(value):
	_health_bar.texture_progress = Preload.bar_blue
	
	if value < _health_bar.max_value * 0.7:
		_health_bar.texture_progress = Preload.bar_yellow
	
	if value < _health_bar.max_value * 0.35:
		_health_bar.texture_progress = Preload.bar_red
	
	if value <= 0:
		_health_bar.texture_progress = Preload.bar_gray
	
	_health_bar.value = value


func _on_MagicBar_value_changed(value):
	_magic_bar.texture_progress = Preload.bar_blue
	
	if value < _magic_bar.max_value * 0.7:
		_magic_bar.texture_progress = Preload.bar_yellow
	
	if value < _magic_bar.max_value * 0.35:
		_magic_bar.texture_progress = Preload.bar_red
	
	if value <= 0:
		_magic_bar.texture_progress = Preload.bar_gray
	
	_magic_bar.value = value
	

func _on_ArrowUp_mouse_entered():
	if Variables._child_scene_open == true && Variables._at_scene != Enum.Scene.Main_Menu:
		return
			
	get_node("Background/ArrowUp").modulate = Color(1, 0.5, 0.5, 1)
	get_node("Background/ArrowUp").grab_focus()


func _on_ArrowUp_mouse_exited():
	if Variables._child_scene_open == true && Variables._at_scene != Enum.Scene.Main_Menu:
		return
		
	get_node("Background/ArrowUp").modulate = Color(1, 1, 1, 1)
	get_node("Background/ArrowUp").release_focus()


func _on_ArrowDown_mouse_entered():
	if Variables._child_scene_open == true && Variables._at_scene != Enum.Scene.Main_Menu:
		return
			
	get_node("Background/ArrowDown").modulate = Color(1, 0.5, 0.5, 1)
	get_node("Background/ArrowDown").grab_focus()


func _on_ArrowDown_mouse_exited():
	if Variables._child_scene_open == true && Variables._at_scene != Enum.Scene.Main_Menu:
		return
			
	get_node("Background/ArrowDown").modulate = Color(1, 1, 1, 1)
	get_node("Background/ArrowDown").release_focus()


func _on_ButtonExit_pressed():
	if Variables._child_scene_open == true:
		return
		
	Variables._trigger_escape_dialog = true
	
	
