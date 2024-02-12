"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# remember to delete the settings file at user:// after adding something here, else you will receive a run time error.
# game builder, creator, construction set variables.
extends Node


var data := {
	"dungeon_number": 			[],
	"level_number": 			[],
	"unlock_at_dungeon_number": [], # unlock door here.
	"unlock_at_level_number": 	[],
	"event_number":		0,
	"event_enabled":			[],
	# when selecting the event_number, this var is used to change the sprite texture.
	"sprite_index":				[],
	"story_text": 				[],
	# is this event finished.
	"is_finished":				[], 
}


func init():
	data = {	
	"dungeon_number": 			[],
	"level_number": 			[],
	"unlock_at_dungeon_number": [],
	"unlock_at_level_number": 	[],
	"event_number":				0,
	"event_enabled":			[],
	"sprite_index":				[],
	"story_text": 				[],
	# is this event finished.
	"is_finished":				[], 
	}	
	

func all_array_append():
	# 800
	# array not listed here will have a value of zero.
	data.dungeon_number = Builder._data.level_size.duplicate(true)
	data.level_number = Builder._data.level_size.duplicate(true)
	data.unlock_at_dungeon_number = Builder._data.level_size.duplicate(true)
	data.unlock_at_level_number = Builder._data.level_size.duplicate(true)
	data.event_enabled = Builder._data.level_size.duplicate(true)
	data.sprite_index = Builder._data.level_size.duplicate(true)
	data.is_finished = Builder._data.level_size.duplicate(true)
	data.story_text = Builder._data.accepting_text.duplicate(true)
	

func reset_game():
	data.dungeon_number.clear()
	data.level_number.clear()
	data.unlock_at_dungeon_number.clear()
	data.unlock_at_level_number.clear()
	data.event_enabled.clear()
	data.sprite_index.clear()
	data.story_text.clear()
	data.is_finished.clear()
	
	# recreate the arrays in this func.
	all_array_append()
	
	Filesystem.save("user://saved_data/builder_event_locked_doors_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_locked_doors.data)
	

func _exit_tree():
	call_deferred("remove_child", data)	
	call_deferred("queue_free", data)
	
	queue_free()
