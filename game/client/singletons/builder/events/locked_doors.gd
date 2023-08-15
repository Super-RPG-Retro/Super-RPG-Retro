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
	for x in range (Variables._total_builder_data_directories):
		data.dungeon_number.append([])
		data.level_number.append([])
		data.unlock_at_dungeon_number.append([])
		data.unlock_at_level_number.append([])
		data.event_enabled.append([])
		data.sprite_index.append([])
		data.story_text.append([])
		data.is_finished.append([])
		
		# dungeon number.
		for y in range (8):
			data.dungeon_number[x].append([])
			data.level_number[x].append([])
			data.unlock_at_dungeon_number[x].append([])
			data.unlock_at_level_number[x].append([])
			data.event_enabled[x].append([])
			data.sprite_index[x].append([])
			data.story_text[x].append([])
			data.is_finished[x].append([])
			
			# 8 dungeons times 100 levels is the total events. 803 value is plenty of events for the game.
			for _z in range (803):			
				data.dungeon_number[x][y].append(0)
				data.level_number[x][y].append(0)
				data.unlock_at_dungeon_number[x][y].append(0)
				data.unlock_at_level_number[x][y].append(0)
				data.event_enabled[x][y].append(0)
				data.sprite_index[x][y].append(0)
				data.story_text[x][y].append("")
				data.is_finished[x][y].append(0)
	

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
