"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# this file holds the dictionary data for each inventory item. the display of these items are at the inventory panel.
extends Node


var _item_total			:= 0

var _file_name 			:= []
var _file_path 			:= []
var _image_texture 		:= []
var _directory_name 	:= []

var _paper := {
				"Description": "Increments your score by 1.",
}

var _potion := {
			"potion_impair_vision": 
			{
				"ID": 0,
				"Description": "Limited sight range in this dungeon.",
			},
			
			"potion_healing": 	
			{
				"ID": 1,
				"Description": "Gain 2 HP for each game turn.",
			},
			
			"potion_poison":
			{
				"ID": 2,
				"Description": "Lose 1 HP for each game turn. Healing potions will not work while this potion is in effect.",
			},
			
			"potion_mana":		
			{
				"ID": 3,
				"Description": "Gain 2 HP for each game turn.",
			},
	  
}

func drop_items() -> String:
	var _name:String = "" # name of the item that was dropped.
	
	var _i = randi() % 4 
			
	match (_i):
		0:	_name = "Potion impair vision"
		1:	_name = "Potion Healing"
		2:	_name = "Potion Poison" 
		3:	_name = "Potion Mana"
	
	return _name

# build of list, including the name and image of all available inventory in this game that was created at the inventory section at builder.	
func build():
	var _stop:bool = false
	
	var _i = -1
	_item_total = 0
	
	_file_name.clear()
	_file_path.clear()
	_image_texture.clear()
	_directory_name.clear()
	
	for _w in range (8): # dungeon number
		for _x in range (100): # event number
			for _y in range (20):
				if Builder._event_inventory.data.file_name[Builder._config.game_id][_w][_x][_y].is_empty() == false:
					for _r in range (Builder._event_inventory.data.file_name[Builder._config.game_id][_w][_x][_y].size()): 	
						# Builder._event_inventory.data.file_name was populated at builder. the _file_name here can be access using Inventory._file_name[1, 2, etc]
						# the directory name here can be used at Json.gd to get its description or any other data that is needed.
						_file_name.push_back(Builder._event_inventory.data.file_name[Builder._config.game_id][_w][_x][_y][_r])
						_file_path.push_back(Builder._event_inventory.data.file_path_json[Builder._config.game_id][_w][_x][_y][_r])
						_image_texture.push_back(Builder._event_inventory.data.image_texture[Builder._config.game_id][_w][_x][_y][_r])
						_directory_name.push_back(Builder._event_inventory.data.directory_name[Builder._config.game_id][_w][_x][_y][_r])
						
						_item_total += 1
					
					
		
		# reset this var for the next event number so that items can be found starting from index 0 again.
		_i = -1
		
		if _stop == true:
			break
	
# current inventory item has just been selected for use. this is the action of that event.
func use(_num:int):
	pass
	#print(_file_name[_num])
		

# when someone drops an item, this enum is used to select an item from the available list. see random drop item at reference constructor at game.scene
enum selected {Paper, Potion}
