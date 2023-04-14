"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node

# Charisma aka Presence, Charm, Social.
onready var _charisma = $Container/Grid/Grid1/CharismaSpinBox

# Constitution aka Stamina, Endurance, Vitality, Recovery.
onready var _constitution = $Container/Grid/Grid2/ConstitutionSpinBox

# Defense aka Resistance, Fortitude, Resilience.
onready var _defense = $Container/Grid/Grid3/DefenseSpinBox

# Dexterity aka Agility, Reflexes, Quickness.
onready var _dexterity = $Container/Grid/Grid4/DexteritySpinBox

# Intelligence aka Intellect, Mind, Knowledge.
onready var _intelligence = $Container/Grid/Grid5/IntelligenceSpinBox

# Luck aka Fate, Chance.
onready var _luck = $Container/Grid/Grid6/LuckSpinBox

# Perception aka Alertness, Awareness, Cautiousness.
onready var _perception = $Container/Grid/Grid7/PerceptionSpinBox

# Strength aka Body, Might, Brawn, Power.
onready var _strength = $Container/Grid/Grid8/StrengthSpinBox

# Willpower aka Sanity, Personality, Ego, Resolve.
onready var _willpower = $Container/Grid/Grid9/WillpowerSpinBox

# Wisdom aka Spirit, Wits, Psyche, Sense.
onready var _wisdom = $Container/Grid/Grid10/WisdomSpinBox

# the builder menu.
onready var _menu = null


func _ready():
	Variables._at_scene = Enum.Scene.Builder
	Variables._scene_title = "Builder: Starting Statistics."
	
	_charisma.value = Builder._starting_statistics.Charisma
	_constitution.value = Builder._starting_statistics.Constitution
	_defense.value = Builder._starting_statistics.Defense
	_dexterity.value = Builder._starting_statistics.Dexterity
	_intelligence.value = Builder._starting_statistics.Intelligence
	_luck.value = Builder._starting_statistics.Luck
	_perception.value = Builder._starting_statistics.Perception
	_strength.value = Builder._starting_statistics.Strength
	_willpower.value = Builder._starting_statistics.Willpower
	_wisdom.value = Builder._starting_statistics.Wisdom
	

func _on_SpinBox_charisma_changed(value):
	Builder._starting_statistics.Charisma = value
		

func _on_SpinBox_constitution_changed(value):
	Builder._starting_statistics.Constitution = value
	
	
func _on_SpinBox_defense_changed(value):
	Builder._starting_statistics.Defense = value

	
func _on_SpinBox_dexterity_changed(value):
	Builder._starting_statistics.Dexterity = value
	
	
func _on_SpinBox_intelligence_changed(value):
	Builder._starting_statistics.Intelligence = value
	
	
func _on_SpinBox_juck_changed(value):
	Builder._starting_statistics.Luck = value
	
	
func _on_SpinBox_perception_changed(value):
	Builder._starting_statistics.Perception = value
	
	
func _on_SpinBox_strength_changed(value):
	Builder._starting_statistics.Strength = value
	
	
func _on_SpinBox_willpower_changed(value):
	Builder._starting_statistics.Willpower = value
	
	
func _on_SpinBox_wisdom_changed(value):
	Builder._starting_statistics.Wisdom = value

	
func _return_to_main_menu():
	var _s = get_tree().change_scene("res://2d/source/scenes/main_menu.tscn")


func _on_Node2D_tree_exiting():
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()
