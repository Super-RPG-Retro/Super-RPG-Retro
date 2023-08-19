"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node


# Charisma aka Presence, Charm, Social.
@onready var _charisma := $Container/Grid/Grid1/CharismaSpinBox

# Constitution aka Stamina, Endurance, Vitality, Recovery.
@onready var _constitution := $Container/Grid/Grid2/ConstitutionSpinBox

# Defense aka Resistance, Fortitude, Resilience.
@onready var _defense := $Container/Grid/Grid3/DefenseSpinBox

# Dexterity aka Agility, Reflexes, Quickness.
@onready var _dexterity := $Container/Grid/Grid4/DexteritySpinBox

# Intelligence aka Intellect, Mind, Knowledge.
@onready var _intelligence := $Container/Grid/Grid5/IntelligenceSpinBox

# Luck aka Fate, Chance.
@onready var _luck := $Container/Grid/Grid6/LuckSpinBox

# Perception aka Alertness, Awareness, Cautiousness.
@onready var _perception := $Container/Grid/Grid7/PerceptionSpinBox

# Strength aka Body, Might, Brawn, Power.
@onready var _strength := $Container/Grid/Grid8/StrengthSpinBox

# Willpower aka Sanity, Personality, Ego, Resolve.
@onready var _willpower := $Container/Grid/Grid9/WillpowerSpinBox

# Wisdom aka Spirit, Wits, Psyche, Sense.
@onready var _wisdom := $Container/Grid/Grid10/WisdomSpinBox

@onready var _artifact_number := $Container/Grid/GridContainer/ArtifactNumberSpinBox
@onready var _artifact_number_description := $Container/Grid/GridContainer/ArtifactNumberDescription

@onready var _artifact_image := $Container/Grid/GridContainer/ArtifactImage 
@onready var _title_text := $Container/Grid/LabelTitle

# the builder menu.
@onready var _menu = null


func _ready():
	Variables._at_scene = Enum.Scene.Builder
	Variables._scene_title = "Builder: Artifacts."
		
	for _i in range (50):
		if Builder._dictionary_artifacts.data.file_name[_i] != "":
			# display a message on scene about how many artifacts are enabled.
			_title_text.text = str(_i + 1) + " artifact"
			if _i > 0:
				_title_text.text += "s"
			_title_text.text += " enabled."
			
			# set the maximum value to the amount of artifacts enabled. user cannot increase SpinBox past this value.
			_artifact_number.max_value = _i + 2
			
	_artifact_number.value = Builder._dictionary_artifacts.data.artifact_number + 1
	_on_artifact_number_SpinBox_value_changed(_artifact_number.value)
	

func _on_artifact_number_SpinBox_value_changed(value):
	if Builder._dictionary_artifacts.data.file_name[value -1] != "":
		# append the value about how many artifacts that are enabled.
		_artifact_number_description.text = " " + Builder._dictionary_artifacts.data.file_name[value -1] 
						
	Builder._dictionary_artifacts.data.artifact_number = value - 1
	
	_artifact_image.texture = Filesystem._load_external_image(Builder._dictionary_artifacts.data.image_texture[Builder._dictionary_artifacts.data.artifact_number])
	
	_charisma.value = Builder._dictionary_artifacts.data.Charisma[Builder._dictionary_artifacts.data.artifact_number]
	_constitution.value = Builder._dictionary_artifacts.data.Constitution[Builder._dictionary_artifacts.data.artifact_number]
	_defense.value = Builder._dictionary_artifacts.data.Defense[Builder._dictionary_artifacts.data.artifact_number]
	_dexterity.value = Builder._dictionary_artifacts.data.Dexterity[Builder._dictionary_artifacts.data.artifact_number]
	_intelligence.value = Builder._dictionary_artifacts.data.Intelligence[Builder._dictionary_artifacts.data.artifact_number]
	_luck.value = Builder._dictionary_artifacts.data.Luck[Builder._dictionary_artifacts.data.artifact_number]
	_perception.value = Builder._dictionary_artifacts.data.Perception[Builder._dictionary_artifacts.data.artifact_number]
	_strength.value = Builder._dictionary_artifacts.data.Strength[Builder._dictionary_artifacts.data.artifact_number]
	_willpower.value = Builder._dictionary_artifacts.data.Willpower[Builder._dictionary_artifacts.data.artifact_number]
	_wisdom.value = Builder._dictionary_artifacts.data.Wisdom[Builder._dictionary_artifacts.data.artifact_number]
	
	
func _on_SpinBox_charisma_changed(value):
	Builder._dictionary_artifacts.data.Charisma[Builder._dictionary_artifacts.data.artifact_number] = value


func _on_SpinBox_constitution_changed(value):
	Builder._dictionary_artifacts.data.Constitution[Builder._dictionary_artifacts.data.artifact_number] = value

	
func _on_SpinBox_defense_changed(value):
	Builder._dictionary_artifacts.data.Defense[Builder._dictionary_artifacts.data.artifact_number] = value

	
func _on_SpinBox_dexterity_changed(value):
	Builder._dictionary_artifacts.data.Dexterity[Builder._dictionary_artifacts.data.artifact_number] = value
	
	
func _on_SpinBox_intelligence_changed(value):
	Builder._dictionary_artifacts.data.Intelligence[Builder._dictionary_artifacts.data.artifact_number] = value
	
	
func _on_SpinBox_juck_changed(value):
	Builder._dictionary_artifacts.data.Luck[Builder._dictionary_artifacts.data.artifact_number] = value


func _on_SpinBox_perception_changed(value):
	Builder._dictionary_artifacts.data.Perception[Builder._dictionary_artifacts.data.artifact_number] = value
	
	
func _on_SpinBox_strength_changed(value):
	Builder._dictionary_artifacts.data.Strength[Builder._dictionary_artifacts.data.artifact_number] = value

	
func _on_SpinBox_willpower_changed(value):
	Builder._dictionary_artifacts.data.Willpower[Builder._dictionary_artifacts.data.artifact_number] = value
	
	
func _on_SpinBox_wisdom_changed(value):
	Builder._dictionary_artifacts.data.Wisdom[Builder._dictionary_artifacts.data.artifact_number] = value

	
func _return_to_main_menu():
	var _s = get_tree().change_scene_to_file("res://3d/scenes/gridmap.tscn")


func _on_Node2D_tree_exiting():
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()
