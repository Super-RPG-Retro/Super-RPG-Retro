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


var data = {
	"file_name":			[], # json file name.
	"id":					[], # ItemList current selected position.
}


func init():
	data = {
	"file_name":			[],
	"id":					[],
	
}
	

func all_array_append():
	for _i in range (9):
		data.file_name.append(Variables._music[str(_i)])
		data.id.append(_i)

func reset_game():
	data.file_name.clear()
	data.id.clear()
		
	# recreate the arrays in this func.
	all_array_append()	
	
	Filesystem.save("user://saved_data/builder_audio_music_" + str(Builder._config.game_id) + "_" + str(Builder._data.dungeon_number) + ".txt", Builder._audio_music)
	
	
func _exit_tree():
	call_deferred("remove_child", data)	
	call_deferred("queue_free", data)
	
	queue_free()
