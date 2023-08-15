"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# when an event is finished, this next event is called. this next event will either end doing nothing, or will go to another event.
extends ScrollContainer


@onready var _dungeon_number := $Grid/Grid1/DungeonNumberSpinbox

@onready var _level_number := $Grid/Grid2/LevelNumberSpinbox

@onready var _item_list := $Grid/HBoxContainer/ItemList

var _item_list_index:int = 0


func _ready():	
	call_deferred("_next_event")
	
	
func _next_event():
	if Variables._scene_title == "Builder: Event Story.":
		Builder._config.event_id = 1 # keep this here.
		
		_item_list_index = Builder._next_event.item_list[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_story.data.event_number][Builder._config.event_id]
		
		_dungeon_number.value = Builder._next_event.dungeon_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_story.data.event_number][Builder._config.event_id] + 1
		
		_level_number.value = Builder._next_event.level_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_story.data.event_number][Builder._config.event_id] + 1
		
	else:
		Builder._config.event_id = 0 # keep this here.
		
		_item_list_index = Builder._next_event.item_list[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][Builder._config.event_id]
		
		_dungeon_number.value = Builder._next_event.dungeon_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][Builder._config.event_id] + 1
	
		_level_number.value = Builder._next_event.level_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][Builder._config.event_id] + 1

	_item_list.select(_item_list_index)
	_item_list.ensure_current_is_visible()
	_on_ItemList_item_selected(_item_list_index)


func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
		_ready()

func _on_dungeon_number_Spinbox_value_changed(value):
	if Variables._scene_title == "Builder: Event Story.":
		Builder._next_event.dungeon_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_story.data.event_number][Builder._config.event_id] = value - 1
		
	else:
		Builder._next_event.dungeon_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][Builder._config.event_id] = value - 1


func _on_level_number_Spinbox_value_changed(value):
	if Variables._scene_title == "Builder: Event Story.":
		Builder._next_event.level_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_story.data.event_number][Builder._config.event_id] = value - 1
		
	else:
		Builder._next_event.level_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][Builder._config.event_id] = value - 1
	

func _on_ItemList_item_selected(index):
	if Variables._scene_title == "Builder: Event Story.":
		Builder._next_event.item_list[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_story.data.event_number][Builder._config.event_id] = index
	
	else:
		Builder._next_event.item_list[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_parent.event_number][Builder._config.event_id] = index
	
