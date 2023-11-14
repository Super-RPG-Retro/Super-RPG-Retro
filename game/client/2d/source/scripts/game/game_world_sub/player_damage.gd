"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# player_damage.gd from Game/Player/Damage node.
extends Node2D


@onready var game := get_parent().get_parent()
@onready var timer_yield := get_parent().get_parent().get_node("TimerYield")
	
func _ready():
	pass

func damage_player(dmg):
	PC._hp = max(0, PC._hp - dmg)	
	
	if PC._hp > PC._hp_max:
			PC._hp = PC._hp_max
	
	if PC._mp > PC._mp_max:
			PC._mp = PC._mp_max
	
	get_parent().get_node("EntityChildScene/HP").size.x = game.TILE_SIZE * PC._hp / PC._hp_max
	
	if get_parent().get_node("EntityChildScene/HP").size.x > game.TILE_SIZE:
		get_parent().get_node("EntityChildScene/HP").size.x = game.TILE_SIZE
	
	get_parent().get_node("EntityChildScene/HP").color = Color("00007d")
	
	if PC._hp < PC._hp_max * 0.7:
		get_parent().get_node("EntityChildScene/HP").color = Color("7d7d00")
					
	if PC._hp < PC._hp_max * 0.35:
		get_parent().get_node("EntityChildScene/HP").color = Color("7d0000")
	
	game.get_node("Player/AnimationPlayer").play("hit")
	
	# loaded stats panel.
	get_tree().call_group("stats_loaded","damage")
	
	if PC._hp == 0:
		game.get_node("Player/AnimationPlayer").play("goodbye")
		Variables._game_over = true
	
	
func start_timer_yield():
	timer_yield.start(.5)


func _on_TimerYield_timeout():
	timer_yield.stop()
