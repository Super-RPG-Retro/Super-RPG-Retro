"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# status bar.
extends Panel


@onready var _game_id := $GameID


func _ready():
	pass


func _input(_delta):
	_game_id.text = "Game ID: " + str(Builder_playing._config.game_id) + "    " + "Dungeon: " + str(Builder_playing._config.dungeon_number) + "    "
	
	if Builder_playing._config.level_number > 0:
		_game_id.text += "Level: " + str(Builder_playing._config.level_number)


func _on_StatusBar_tree_exiting():
	_game_id.queue_free()
	queue_free()
