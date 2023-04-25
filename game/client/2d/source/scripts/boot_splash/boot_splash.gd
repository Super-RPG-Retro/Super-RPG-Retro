"""
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

onready var _sprite = $Sprite

func _ready():
	Filesystem._make_saved_data_directories()

	P._update_character_stats_loaded()
	P._update_character_stats_saved()
	P.reset()

	# generate the xp levels.
	P.xp_table()

	Common._game_title()
	Builder.reset_config()

	# initiate all builder data.
	Builder._all_init()
	
	var file = File.new()
	var _err

	if not file.file_exists("user://saved_data/builder_config.txt"):
		Builder.all_array_append()


	Filesystem.builder_load_data()

