"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

onready var _coordinates_label = $CoordinatesLabel
onready var _clock_sprite = $ClockSprite
onready var _clock_label = $ClockLabel


func _ready():
	$ScoreLabel.text = str(Hud._loaded.Score)
	
	# start at library
	if Variables._at_library == true:
		$DungeonSprite.visible = false
		$LibrarySprite.visible = true
		
	else:
		$DungeonSprite.visible = true
		$LibrarySprite.visible = false
	
	clock()
	
	set_label(1, Variables._potion_impair_vision_turns)
	set_label(2, Variables._potion_healing_turns)
	set_label(3, Variables._potion_poison_turns)
	set_label(4, Variables._potion_mana_turns)
		
	
func clock():
	if Settings._game.clock == true:
		$ClockSprite.visible = true
		$ClockLabel.visible = true
	
	else:
		$ClockSprite.visible = false
		$ClockLabel.visible = false
		
		
func _process(_delta):
	label_text()
	_clock_label.text = Variables._time
	$GoldLabel.text = str(Hud._loaded.Gold)
	$FoodLabel.text = str(Hud._loaded.Food)
	
	
func _unhandled_input(event: InputEvent):
	if Variables._game_over == true:
		return
	
	if Variables._keyboard_tab_pressed == true:
		return
	
	if Variables._child_scene_open == true:
		return
		
	$ScoreLabel.text = str(Hud._loaded.Score)
	
	if Variables._at_library == false:
		$DungeonSprite.visible = true
		$LibrarySprite.visible = false
		
		if event.is_action_pressed("ui_up", true):
			Variables._compass = "N"
			Hud._loaded.Turns += 1
			
		elif event.is_action_pressed("ui_down", true):
			Variables._compass = "S"
			Hud._loaded.Turns += 1
			
		elif event.is_action_pressed("ui_left", true):
			Variables._compass = "W"
			Hud._loaded.Turns += 1
		
		elif event.is_action_pressed("ui_right", true):
			Variables._compass = "E"
			Hud._loaded.Turns += 1
				
	elif Variables._compass_update == true:
		$DungeonSprite.visible = false
		$LibrarySprite.visible = true
		
		if event.is_action_pressed("ui_left", true):
			if Variables._compass == "N":
				Variables._compass = "W"
			
			elif Variables._compass == "W":
				Variables._compass = "S"
		
			elif Variables._compass == "S":
				Variables._compass = "E"
		
			elif Variables._compass == "E":
				Variables._compass = "N"
			Variables._compass_update = false
			
		elif event.is_action_pressed("ui_right", true):
			if Variables._compass == "N":
				Variables._compass = "E"
			
			elif Variables._compass == "E":
				Variables._compass = "S"
		
			elif Variables._compass == "S":
				Variables._compass = "W"
		
			elif Variables._compass == "W":
				Variables._compass = "N"
			
			Variables._compass_update = false
			
func label_text():
	_coordinates_label.text = str(Variables._dungeon_number + 1) + "-" + str(Settings._game.level_number + 1) + " (" + Variables._dungeon_coordinates + ") " + Variables._compass


# this is called from game/try_move func.
func set_label(_potion_num, _move_turns):
	get_node("Label" + str(_potion_num)).text =  str(_move_turns).pad_zeros(3)
