"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# anything relevent to tiles can be placed here, when moving the mouse to a tile, when right clicking it, user will be redirected to overview, displaying information about that tile. tile information will be grabbed from this file. this file could also hold functions to give damage to player when stepping on a tile and maybe animation of a tile could be done here to.

extends Node

# name of a tile, plus level player is at. eg wall_1.
var _dungeon1 = {
		"level_1":
			{
				"Wall": 
				{
					"Description": "A painted room wall made of wood. Nothing special here.",
				},
				
				"Door": 
				{
					"Description": "Nothing special about this door.",
				},
				
				"Floor": 
				{
					"Description": "Basic dungeon floor tile. The tile is made of concrete. Nothing special here.",
				},
				
				"Ladder_down": 
				{
					"Description": "A ladder that can take you down to the next level.",
				},
				
				"Ladder_up": 
				{
					"Description": "A ladder that can take you up to the next level.",
				},
				
				"Stone": 
				{
					"Description": "A corridor wall. A normal wall made of concrete. There are no hidden passages nor markings on this wall.",
				},
							
				"Floor_rooms": 
				{
					"Description": "A normal floor tile. Nothing special here.",
				},
				
				"Ceiling": 
				{
					"Description": "A basic dungeon ceiling.",
				},
			},
			
		"level_2":
			{
				"Wall": 
				{
					"Description": "A room wall made of concrete. Nothing special here.",
				},
				
				"Door": 
				{
					"Description": "A metal door. Nothing special here.",
				},
				
				"Floor": 
				{
					"Description": "Basic dungeon floor tile. The tile is made of concrete. Nothing special here.",
				},
				
				"Ladder_down": 
				{
					"Description": "A ladder that can take you down to the next level.",
				},
				
				"Ladder_up": 
				{
					"Description": "A ladder that can take you up to the next level.",
				},
				
				"Stone": 
				{
					"Description": "A corridor wall. A normal wall made of concrete. There are no hidden passages nor markings on this wall.",
				},
							
				"Floor_rooms": 
				{
					"Description": "A normal floor tile. Nothing special here.",
				},
				
				"Ceiling": 
				{
					"Description": "A basic dungeon ceiling.",
				},
			},
}
 
