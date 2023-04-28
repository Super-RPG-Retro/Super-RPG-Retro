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

	
func _input(event):
	Variables._mouse_cursor_position.x = get_global_mouse_position().x
	Variables._mouse_cursor_position.y = get_global_mouse_position().y
	
	# this is for the small panel. if arrow up button is clicked then stats name, xp, etc is shown. if down arrow button is clicked then str, def, con, etc is shown.
	if event is InputEventMouseButton && event.is_action_pressed("ui_left_mouse_click") && Variables._child_scene_open == false || event is InputEventMouseButton && event.is_action_pressed("ui_left_mouse_click") && Variables._child_scene_open == true && Variables._at_scene == Enum.Scene.Main_Menu:		
		#right side of scene.
		if get_node("Background/ArrowUp").has_focus() || get_node("Background/ArrowDown").has_focus():
			if get_node("Background/ArrowUp").has_focus():
				P._number += 1
				
			if get_node("Background/ArrowDown").has_focus():
				P._number -= 1
			
			P._number = int(clamp(P._number, 0, P.character_stats.size() - 1))
				
			if get_node("Background/ArrowUp").has_focus() == true || get_node("Background/ArrowDown").has_focus() == true:
				if Settings._system.sound == true:
					if $SoundClick.is_playing() == false:
						$SoundClick.play()
		
			
			_update_one_player_panel()
	
	
func _update_stats():
	_health_bar.max_value = P.character_stats[str(P._number)]["_saved"].HP_max
	_health_bar.value = P.character_stats[str(P._number)]["_saved"].HP
	
	_magic_bar.max_value = P.character_stats[str(P._number)]["_saved"].MP_max
	_magic_bar.value = P.character_stats[str(P._number)]["_saved"].MP
	
	if self.visible == true:
		_update_one_player_panel()
		
		
func _update_one_player_panel():
	_health_bar.max_value = P.character_stats[str(P._number)]["_saved"].HP_max
	_on_HealthBar_value_changed(P.character_stats[str(P._number)]["_saved"].HP)
	
	var _t: float = P.character_stats[str(P._number)]["_saved"].HP
	var _t_max: float = P.character_stats[str(P._number)]["_saved"].HP_max
	_health_percentage.text = str(int((_t / _t_max) * 100)) + "%"
	
	_health_text.text = str(_t).pad_zeros(4) + "/" + str(_t_max).pad_zeros(4)
	
	_magic_bar.max_value = P.character_stats[str(P._number)]["_saved"].MP_max
	_on_MagicBar_value_changed(P.character_stats[str(P._number)]["_saved"].MP)
		
	_t = P.character_stats[str(P._number)]["_saved"].MP
	
	_t_max = 0
	_magic_percentage.text = "0%"
	
	if P.character_stats[str(P._number)]["_saved"].MP_max > 0:
		_t_max = P.character_stats[str(P._number)]["_saved"].MP_max
		_magic_percentage.text = str(int((_t / _t_max) * 100)) + "%"
	
	_mana_text.text = str(_t).pad_zeros(4) + "/" + str(_t_max).pad_zeros(4)

	stats_saved_text_all_update()
	stats_saved_value_all_update()


func stats_saved_empty():
	self.visible = false
	Variables._is_saved_id_panel_visible = false	

	
func stats_saved_value_all_update():
	call_deferred("stats_saved_value_all_update2")
	
	var _file = File.new()
	if _file.file_exists("user://saved_data/" + str(Variables._id_of_saved_game) + "/username.txt"):
		self.visible = true
		Variables._is_saved_id_panel_visible = true

	else:
		stats_saved_empty()

# draw all stats text. not the value. So "Luck" text is displayed but not the value of it.
func stats_saved_text_all_update():
	
	var i = -1
	_stats_text_all_column1_label.bbcode_enabled = true
	_stats_text_all_column2_label.bbcode_enabled = true
	
	for d in P.character_stats[str(P._number)]["_saved"].keys():
		i += 1
		if i <= 5:
			if d == "Class":
				d = ""
							
			_stats_text_all_column1_label.bbcode_text += "[right]" + str(d) + "[/right]\n"
		else:
			if d == "Level":
				d = ""
			
			_stats_text_all_column2_label.bbcode_text += "[right]" + str(d) + "[/right]\n"


# this func is called when the game id value is changed at the main menu. this updates the game data saved panel. this func updates the values of P.character_stats. for example, not the text of "Luck" but instead its value.
func stats_saved_value_all_update2():	
	_on_HealthBar_value_changed(P.character_stats[str(P._number)]["_saved"].HP)
	_on_MagicBar_value_changed(P.character_stats[str(P._number)]["_saved"].MP)
	
	_username_value_label.text = P.character_stats[str(P._number)]["_saved"].Username + " - " + P.character_name[str(P._number)]
	
	if P.character_stats[str(P._number)]["_saved"].XP == 0:
		P.character_stats[str(P._number)]["_saved"].XP = P._xp_level[P.character_stats[str(P._number)]["_saved"].Level]
	
	# display xp_next at stats.
	_xp_value_label.text = str(P.character_stats[str(P._number)]["_saved"].XP)
	_xp_next_value_label.text = str(P.character_stats[str(P._number)]["_saved"].XP_next)
	
	if P.character_stats[str(P._number)]["_saved"].Level < 999:
		_xp_next_value_label.text = str(P._xp_level[P.character_stats[str(P._number)]["_saved"].Level + 1]) 
	
	
	var i = -1
	_stats_value_all_column1_label.bbcode_enabled = true
	_stats_value_all_column2_label.bbcode_enabled = true
	
	_stats_value_all_column1_label.bbcode_text = ""
	_stats_value_all_column2_label.bbcode_text = ""
	
	for d in P.character_stats[str(P._number)]["_saved"].values():
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

	_health_text.text = str(P.character_stats[str(P._number)]["_saved"].HP).pad_zeros(4) + "/" + str(P.character_stats[str(P._number)]["_saved"].HP_max).pad_zeros(4)
	_mana_text.text = str(P.character_stats[str(P._number)]["_saved"].MP).pad_zeros(4) + "/" + str(P.character_stats[str(P._number)]["_saved"].MP_max).pad_zeros(4)
	

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
