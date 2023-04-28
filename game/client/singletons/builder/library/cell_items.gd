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
	"item_name": 			[],
	"cell_items":		[],
}
	
func init():
	data = {	
	"item_name": 			[],
	"cell_items":		[],
}	
	

func all_array_append():	
	for _n in range (10):
		data.item_name.append([])
		
	# 100 x coordinates plus 100 y coordinates equals 1000 3d tiles
	for _n in range (1000):
		# a -1 value is an empty tile.
		data.cell_items.append(Vector2(-1, -1))


func reset_game():
	data.item_name.clear()
	data.cell_items.clear()
	
	# recreate the arrays in this func.
	all_array_append()
	
	Filesystem.save("user://saved_data/builder_library_cell_items_" + str(Builder._config.game_id) + ".txt", Builder._library_cell_items.data)
	

func _exit_tree():
	call_deferred("remove_child", data)	
	call_deferred("queue_free", data)
	
	queue_free()
