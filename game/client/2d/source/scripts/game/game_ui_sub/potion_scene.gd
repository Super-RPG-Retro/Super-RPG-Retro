"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


func _ready():
	set_label(1, Variables._potion_impair_vision_turns)
	set_label(2, Variables._potion_healing_turns)
	set_label(3, Variables._potion_poison_turns)
	set_label(4, Variables._potion_mana_turns)
		

# this is called from game/try_move func.
func set_label(_potion_num, _move_turns):
	get_node("Control/Label" + str(_potion_num)).text =  str(_move_turns).pad_zeros(2)
	
	
	
	
	
