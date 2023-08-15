"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node3D

# Get the 3D model
@export @onready var wall1 = get_node("Wall1")


func _ready():
	var meshlib = preload("res://3d/assets/meshlibs/library.meshlib")
	
	# TODO: use builder var here.
	var img = preload("res://bundles/assets/images/textures/6.png")
	
	wall1.get_active_material(0).set("albedo_texture", img)
	
	##get_active_material
	#spatial_material.set_texture(Decal.TEXTURE_ALBEDO, image)
	
	meshlib.create_item(0)
	meshlib.set_item_name(0, "Wall1")
	meshlib.set_item_mesh(0, wall1.mesh)
	ResourceSaver.save(meshlib, "res://3d/assets/meshlibs/library.meshlib")

	var _s = get_tree().change_scene_to_file("res://2d/source/scenes/main_menu.tscn")
