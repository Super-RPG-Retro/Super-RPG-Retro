"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

onready var _accept_dialog = $AcceptDialog


func _ready():
	for _i in range(0, 2000):
		if 	P._xp >= P._xp_level[_i] && _i > P._level - 1:
			$AcceptDialog.dialog_text = "Congratulations, you are now level " + str(_i + 1) + ".\r\nYou need " + str(P._xp_level[_i + 1] - P._xp) + " more xp for your next level." 
			
			P._level = _i + 1
			# give more mp the lower the difficulty level.
			P._hp_max = int((P._level * (15 / float("1." + str(Settings._game.difficulty_level)))))
			
			P._mp_max = int((P._level * (10 / float("1." + str(Settings._game.difficulty_level)))))
			
			_accept_dialog.popup_centered()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
			break
