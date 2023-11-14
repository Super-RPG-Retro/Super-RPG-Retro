"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Control


# close the "/?" scene.
func _input(event):
	if (event.is_pressed()):
		if (event.is_action_pressed("ui_escape", true)) and Variables._trigger_commands != Enum.Trigger_commands.Unit_description and Variables._game_help.visible == true:
			# clear event scancode, so elsewhere the keypress will not trigger.
			event.keycode = 0 
			self.visible = false


func _on_ButtonExit_pressed():
	self.visible = false
	
	
	
	
	
	
