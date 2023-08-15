"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Camera2D


# used to shake the screen. the bigger the value, the greater the screen shake will be,
var shake_amount := 0

# screen offset value.
var default_offset := offset


func _ready():
	Variables.camera = self
	set_process(false)


func _process(delta):
	if shake_amount > 0:
		offset = Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount)) * delta + default_offset

# new_shake: 		the distance the screen will shake. the bigger the value, the greater the screen shake.
# shake_time:		for how long the screen will shake for.
# shake_limit		the distance the screen will shake does not exceed this value.
func shake(new_shake, shake_time=0.4, shake_limit=100):
	shake_amount += new_shake
	if shake_amount > shake_limit:
		shake_amount = shake_limit
	
	set_process(true)	
	$Timer.wait_time = shake_time
	$Timer.start()


# this is used to stop the shaking of the screen.
func _on_Timer_timeout():
	shake_amount = 0
	set_process(false)
