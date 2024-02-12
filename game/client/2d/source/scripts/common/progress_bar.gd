"""
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends ProgressBar


func _ready():
	pass


func _process(delta):
	if Variables._progress_bar_current_value > 0:
		visible = true
	else:
		visible = false
	
	self.value = Variables._progress_bar_current_value
	self.max_value = Variables._progress_bar_max_value
	
	
	
	
	
