"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

onready var game = get_parent()
onready var build = get_parent().get_node("BuildLevel")

var _text = "" # dialog text about the rune casted, such as, turns amount.

func _ready():
	set_process_input(true)

func hit_points_recovered_text(_hp_calc):
	# find the maximum amount of hp that could be given.	
	var _hp_max_calc = int( P._hp_max - P._hp )
	
	# give hp but do not exceed _hp_calc value.
	_hp_calc = clamp(_hp_calc, 0, _hp_max_calc)
	
	P._hp += _hp_calc
	game.player.get_node("Damage").damage_player(0)
	
	_text = "You recovered " + str(_hp_calc) + " hit points."


# the rune was casted. now do the effect of the rune at object, such as, healing self or turning self invisible.
func cast_at_object_self():
	# the rune is casted. therefore, minus the mp from player.	
	P._mp -= Json._magic[Variables._rune_current_selected_name]["MP"]
		
	match (Variables._rune_current_selected_name):
		"minor_healing":
			var _hp_calc :float = 0.2 * P._hp_max
			hit_points_recovered_text(_hp_calc)
			
		"light_healing":
			var _hp_calc :float = 0.4 * P._hp_max
			hit_points_recovered_text(_hp_calc)
			
		"intense_healing":
			var _hp_calc :float = 0.6 * P._hp_max
			hit_points_recovered_text(_hp_calc)
		
		"ultimate_healing":	
			var _hp_calc :float = 0.8 * P._hp_max
			hit_points_recovered_text(_hp_calc)
		
		"restoration":	
			var _hp_calc :float = 1.0 * P._hp_max
			hit_points_recovered_text(_hp_calc)
		
		"reset_level":
			_text = "Resetting room back to default."
			
			Filesystem.save_visibility_map(game.LEVEL_SIZE, game.visibility_map, false)
			game._player_tile = Vector2(game._player_tile.x , game._player_tile.y)
			
			Variables._reset_player = true
			Variables._reset_player_position = game._player_tile
			
			var _s = get_tree().change_scene("res://2d/source/scenes/game/game_ui.tscn")
				
		"invisible":	
			game.player.frame = 1
			Variables._rune_invisible_turns = Json._magic["invisible"]["Turns"]
			
			_text = "This rune will stop working when standing next to entity or after " + str(Json._magic["invisible"]["Turns"]) + " turns have elapsed."
			
			# this is needed because the first rune turn will be used at rune casting.
			Variables._rune_invisible_turns = Json._magic["invisible"]["Turns"] + 1
			
		"haste":
			
			_text = "This Haste rune will stop working after " + str(Json._magic["haste"]["Turns"]) + " turns have elapsed."
			
			Variables._rune_haste_turns = Json._magic["haste"]["Turns"] + 1
			
			P._move_speed = 2
			Variables._is_haste_enabled = true
	
		"strong_haste":
			
			_text = "This Strong Haste rune will stop working after " + str(Json._magic["strong_Haste"]["Turns"]) + " turns have elapsed."
			
			Variables._rune_haste_turns = Json._magic["strong_Haste"]["Turns"] + 1
			
			P._move_speed = 3
			Variables._is_haste_enabled = true

	Variables._wait_a_turn = 0
	Variables._child_scene_open = true

	get_tree().call_group("game_ui", "rune_dialog_display", _text, Variables._rune_current_selected_name)
	
	Variables._rune_currently_selected = -1
	Variables._rune_current_selected_name = ""
	
	
