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
	"dungeon_number": 				[],
	"level_number":					[],
	"event_number":					0,
	# one event per level. is this event at this level enabled?
	"event_enabled":				[],
	
	# this holda all the rows and columns. each value refers to the state of the puzzle block. 0: floor. 1:block 1. 2:block 2.
	# s: puzzle layout at the start of the level.
	# e: puzzle layout s must look like this e before the amount of moves at move_total is made. Only then will the next_event be triggered. 
	# this var is a dupicate of coordinates_s_location at builder. while playing the game it never changes.
	# this var is used when a room is reset, coordinates_s_location will then equal this var.
	"coordinates_static_location":	[],
	"coordinates_s_location":		[],
	"coordinates_e_location":		[],
	
	# The amount of moves it takes to complete this puzzle.
	"move_total":					[],
	
	# puzzle is solved when all blcoks are this color.
	"color_when_solved":			[],
	"is_finished":					[], 
}

	
func init():
	data = {
	"dungeon_number": 				[],
	"level_number":					[],
	"event_number":					0,
	"event_enabled":				[],
	"coordinates_static_location":	[],
	"coordinates_s_location":		[],
	"coordinates_e_location":		[],
	"move_total":					[],
	"color_when_solved":			[],
	"is_finished":					[],
		
	}
	
	
func all_array_append():
	for x in range (Variables._total_builder_data_directories):
		data.dungeon_number.append([])
		data.level_number.append([])
		data.event_enabled.append([])
		data.coordinates_static_location.append([])
		data.coordinates_s_location.append([])
		data.coordinates_e_location.append([])
		data.move_total.append([])
		data.color_when_solved.append([])
		data.is_finished.append([])
		
		# dungeon number.
		for y in range (8):
			data.dungeon_number[x].append([])	
			data.level_number[x].append([])	
			data.event_enabled[x].append([])
			data.coordinates_static_location[x].append([])
			data.coordinates_s_location[x].append([])
			data.coordinates_e_location[x].append([])
			data.move_total[x].append([])
			data.color_when_solved[x].append([])
			data.is_finished[x].append([])
			
			# 8 dungeons times 100 levels is the total events. 803 value is plenty of events for the game.
			for z in range (803):		
				data.dungeon_number[x][y].append(0)
				data.level_number[x][y].append(0)
				data.event_enabled[x][y].append(0)
				data.coordinates_static_location[x][y].append([])
				data.coordinates_s_location[x][y].append([])
				data.coordinates_e_location[x][y].append([])
				data.move_total[x][y].append(0)
				data.color_when_solved[x][y].append(0)
				data.is_finished[x][y].append(0)
				
				# 169 is 13 rows starting at 1 times 13 columns starting at 1. 13 x 13 = 169.
				for _p in range (170):
					data.coordinates_static_location[x][y][z].append(0)
					data.coordinates_s_location[x][y][z].append(0)
					data.coordinates_e_location[x][y][z].append(0)
					
		
func reset_game():
	data.dungeon_number.clear()
	data.level_number.clear()
	data.event_enabled.clear()
	data.coordinates_static_location.clear()
	data.coordinates_s_location.clear()
	data.coordinates_e_location.clear()
	data.move_total.clear()
	data.color_when_solved.clear()
	data.is_finished.clear()
	
	# recreate the arrays in this func.
	all_array_append()
	
	Filesystem.save("user://saved_data/builder_event_puzzles_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._event_puzzles.data)
	

func _exit_tree():
	call_deferred("remove_child", data)	
	call_deferred("queue_free", data)
	
	queue_free()
