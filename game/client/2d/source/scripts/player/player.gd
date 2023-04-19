"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Sprite

onready var _type = ""
onready var _name = P.character_number[str(P._number)]["_stats_loaded"].Username
onready var tile = Vector2(0,  0)


func _ready():
	Common._player_now_playing_vars_update()
	
	if $Camera2D != null:
		if Settings._system.use_large_tiles == true:
			$Camera2D.zoom.x = 1
			$Camera2D.zoom.y = 1
			
		else:
			$Camera2D.zoom.x = 1.5
			$Camera2D.zoom.y = 1.5

	_change_texture()
	
	
func _change_texture():
	texture = load("res://bundles/assets/images/player_characters/" + str(P._number) + ".png")
	
	if P._number == 0:
		hframes = 3
	else:
		hframes = 1
		
		
