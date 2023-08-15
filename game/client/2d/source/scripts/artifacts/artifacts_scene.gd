"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


const _artifacts:= []

func _ready():
	Builder_playing._dictionary_artifacts.data.owned[0] = false
	Builder_playing._dictionary_artifacts.data.owned[1] = true
	Builder_playing._dictionary_artifacts.data.owned[2] = false
	draw_Artifacts_icons()

# draw Artifacts to scene.
func draw_Artifacts_icons():
	if Variables._child_scene_open == true:
		return
	
	if !_artifacts.is_empty():
		_artifacts.clear()
		
	var _i = -1
	# loop through all Artifacts.
	for _r in range (50):
		_i += 1
		
		if Builder_playing._dictionary_artifacts.data.file_name[_r] != "":
			# set each image texture to a node. the node is TextureRect. the reason is to get the mouse entering/exiting events.			
			get_node("Artifacts/Sprite2D" + str(_r + 1)).texture = Filesystem._load_external_image(Builder_playing._dictionary_artifacts.data.image_texture[_r])
			
			if bool(Builder_playing._dictionary_artifacts.data.owned[_r]) == false:
				get_node("Artifacts/Sprite2D" + str(_r + 1)).modulate = Color(0, 0, 3, 20) # blue shade
			
			# remove signals because we are about to add new signals for this group.
			if get_node("Artifacts/Sprite2D" + str(_i + 1)).is_connected("mouse_entered", Callable(self, "_on_mouse_entered")):
				get_node("Artifacts/Sprite2D" + str(_i + 1)).disconnect("mouse_entered", Callable(self, "_on_mouse_entered"))
				
				get_node("Artifacts/Sprite2D" + str(_i + 1)).disconnect("mouse_exited", Callable(self, "_on_mouse_exited"))
				
			# create the signals for the mouse entering /exiting the nodes.
			var _y = get_node("Artifacts/Sprite2D" + str(_i + 1)).connect("mouse_entered", Callable(self, "_on_mouse_entered").bind(_i))

			var _z = get_node("Artifacts/Sprite2D" + str(_i + 1)).connect("mouse_exited", Callable(self, "_on_mouse_exited"))
			
			if _i == 23:
				break
