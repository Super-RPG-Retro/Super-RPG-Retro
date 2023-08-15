"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends GridMap


@onready var _player := $Player

 
func _ready():
	# TODO: use builder var here.
	var img = preload("res://bundles/assets/images/textures/7.png")
	
	get_node("../Floor").get_active_material(0).set("albedo_texture", img)
	
	img = preload("res://bundles/assets/images/textures/15.png")
	
	get_node("../Ceiling").get_active_material(0).set("albedo_texture", img)
	
	
	var _e = -1
	
	# place the blocks on the main map.
	for _y in range (100):
		for _x in range (100):
			_e += 1
			if _e >= 10000:
				break
			
			# x, z, y, block id.
			self.set_cell_item(Vector3i(_x, 0, _y), Builder_playing._library_cell.data.cell_item[_e] - 1)
	
			if Builder_playing._library_cell.data.cell_item[_e] >= 96 && Builder_playing._library_cell.data.cell_item[_e] <= 99:
				_player.position.x = _x + 1
				_player.position.z = _y + 1
	
				Variables._player_target_rotation = (Builder_playing._library_cell.data.cell_item[_e] - 96) * 90
