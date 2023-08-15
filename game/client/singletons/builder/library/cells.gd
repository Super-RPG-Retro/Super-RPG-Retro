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
	# all cell mesh, player and items etc. this var is used to create the library.
	"cell_item":					[],
	"player_starting_direction":	0,	# when game first starts.
}
	
func init():
	data = {	
	"cell_item":					[],
	"player_starting_direction":	0,
}	
	

func all_array_append():		
	var _e = -1
	
	for _y in range (100):
		for _x in range (100):
			_e += 1
			if _e >= 10000:
				break
			
			# first row and last row in maze.
			if _y == 0 && _x < 16 || _y == 15 && _x < 16 || _y == 7 && _x < 8:
				data.cell_item.append(1)
			
			# left / right border of maze.
			elif _y < 16 && _x == 0 || _y < 16 && _x == 15:
				data.cell_item.append(1)
			
			else:
				data.cell_item.append(0)

	# at default maze layout the player starts here.
	data.cell_item[302] = 96 # player facing north.
	
	
func reset_game():
	data.cell_item.clear()
	data.player_starting_direction = 0
	
	# recreate the arrays in this func.
	all_array_append()
	
	Filesystem.save("user://saved_data/builder_library_cells_" + str(Builder._config.game_id) + ".txt", Builder._library_cell.data)
	

func _exit_tree():
	call_deferred("remove_child", data)	
	call_deferred("queue_free", data)
	
	queue_free()
