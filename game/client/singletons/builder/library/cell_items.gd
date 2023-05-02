"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# remember to delete the settings file at user:// after adding something here, else you will receive a run time error.
extends Node
var data = {
	"mesh_library": 			[],
	"cell_items":		[],
}
	
func init():
	data = {	
	"mesh_library": 			[],
	"cell_items":		[],
}	
	

func all_array_append():	
	for _n in range (10):
		data.mesh_library.append([])
	
	var _e = -1
	
	for _y in range (100):
		for _x in range (100):
			_e += 1
			if _e >= 10000:
				break
				
			data.cell_items.append(-1)


func reset_game():
	data.mesh_library.clear()
	data.cell_items.clear()
	
	# recreate the arrays in this func.
	all_array_append()
	
	Filesystem.save("user://saved_data/builder_library_cell_items_" + str(Builder._config.game_id) + ".txt", Builder._library_cell_items.data)
	

func _exit_tree():
	call_deferred("remove_child", data)	
	call_deferred("queue_free", data)
	
	queue_free()
