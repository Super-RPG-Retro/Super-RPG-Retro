"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

var _list_rune = []
var _num = 0


func _ready():
	Variables._child_scene_open = true
	Variables._scene_title = "Rune Help."
	
	for _key in Json._magic.keys():
		_list_rune.push_back(_key)
	
	# game crashed at this line? this could work... delete the saved_data directory, run the game. click play button, exit the game then delete this builder/magic/data/1,2,3,4,5,6,7,8 directories then the game will run normally.
	# keep builder/magic/data directory.
	overview(_list_rune[0], 0) 

func _input(event):
	if (event.is_pressed()):
		if (event.is_action_pressed("ui_escape", true)) && Variables._child_scene_open == true && Variables._trigger_commands != Enum.Trigger_commands.Unit_description && Variables._rune_help.visible == true:
			# clear event scancode, so elsewhere the keypress will not trigger.
			event.scancode = 0 
			Variables._child_scene_open = false
			self.visible = false
	
		if (event.is_action_pressed("ui_left", true)):
			_on_Arrow_left_data_input(event)
		
		if (event.is_action_pressed("ui_right", true)):
			_on_Arrow_right_data_input(event)
		
func overview(_name, num):
	_num = num
	_list_rune.clear()

	for _key in Json._magic.keys():
		_list_rune.push_back(_key)
	
	var _abbreviation = Json._magic[_name]["Abbreviation"]
	var _level = Json._magic[_name]["Level"]
	var _element = Json._magic[_name]["Element"]
	var _turns = Json._magic[_name]["Turns"]
	var _range = Json._magic[_name]["Range"]
	var _location = Json._magic[_name]["Location"]
	var _group = Json._magic[_name]["Group"]
	var _gold = Json._magic[_name]["Gold"]
	var _discription = Json._magic[_name]["Description"]
	var _strength = Json._magic[_name]["Strength"]
	var _defense = Json._magic[_name]["Defense"]
	var _dice = Json._magic[_name]["Dice"]
		
	# display the rune information.
	get_node("Panel/PanelHelp/Label").bbcode_text = "\r\n                                   " + _name.replace("_", " ") + "\r\n\r\n\r\n" + "\r\n[table=10][cell] Level [/cell][cell][color=#00cc00]" + str(_level) + "[/color][/cell][/table][table=10][cell] Gold [/cell][cell][color=#00cc00]" + str(_gold) + "[/color][/cell][/table][table=10][cell] Element [/cell][cell][color=#00cc00]" + str(_element) + "[/color][/cell][/table][table=10][cell] Turns [/cell][cell][color=#00cc00]" + str(_turns) + "[/color][/cell][/table][table=10][cell] Range [/cell][cell][color=#00cc00]" + str(_range) + "[/color][/cell][/table]" + "\r\n\r\n" + "[table=10][cell] Discription [/cell][cell][color=#00cc00]" + str(_discription) + "[/color][/cell][/table]"
	
	get_node("Panel/PanelHelp/Label2").bbcode_text = "\r\n\r\n\r\n\r\n" + "\r\n[table=10][cell] Strength [/cell][cell][color=#00cc00]" + str(_strength) + "[/color][/cell][/table][table=10][cell] Defense [/cell][cell][color=#00cc00]" + str(_defense) + "[/color][/cell][/table][table=10][cell] Dice [/cell][cell][color=#00cc00]" + str(_dice) + "[/color][/cell][/table][table=10][cell] Location [/cell][cell][color=#00cc00]" + str(_location) + "[/color][/cell][/table][table=10][cell] Group [/cell][cell][color=#00cc00]" + str(_group) + "[/color][/cell][/table]"
	
	get_node("Panel/PanelHelp/Abbreviation").bbcode_text = "\r\n[table=2][cell]  Abbreviation: [/cell][cell][color=#00cc00]" + str(_abbreviation) + "[/color][/cell][cell][/cell][/table]"

	# display the rune number.
	get_node("Panel/RuneNumber").bbcode_text = "[table=2][cell]#[color=#00cc00]" + str(_num + 1) + "[/color][/cell][/table]"
	
	get_node("Panel/RuneImage").texture = load("res://bundles/assets/images/magic/" + _name.to_lower().replace(" ", "_") + ".png")

func _on_Arrow_left_data_input(event):
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT and event.pressed || (event.is_action_pressed("ui_left", true)):
			_num -= 1 
			
			if _num < 0: 
				_num = _list_rune.size() - 1
				
			overview(_list_rune[_num], _num)


func _on_Arrow_right_data_input(event):
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT and event.pressed || (event.is_action_pressed("ui_right", true)):
			_num += 1 
						
			if _num > _list_rune.size() - 1: 
				_num = 0				
			
			overview(_list_rune[_num], _num)


func _on_ButtonExit_pressed():
	Variables._child_scene_open = false
	self.visible = false


func _on_ArrowLeft_focus_entered():
	get_node("Panel/ArrowLeft").modulate = Color(1, 0.5, 0.5, 1)


func _on_ArrowLeft_focus_exited():
	get_node("Panel/ArrowLeft").modulate = Color(1, 1, 1, 1)


func _on_ArrowRight_focus_entered():
	get_node("Panel/ArrowRight").modulate = Color(1, 0.5, 0.5, 1)


func _on_ArrowRight_focus_exited():
	get_node("Panel/ArrowRight").modulate = Color(1, 1, 1, 1)

