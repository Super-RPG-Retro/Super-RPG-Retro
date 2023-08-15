"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


@onready var _username_value_label := $Background/UsernameValueLabel
@onready var _xp_value_label := $Background/xpValueLabel
@onready var _xp_next_value_label := $Background/xpNextValueLabel

@onready var _stats_text_all_column1_label := $Background/StatsTextAllColumn1Label
@onready var _stats_text_all_column2_label := $Background/StatsTextAllColumn2Label
@onready var _stats_value_all_column1_label := $Background/StatsValueAllColumn1Label
@onready var _stats_value_all_column2_label := $Background/StatsValueAllColumn2Label

@onready var _health_bar := $Background/HealthBar
@onready var _health_percentage := $Background/HealthPercentage

@onready var _magic_bar := $Background/MagicBar
@onready var _magic_percentage := $Background/MagicPercentage

@onready var _player_gain_a_level = null

# health "min / max" values
@onready var _health_text := $Background/HealthText
@onready var _mana_text := $Background/MagicText

@onready var _misc_value_all_column1_label := $Background/MiscValueAllColumn1Label
	
# sets the player character to the first player when scene loads.
var _do_once_at_scene_load := true


func _ready():
	# stat text will not draw to scene when mouse is outside of app.
	get_viewport().warp_mouse(Vector2(512, 330))
	
	if Variables._at_scene == Enum.Scene.Game_UI:
		$ButtonExit.visible = true
	
	else:
		P._update_character_stats_loaded() # sets the stats vars to the player in use. 
	
	# draw the stats panel but do not display the stats panel unless the saved panel is displayed.
	self.visible = true	
	_update_stats()	
	
	# update small health bar.
	get_tree().call_group("player_damage", "damage_player", 0)
	player_stats_panel_size()
	
		
func _input(event):
	Variables._mouse_cursor_position.x = get_global_mouse_position().x
	Variables._mouse_cursor_position.y = get_global_mouse_position().y
	
	# this is for the small panel. if arrow up button is clicked then stats name, xp, etc is shown. if down arrow button is clicked then str, def, con, etc is shown.
	if event is InputEventMouseButton && event.is_action_pressed("ui_left_mouse_click") && Variables._child_scene_open == false || event is InputEventMouseButton && event.is_action_pressed("ui_left_mouse_click") && Variables._child_scene_open == true && Variables._at_scene == Enum.Scene.Main_Menu || _do_once_at_scene_load == true:
		#left side of scene.
		if self.visible == true || Variables._at_scene != Enum.Scene.Main_Menu || _do_once_at_scene_load == true:
			if get_node("Background/ArrowUp").has_focus() || _do_once_at_scene_load == true:
				Common._update_stats_last_player(P._number)
				
				if _do_once_at_scene_load == false:
					P._number += 1
				
				P._number = int(clamp(P._number, 0, 6))
				
				Common._update_stats_player_characters(P._number)
				_update_stats()	
				
				# update small health bar.
				get_tree().call_group("player_damage", "damage_player", 0)
				
				_do_once_at_scene_load = false
				
			
			if get_node("Background/ArrowDown").has_focus():
				Common._update_stats_last_player(P._number)
				
				P._number -= 1
				P._number = int(clamp(P._number, 0, 6))
				
				Common._update_stats_player_characters(P._number)
				_update_stats()	
				
				# update small health bar.
				get_tree().call_group("player_damage", "damage_player", 0)
			
			if get_node("Background/ArrowUp").has_focus() == true || get_node("Background/ArrowDown").has_focus() == true:
				if Settings._system.sound == true:
					if $SoundClick.is_playing() == false:
						$SoundClick.play()
					
			# change the player's texture on main map.
			get_tree().call_group("player", "_change_texture")
			
	
func _update_stats():
	_health_bar.max_value = P.character_stats[str(P._number)]["_loaded"].HP_max
	_health_bar.value = P.character_stats[str(P._number)]["_loaded"].HP
	
	_magic_bar.max_value = P.character_stats[str(P._number)]["_loaded"].MP_max
	_magic_bar.value = P.character_stats[str(P._number)]["_loaded"].MP
	
	if self.visible == true:
		stats_text_all_update()
		stats_value_all_update()
	

func player_stats_panel_size():
	var _vis = true
	
	if Variables._at_scene == Enum.Scene.Game_UI:
		_vis = false
		
		if Settings._system.player_stats_panel_size == 0:
			get_node("Background").offset_bottom = 123
			
		elif Settings._system.player_stats_panel_size <= 2:
			get_node("Background").size.y = 268
			_vis = true
				
		elif Settings._system.player_stats_panel_size == 3:
			get_node("Background").size.y = 402
			_vis = true
		
	for _i in range (1, 2):		
		get_node("Background/StatsTextAllColumn" + str(_i) + "Label").visible = _vis
		get_node("Background/StatsValueAllColumn" + str(_i) + "Label").visible = _vis
		
	
func damage():	
	var _t: float = P.character_stats[str(P._number)]["_loaded"].HP
	var _t_max: float = P.character_stats[str(P._number)]["_loaded"].HP_max
	_health_percentage.text = str(int((_t / _t_max) * 100)) + "%"

	_health_text.text = str(_t).pad_zeros(4) + "/" + str(_t_max).pad_zeros(4)

	_on_HealthBar_value_changed(P.character_stats[str(P._number)]["_loaded"].HP)
	
	_t = P.character_stats[str(P._number)]["_loaded"].MP
	
	_t_max = 0
	_magic_percentage.text = "0%"
	
	if P.character_stats[str(P._number)]["_loaded"].MP_max > 0:
		_t_max = P.character_stats[str(P._number)]["_loaded"].MP_max
		_magic_percentage.text = str(int((_t / _t_max) * 100)) + "%"

	_mana_text.text = str(_t).pad_zeros(4) + "/" + str(_t_max).pad_zeros(4)
	
	_on_MagicBar_value_changed(P.character_stats[str(P._number)]["_loaded"].MP)
	
	
func stats_text_all_update():	
	var i = -1
	_stats_text_all_column1_label.bbcode_enabled = true
	_stats_text_all_column2_label.bbcode_enabled = true
	
	for d in P.character_stats[str(P._number)]["_loaded"].keys():
		i += 1
		if i <= 5:
			if d == "Class":
				d = ""
							
			_stats_text_all_column1_label.text += "[right]" + str(d) + "[/right]\n"
		else:
			if d == "Level":
				d = ""
			
			_stats_text_all_column2_label.text += "[right]" + str(d) + "[/right]\n"
	
	_on_HealthBar_value_changed(P.character_stats[str(P._number)]["_loaded"].HP)
	_on_MagicBar_value_changed(P.character_stats[str(P._number)]["_loaded"].MP)

	
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
	
	#print(P._xp)
	#print("level " ,P._level )
	
	# determine is player advances to the next level.
	for _i in range(1, 999):
		if 	P._xp >= P._xp_level[_i] && _i -1 == P._level:
			
			# destroy level up scene so that its dialog can be displayed at the ready() func, the next time its newed.			  
			if _player_gain_a_level != null:
				remove_child(_player_gain_a_level)
				_player_gain_a_level = null
			
			# display the level up dialog.
			if _player_gain_a_level == null:
				_player_gain_a_level = load("res://2d/source/scenes/player_gained_a_level.tscn").instantiate()
				add_child(_player_gain_a_level)
				
			_player_gain_a_level.visible = true
			_found = true
			
				
	if _found == false && _player_gain_a_level != null:
		_player_gain_a_level.visible = false
	
	# display xp_next at stats.
	if P._level < 999:
		_xp_next_value_label.text = str(P._xp_level[P._level])	
	
	# display the username on the stats panel.	
	if get_node("Background/UsernameValueLabel") != null && P.character_stats[str(P._number)]["_loaded"].Username != "":
		_username_value_label = get_node("Background/UsernameValueLabel")
		_username_value_label.text = P.character_stats[str(P._number)]["_loaded"].Username[0].to_upper() + P.character_stats[str(P._number)]["_loaded"].Username.substr(1,-1) + " - " + P.character_name[str(P._number)]
	
	# display the xp on the stats panel.
	if P._xp == 0:
		P._xp = P._xp_level[P._level]
	
	_xp_value_label.text = str(P._xp)
	_xp_next_value_label.text = str(P._xp_next)
	
	# prepare to display the rest of the stats, such as, str, def, int.
	P._level = P._level
	
	var i = -1
	_stats_value_all_column1_label.bbcode_enabled = true
	_stats_value_all_column2_label.bbcode_enabled = true
	
	_stats_value_all_column1_label.text = ""
	_stats_value_all_column2_label.text = ""
	
	# add the stats values, such as, str value, def value.
	for d in P.character_stats[str(P._number)]["_loaded"].values():
		i += 1
		if i <= 5:
			if i == 0:
				_stats_value_all_column1_label.text += "\n"
			else:
				_stats_value_all_column1_label.text += str(d).pad_zeros(3) + "\n"
		else:
			if i == 6:
				_stats_value_all_column2_label.text += "\n"
			else:
				_stats_value_all_column2_label.text += str(d).pad_zeros(3) + "\n"
				
	# display the health and health max.
	if get_node("Background/HealthText") != null:
		_health_text = get_node("Background/HealthText")
		_health_text.text = str(P.character_stats[str(P._number)]["_loaded"].HP).pad_zeros(4) + "/" + str(P.character_stats[str(P._number)]["_loaded"].HP_max).pad_zeros(4)
	
	# healthbar	
	var _t: float = P.character_stats[str(P._number)]["_loaded"].HP
	var _t_max: float = P.character_stats[str(P._number)]["_loaded"].HP_max
	_health_percentage.text = str(int((_t / _t_max) * 100)) + "%"
	
	_on_HealthBar_value_changed(P.character_stats[str(P._number)]["_loaded"].HP)
	
	
	
	# display the mana and mana max.
	if get_node("Background/MagicText") != null:
		_mana_text = get_node("Background/MagicText")
		_mana_text.text = str(P.character_stats[str(P._number)]["_loaded"].MP).pad_zeros(4) + "/" + str(P.character_stats[str(P._number)]["_loaded"].MP_max).pad_zeros(4)
	
	# Magicbar	
	_t = P.character_stats[str(P._number)]["_loaded"].MP
	_magic_percentage.text = "0%"
	
	_t_max = 0
	if P.character_stats[str(P._number)]["_loaded"].MP_max > 0:
		_t_max = P.character_stats[str(P._number)]["_loaded"].MP_max
		_magic_percentage.text = str(int((_t / _t_max) * 100)) + "%"
	
		_on_MagicBar_value_changed(P.character_stats[str(P._number)]["_loaded"].MP)
	
	
	var _str = Common._skills_loaded_total()
	_misc_value_all_column1_label.text = _str + "\n" + str(P._level + 1)
	
	
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
	
	
