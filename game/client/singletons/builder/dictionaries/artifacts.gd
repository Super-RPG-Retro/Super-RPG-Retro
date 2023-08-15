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
	"artifact_number":			0,
	"file_name":			[], # json file name.
	"file_path_json":		[], # json file path.
	"image_texture":		[], # json image.
	"directory_name":		[], # eg, mobs1, gold, weapon,
	
	"owned": 				[],
	"is_active": 			[],
	
	"Charisma": 			[],
	"Constitution": 		[],
	"Defense": 				[],
	"Dexterity": 			[],
	"Intelligence": 		[],
	"Luck": 				[],
	"Perception": 			[],
	"Strength": 			[],
	"Willpower": 			[],
	"Wisdom": 				[],
}


func init():
	data = {
	"artifact_number":			0,
	"file_name":			[], # json file name.
	"file_path_json":		[], # json file path.
	"image_texture":		[], # json image.
	"directory_name":		[], # eg, mobs1, gold, weapon,	
	"owned": 				[],
	"is_active": 			[],	
	"Charisma": 			[],
	"Constitution": 		[],
	"Defense": 				[],
	"Dexterity": 			[],
	"Intelligence": 		[],
	"Luck": 				[],
	"Perception": 			[],
	"Strength": 			[],
	"Willpower": 			[],
	"Wisdom": 				[],
	
}
	

func all_array_append():
	for _i in range (50):
		data.file_name.append("")
		data.file_path_json.append("")
		data.image_texture.append("")	
		data.directory_name.append("")
		
		data.owned.append(false)
		data.is_active.append(false)
	
		data.Charisma.append(0)
		data.Constitution.append(0)
		data.Defense.append(0)
		data.Dexterity.append(0)
		data.Intelligence.append(0)
		data.Luck.append(0)
		data.Perception.append(0)
		data.Strength.append(0)
		data.Willpower.append(0)
		data.Wisdom.append(0)
		
		# if you add a artifact var here, remember to clear it at Builder.home.tscn scene, func _copy_files_to_artifacts_directory()

func reset_game():
	data.file_name.clear()
	data.file_path_json.clear()
	data.image_texture.clear()
	data.directory_name.clear()
	
	data.owned.clear()
	data.is_active.clear()

	data.Charisma.clear()
	data.Constitution.clear()
	data.Defense.clear()
	data.Dexterity.clear()
	data.Intelligence.clear()
	data.Luck.clear()
	data.Perception.clear()
	data.Strength.clear()
	data.Willpower.clear()
	data.Wisdom.clear()
		
	# recreate the arrays in this func.
	all_array_append()	
	
	Filesystem.save("user://saved_data/builder_dictionary_artifacts_" + str(Builder._config.game_id) + ".txt", Builder._dictionary_artifacts.data)
	
	
func _exit_tree():
	call_deferred("remove_child", data)	
	call_deferred("queue_free", data)
	
	queue_free()
