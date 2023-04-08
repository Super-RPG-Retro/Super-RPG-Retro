"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node

# changes the modulate which makes the scene lighter or darker depending on what time this value is. 
var _raw_value: float = 0

var _full_moon_at_this_number: int = 5
var _full_moon: int = 0

# these ticks are used to determine time of day.
var _ticks_timestamp: int = -1
var _time:float = 0

func cycle():
	if Variables._child_scene_open == true:
		return
	
	if Settings._game.clock == false:
		reset_vars()
		return
			
	_ticks_timestamp += 1
	
	# 86400 seconds in a day / 2000 = 43.2 (0.0005)
	# 86400 seconds in a day / 20000 = 4.32 (0.00005) longer day.
	var _time_ratio = 43.2 
	
	#_raw_value = 
	# 0.0005 (12h = 2000 _ticks_timestamp)
	# 0.00005 (12h - 10000 _ticks_timestamp)
		
	if Variables._time_is_day == false && _raw_value > 0:
		_raw_value -= 0.0005 * 2
	elif Variables._time_is_day == true && _raw_value < 1:
		_raw_value += 0.0005 * 2
			
	if _raw_value <= 0:
		_full_moon += 1
		if _full_moon == _full_moon_at_this_number + 1:
			_full_moon = 0
			
		Variables._time_is_day = true
		_ticks_timestamp = 0
		
	if _raw_value >= 1:
		Variables._time_is_day = false
		
		print("midnight")
	
	convertSectoDay(_time_ratio * _ticks_timestamp)
	
# display the time of day at a node.
func convertSectoDay(_n:int):
	if Variables._child_scene_open == true:
		return
	
	if Settings._game.clock == false:
		reset_vars()
		return
		
	Variables._hour = _n / float(3600);
 
	_n %= 3600;
	var minutes = _n / float(60) ;
 
	if Variables._hour == 0:
		Variables._hour = 12
	
	if Variables._hour > 36:
		Variables._hour -= 37 - 1
	
	elif Variables._hour > 24:
		Variables._hour -= 25 - 1
		
	elif Variables._hour > 12:
		Variables._hour -= 13 - 1
	
	# do not output 12 hour as 0.
	if int(Variables._hour) == 0:
		Variables._time = "12"
	else:
		Variables._time = str(int(Variables._hour))
	
	# do not output single minutes without a zero in front of it.
	if int(minutes) < 10:
		Variables._time += ":0"
	else:
		Variables._time += ":"
		
	Variables._time += str(int(minutes))
	
	if Variables._time_is_day == true:
		Variables._time += "A"
	else:
		Variables._time += "P"

func reset_vars():
	_raw_value = 0
	_full_moon_at_this_number = 5
	_full_moon = 0
	Variables._time_is_day = true
	_ticks_timestamp = -1
	_time = 0
	Variables._time = ""

