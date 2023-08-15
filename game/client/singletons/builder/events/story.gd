"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# remember to delete the settings file at user:// after adding something here, else you will receive a run time error.
extends Node


var data := {
	"dungeon_number": 		[],
	"level_number": 		[],
	"event_number":			0,
	"event_enabled":		[],
	"file_name":			[], # json file name.
	"file_path_json":		[], # json file path.
	"image_texture":		[], # json image.
	"directory_name":		[], # eg, mobs1, gold, weapon,
	"story_text": 			[],
	"is_finished":			[],
}
	
func init():
	data = {	
	"dungeon_number": 		[],
	"level_number": 		[],
	"event_number":			0,
	"event_enabled":		[],
	"file_name":			[], # json file name.
	"file_path_json":		[], # json file path.
	"image_texture":		[], # json image.
	"directory_name":		[], # eg, mobs1, gold, weapon,
	"story_text": 			[],
	"is_finished":			[],
	}	
	

func all_array_append():	
	for w in range (Variables._total_builder_data_directories):
		data.dungeon_number.append([])
		data.level_number.append([])
		data.event_enabled.append([])
		data.file_name.append([])
		data.file_path_json.append([])
		data.image_texture.append([])
		data.directory_name.append([])
		data.story_text.append([])
		data.is_finished.append([])
		
		# dungeon number.
		for x in range (8):
			data.dungeon_number[w].append([])
			data.level_number[w].append([])
			data.event_enabled[w].append([])
			data.file_name[w].append([])
			data.file_path_json[w].append([])
			data.image_texture[w].append([])
			data.directory_name[w].append([])
			data.story_text[w].append([])
			data.is_finished[w].append([])
			
			# 8 dungeons times 100 levels is the total events. 803 value is plenty of events for the game.
			for y in range (803):		
				data.dungeon_number[w][x].append(0)
				data.level_number[w][x].append(0)
				data.event_enabled[w][x].append(0)
				data.file_name[w][x].append([])
				data.file_path_json[w][x].append([])
				data.image_texture[w][x].append([])
				data.directory_name[w][x].append([])
				data.story_text[w][x].append("")
				data.is_finished[w][x].append(0)
				
				# directory index
				for _z in range (20):
					data.file_name[w][x][y].append([])
					data.file_path_json[w][x][y].append([])
					data.image_texture[w][x][y].append([])
					data.directory_name[w][x][y].append([])
			
func reset_game():
	data.dungeon_number.clear()
	data.level_number.clear()
	data.event_enabled.clear()
	data.file_name.clear()
	data.file_path_json.clear()
	data.image_texture.clear()
	data.directory_name.clear()
	data.story_text.clear()
	data.is_finished.clear()
	
	# recreate the arrays in this func.
	all_array_append()
	
	Filesystem.save("user://saved_data/builder_event_story_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_story.data)
	

func _exit_tree():
	call_deferred("remove_child", data)	
	call_deferred("queue_free", data)
	
	queue_free()
