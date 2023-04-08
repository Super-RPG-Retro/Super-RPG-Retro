"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node

# how does this object move. follows player, moves in opposite direction of player...
onready var _movement_type = $Container/Grid/GridContainer27/MovementTypeItemList

var _something_went_wrong_dictionary: String = "Something went wrong with the dictionaries. Was a file manually deleted? Returning you to the builder home scene."

onready var _accept_dialog_rename = $AcceptDialogRename
onready var _accept_dialog_return_to_builder_home = $AcceptDialogReturnToBuilderHome

# select a object group list such as animals or dragons.
onready var _group_item_list = $Container/Grid/Grid2/ItemList
var _group_item_list_index = 0

# when selecting the sprite with the arrows keys, this var is used to change that sprite texture. the value of 2 will display the third sprite in the Variables._file_paths array.
onready var _current_sprite_index = 0

# image texture.
onready var _image_sprite 	= $Container/Grid/GridContainer/Sprite

onready var _dictionary_description = $Container/Grid/TextEditDescription

#Charisma aka Presence, Charm, Social.
onready var _charisma = $Container/Grid/GridContainer14/SpinBoxCharisma

# Constitution aka Stamina, Endurance, Vitality, Recovery.
onready var _constitution = $Container/Grid/GridContainer2/SpinBoxConstitution

# Defense aka Resistance, Fortitude, Resilience.
onready var _defense = $Container/Grid/GridContainer3/SpinBoxDefense

# Dexterity aka Agility, Reflexes, Quickness.
onready var _dexterity = $Container/Grid/GridContainer4/SpinBoxDexterity
# Intelligence aka Intellect, Mind, Knowledge.
onready var _intelligence = $Container/Grid/GridContainer5/SpinBoxIntelligence

# Luck aka Fate, Chance.
onready var _luck = $Container/Grid/GridContainer6/SpinBoxLuck

# Perception aka Alertness, Awareness, Cautiousness.
onready var _perception = $Container/Grid/GridContainer7/SpinBoxPerception

# Strength aka Body, Might, Brawn, Power.
onready var _strength = $Container/Grid/GridContainer8/SpinBoxStrength

# Willpower aka Sanity, Personality, Ego, Resolve.
onready var _willpower = $Container/Grid/GridContainer9/SpinBoxWillpower

# Wisdom aka Spirit, Wits, Psyche, Sense.
onready var _wisdom = $Container/Grid/GridContainer10/SpinBoxWisdom

# Maximum amount a player can have is 999 unless set here.
onready var _stack_amount = $Container/Grid/GridContainer28/SpinBoxAmount

# the amount of gold the object has.
onready var _selling_price = $Container/Grid/GridContainer11/SpinBoxSellingPrice

# if this object is at store.
onready var _buying_price = $Container/Grid/GridContainer23/SpinBoxBuyingPrice

# The amount of gold dropped with this item.
onready var _drop_gold = $Container/Grid/GridContainer26/SpinBoxDropGold

# healing hp for this object will not go beyond this value.
onready var _hp_max = $Container/Grid/GridContainer12/SpinBoxHpMax

# current hit points of this object.
onready var _hp = $Container/Grid/GridContainer13/SpinBoxHp

# magic points. using a mana potion will not give more mana then this value.
onready var _mp_max = $Container/Grid/GridContainer15/SpinBoxMpMax

# current mana points.
onready var _mp = $Container/Grid/GridContainer16/SpinBoxMp

# object will give this value to player.
onready var _xp_given = $Container/Grid/GridContainer17/SpinBoxXpGiven

# the name of the object.
onready var _dictionary_name = $Container/Grid/GridContainer18/LabelDictionaryName

# when renaming a object, this var holds that data.
onready var _dictionary_rename = $Container/Grid/GridContainer22/LineEditDictionaryRename

# an optional SpinBox value added to the end of the object name.
onready var _dictionary_name_suffix = $Container/Grid/GridContainer22/SpinBoxDictionaryNameSuffix

onready var _suffix_checkbox = $Container/Grid/GridContainer22/CheckBoxSuffix

# there are 8 dungeons in this game. which dungeon is the object at?
onready var _at_dungeon_from = $Container/Grid/GridContainer19/SpinBoxAtDungeonFrom

onready var _at_dungeon_to = $Container/Grid/GridContainer19/SpinBoxAtDungeonTo

# object is seen when this var matches the current dungeon level player is at. this is the starting value.
onready var _at_level_from = $Container/Grid/GridContainer20/SpinBoxAtLevelFrom

# object is seen when this var matches the current dungeon level player is at. this is the ending value
onready var _at_level_to = $Container/Grid/GridContainer20/SpinBoxAtLevelTo

# true: object is seen at current dungeon level. false: object is not at that dungeon level
onready var _enabled = $Container/Grid/GridContainer21/CheckButtonEnabled

# Best to disable this object if using it as an artifact.
onready var _is_artifact = $Container/Grid/GridContainer25/IsArtifactEnabled

# the builder menu.
onready var _menu = null

# this is used to change the json object sprite texture.
onready var _arrow_left = $Container/Grid/GridContainer/ArrowLeft

# this is used to stop a trigger of a left arrow when the mouse is not at the left arrow image. the problem is that when first clicking the left arrow image, the code will remember that state even when the mouse is no longer at that location.
var _arrow_left_hover = false

onready var _arrow_right = $Container/Grid/GridContainer/ArrowRight
var _arrow_right_hover = false

# gets the file path of this object.
var _path_file = Variables._project_path + "/builder/objects/data/" + str(Builder._config.game_id + 1) + "/" + Variables._dictionary_name + "/"

# gets the image path of this object.
var _path_image = Variables._project_path + "/builder/objects/images/dictionaries/" + str(Builder._config.game_id + 1) + "/" + Variables._dictionary_name + "/"

# res:// is inaccessible during runtime, when at ready() func. You can't save/load files in it when you run the program. this var stops that attempt from happening. after everything is processed at ready() func, this var will be set to false.
var _runtime = true
	
func _ready():
	Variables._at_scene = Enum.Scene.Builder
	Variables._scene_title = "Builder: Dictionary Edit."
	
	Json.make_directories()	
	Json.refresh_dictionaries(Variables._project_path + "/builder/objects/data/" + str(Builder._config.game_id + 1) + "/" + Variables._dictionary_name + "/")
		
	var _found = false
	
	# how does this object walk in the dungeon. eg, follow player, opposite direction of player...
	_movement_type.select(0, true)
	
	# loop thur all object directories.
	for _i in Variables._folder_names:
		_found = false
		
		for _f in Variables._file_names:
			# if folder_name is part of the filename but not an exact dupicate of that filename then enter code. remember that the file_names var has part of the folder as that name.
			if _i in _f && _i != _f:
				var _found2 = false
				
				# if duplicate...
				for _r in range (_group_item_list.get_item_count()):
					if _group_item_list.get_item_text(_r) == _i:
						_found2 = true
				
				# else add the directory name to the item list.
				if _found2 == false:						
					_group_item_list.add_item(_i, null, true)
			
			if _found == true:
				break
			
	_group_item_list.select(0, true)
	
	display_values()
	
	
func _input(event):
	# these arrows are used to change to the next dictionary,
	if _arrow_left.has_focus() == true && _arrow_left_hover == true:
		if (event.is_action_released("ui_left", true)) || event is InputEventMouseButton && event.button_index == BUTTON_LEFT && !event.pressed:
					 
			_current_sprite_index -= 1
			
			# when clicking the arrow images, this keeps the index within range, so that an invalid error does not occur.
			_current_sprite_index = clamp(_current_sprite_index, 0, Variables._file_paths.size() - 1)
			
			# display the sprite texture.
			if _current_sprite_index >= 0:
				_image_sprite.texture =  Filesystem._load_external_image(Variables._image_textures[_current_sprite_index], 3)
			
			_runtime = true
			display_values()
	
	if _arrow_right.has_focus() == true && _arrow_right_hover == true:
		if (event.is_action_released("ui_right", true)) || event is InputEventMouseButton && event.button_index == BUTTON_LEFT && !event.pressed:
			
			_current_sprite_index += 1
			_current_sprite_index = clamp(_current_sprite_index, 0, Variables._file_paths.size() - 1)
			
			if _current_sprite_index < Variables._file_paths.size():
				_image_sprite.texture = Filesystem._load_external_image(Variables._image_textures[_current_sprite_index], 3)
			
			_runtime = true
			display_values()


# when user changes the display of the sprite, populate the values into the fields such as TextEdit or SpinBox.
func display_values():
	_on_ItemList_item_selected(_group_item_list_index)
	
	# load the sprite texture.
	# this avoids an invalid get index on base array error.
	if range(Variables._image_textures.size()).has(_current_sprite_index):
		_image_sprite.texture = Filesystem._load_external_image(Variables._image_textures[_current_sprite_index], 3)
	
	else:
		_accept_dialog_return_to_builder_home.dialog_text = _something_went_wrong_dictionary
		
		_accept_dialog_return_to_builder_home.popup_centered()
		
		return
					
	refresh_data()
	
	
func refresh_data():	
	# this is all the values that can be changed. most of them are SpinBox.
	_dictionary_description.text = Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Description"]
	
	_charisma.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Charisma"])	
	
	_constitution.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Constitution"])
	
	_defense.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Defense"])
	
	_dexterity.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Dexterity"])
	
	_intelligence.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Intelligence"])
	
	_luck.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Luck"])
	
	_perception.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Perception"])
	
	_strength.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Strength"])
	
	_willpower.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Willpower"])
	
	_wisdom.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Wisdom"])
	
	_stack_amount.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Stack_amount"])
	
	_selling_price.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Selling_price"])
	
	_buying_price.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Buying_price"])
	
	_drop_gold.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Drop_gold"])
	
	_hp_max.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["HP_max"])
	
	_hp.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["HP"])
	
	_mp_max.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["MP_max"])
	
	_mp.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["MP"])
	
	_xp_given.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["XP_given"])
	
	_at_dungeon_to.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["At_dungeon_to"])
	
	_at_dungeon_from.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["At_dungeon_from"])
	
	_at_level_to.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["At_level_to"])
	
	_at_level_from.value = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["At_level_from"])
	
	_enabled.pressed = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Enabled"])
	
	_movement_type.select(int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Movement_type"]), true)
	
	_is_artifact.pressed = int(Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Is_artifact"])
	
	if _is_artifact.pressed == true:
		_enabled.pressed = false
		_enabled.disabled = true
	
	else:
		_enabled.disabled = false
	
	# this assures hp cannot go higher in value then the current value of hp_max.
	_hp.max_value = _hp_max.value
	_mp.max_value = _mp_max.value
	_at_dungeon_from.max_value = _at_dungeon_to.value
	_at_level_from.max_value = _at_level_to.value
	
	_dictionary_name.text = str(Variables._file_names[_current_sprite_index])
	
	# this gets the suffix. 
	var _dn_suffix = _dictionary_name.text.lstrip("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_")
	
	# if suffix equals two then this is the numeric value of the object's name. this is an option for the user to add numbers at the end of the objects name.
	if _dn_suffix.length() == 2:
		_dictionary_name_suffix.value = int(_dn_suffix)
	else:
		_dictionary_name_suffix.value = 0
		
	# data can now be saved.
	_runtime = false


# modulate is used to change the color of the sprite.
func _on_ArrowLeft_focus_entered():
	_arrow_left.modulate = Color(1, 0.5, 0.5, 1)
	_arrow_left_hover = true

	
func _on_ArrowLeft_focus_exited():
	_arrow_left.modulate = Color(1, 1, 1, 1)
	_arrow_left_hover = false


func _on_ArrowLeft_mouse_entered():
	_arrow_left.modulate = Color(1, 0.5, 0.5, 1)
	_arrow_left_hover = true
	

func _on_ArrowLeft_mouse_exited():
	_arrow_left.modulate = Color(1, 1, 1, 1)
	_arrow_left_hover = false
	

func _on_ArrowRight_focus_entered():
	_arrow_right.modulate = Color(1, 0.5, 0.5, 1)
	_arrow_right_hover = true


func _on_ArrowRight_focus_exited():
	_arrow_right.modulate = Color(1, 1, 1, 1)
	_arrow_right_hover = false
	
	
func _on_ArrowRight_mouse_entered():
	_arrow_right.modulate = Color(1, 0.5, 0.5, 1)
	_arrow_right_hover = true


func _on_ArrowRight_mouse_exited():
	_arrow_right.modulate = Color(1, 1, 1, 1)
	_arrow_right_hover = false


func _on_Node2D_tree_exiting():
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()


# this is the object group, such as, animals or dragons. this func is entered when the mouse selects a group.
func _on_ItemList_item_selected(index):
	if _group_item_list_index != index:
		_current_sprite_index = 0
	
	_group_item_list_index = index
	_group_item_list.select(_group_item_list_index, true)
	
	# when searching for dictionary json files, the directories are scanned and all filenames from those directories are populated into these vars. these vars are then used to display the json data in the form of dictionaries and then the Variables._file_names are used to grab the sprite textures.
	Variables._file_paths.clear()
	Variables._file_names.clear()
	Variables._image_textures.clear()
	
	# get the dictionary information.
	var full_path = Variables._project_path + "/builder/objects/data/" + str(Builder._config.game_id + 1) + "/" + Variables._dictionary_name + "/"
	
	var path_texture = Variables._project_path + "/builder/objects/images/dictionaries/" + str(Builder._config.game_id + 1) + "/" + Variables._dictionary_name + "/"
		
	full_path += str(_group_item_list.get_item_text(index)).pad_zeros(2)
		
	# gets the filenames from that folder
	Filesystem.get_dir_files(full_path)
	
	# If deep is true, a deep copy is performed: all nested arrays and dictionaries are duplicated and will not be shared with the original array. If false, a shallow copy is made and references to the original nested arrays and dictionaries are kept, so that modifying a sub-array or dictionary in the copy will also impact those referenced in the source array.
	Variables._image_textures = Variables._file_paths.duplicate(true)
	Variables._file_names = Variables._file_paths.duplicate(true)
	
	# output all files in this var. this is the full path including the file name ending in .json.
	var _i = -1
	for _f in Variables._file_paths:
		_i += 1
		
		# Replaces occurrences of a case-sensitive substring with the given one inside the string.
		Variables._image_textures[_i] = Variables._image_textures[_i].replace(full_path, path_texture + str(_group_item_list.get_item_text(index)).pad_zeros(2))
		Variables._image_textures[_i] = Variables._image_textures[_i].replace(".json", "/1.png")
		
		Variables._file_names[_i] =	Variables._file_names[_i].replace(full_path + "/", "")
		Variables._file_names[_i] =	Variables._file_names[_i].replace(".json", "")

	
	if _runtime == false:
		
		# this avoids an invalid get index on base array error.
		if range(Variables._image_textures.size()).has(0):
			_image_sprite.texture = Filesystem._load_external_image(Variables._image_textures[0], 3)
			
			refresh_data()
		
		else:
			_accept_dialog_return_to_builder_home.dialog_text = _something_went_wrong_dictionary
			
			_accept_dialog_return_to_builder_home.popup_centered()
			
			return
		
func _return_to_main_menu():
	var _s = get_tree().change_scene("res://2d/source/scenes/main_menu.tscn")


# this saves all current object data back to its json file.
func save_stats():
	if _runtime == false:
		Filesystem.FILE_PATH = _path_file
		Filesystem.save_dictionary_json(str(_group_item_list.get_item_text(_group_item_list_index)).pad_zeros(2), Variables._file_names[_current_sprite_index], Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]])

func _on_text_edit_description_mouse_exited():
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Description"] = _dictionary_description.text
		
	if _runtime == false:
		save_stats()


func _on_SpinBox_charisma_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Charisma"] = value

	if _runtime == false:
		save_stats()
		
		
func _on_SpinBox_Constitution_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Constitution"] = value

	if _runtime == false:
		save_stats()
	
	
func _on_SpinBox_Defense_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Defense"] = value

	if _runtime == false:
		save_stats()
	
	
func _on_SpinBox_Dexterity_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Dexterity"] = value

	if _runtime == false:
		save_stats()
	
	
func _on_SpinBox_Intelligence_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Intelligence"] = value

	if _runtime == false:
		save_stats()
	
	
func _on_SpinBox_Luck_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Luck"] = value

	if _runtime == false:
		save_stats()
	
	
func _on_SpinBox_Perception_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Perception"] = value

	if _runtime == false:
		save_stats()
	
	
func _on_SpinBox_Strength_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Strength"] = value
	
	if _runtime == false:
		save_stats()
	
	
func _on_SpinBox_Willpower_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Willpower"] = value
	
	if _runtime == false:
		save_stats()
	
	
func _on_SpinBox_Wisdom_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Wisdom"] = value

	if _runtime == false:
		save_stats()
	
	
func _on_SpinBox_Amount_changed(index):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Stack_amount"] = index
	
	if _runtime == false:
		save_stats()
		

func _on_SpinBox_selling_price_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Selling_price"] = value

	if _runtime == false:
		save_stats()
	
	
func _on_SpinBox_buying_price_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Buying_price"] = value

	if _runtime == false:
		save_stats()


func _on_SpinBox_HP_max_changed(value):
	# this stops hp value from a value greater than hp_max
	if _hp.value > value:
		_hp.value = value		
	_hp.max_value = value
	
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["HP_max"] = value

	if _runtime == false:
		save_stats()
	
	
func _on_SpinBox_HP_changed(value):
	if value <= _hp_max.value:
		Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["HP"] = value
	
		if _runtime == false:
			save_stats()
	
	else:
		value = _hp_max.value - 1


func _on_SpinBox_MP_max_changed(value):
	# this stops mp value from a value greater than mp_max
	if _mp.value > value:
		_mp.value = value		
	_mp.max_value = value
	
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["MP_max"] = value

	if _runtime == false:
		save_stats()
	

func _on_SpinBox_MP_changed(value):
	if value <= _mp_max.value:
		Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["MP"] = value
	
		if _runtime == false:
			save_stats()
	
	else:
		value = _mp_max.value - 1


func _on_SpinBox_XP_Given_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["XP_given"] = value

	if _runtime == false:
		save_stats()


# rename this object.
func _on_Button_dictionary_rename_pressed():
	if _dictionary_rename.text == "":
		_accept_dialog_rename.dialog_text = Variables._dictionary_name + " name cannot be empty."
		
		_accept_dialog_rename.popup_centered()
		
		return
	
	var _bool = Common._is_letters(_dictionary_rename.text)
	
	if _bool == false:
		_accept_dialog_rename.dialog_text = Variables._dictionary_name + " name must contain only letters and underscore. For example (a-z _)"
				
		_accept_dialog_rename.popup_centered()
		
		return
	
	
	# if suffix is greater than zero, remove all numbers from rename text feild since code is adding that number value to the end of the text. basiclly, this code is used when suffix field is not zero. code adds that value to the end of the rename text.
	var _dn: String = _dictionary_rename.text
	if _suffix_checkbox.pressed == true && _dictionary_name_suffix.value > 0:
		_dn = _dictionary_rename.text.lstrip("0123456789")
		_dn = _dn + "_" + str(_dictionary_name_suffix.value).pad_zeros(2)
		
		_dictionary_rename.text = _dn
	
		
	if _dictionary_rename.text == "":
		_accept_dialog_rename.dialog_text = Variables._dictionary_name + " name cannot be empty."
		
		_accept_dialog_rename.popup_centered()
	

	for _f in Variables._file_names:
		if _f == _dictionary_rename.text:
			_accept_dialog_rename.dialog_text = "File exists. Use a different name."
			_accept_dialog_rename.popup_centered()
			
			return

	# make the selected "dictionary rename" text lower case.
	_dictionary_rename.text = _dictionary_rename.text.to_lower()
		
	var _old_filename = str(_path_file) + str(_group_item_list.get_item_text(_group_item_list_index)).pad_zeros(2) + "/" + str(Variables._file_names[_current_sprite_index]) + ".json"
	var _new_filename = str(_path_file) + str(_group_item_list.get_item_text(_group_item_list_index)).pad_zeros(2) + "/" + _dictionary_rename.text + ".json"
	
	# when searching for dictionary json files at the Filesystem._rename_file_or_directory func, the directories are scanned and all filenames from those directories are populated into these vars. these vars are then used to display the json data in the form of dictionaries and then the Variables._file_names is used to grab the sprite textures.
	
	# rename file. the parameter false is _is_dir at this func.
	Filesystem._rename_file_or_directory(false, _old_filename, _new_filename)
	
	# rename directory.
	Filesystem._rename_file_or_directory(true, _path_image + str(_group_item_list.get_item_text(_group_item_list_index)).pad_zeros(2) + "/" + str(Variables._file_names[_current_sprite_index]), _path_image + str(_group_item_list.get_item_text(_group_item_list_index)).pad_zeros(2) + "/" + _dictionary_rename.text)
	
	# update the dictionary name Label to show what it has been renamed to, then clear the dictionary rename LineEdit.
	_dictionary_name.text = _dictionary_rename.text
	_dictionary_rename.text = ""
	
	Json.make_directories()	
	Json.refresh_dictionaries(Variables._project_path + "/builder/objects/data/" + str(Builder._config.game_id + 1) + "/" + Variables._dictionary_name + "/")


func _on_AcceptDialog_focus_exited():
	_accept_dialog_rename.visible = false
	

func _on_AcceptDialog_popup_hide():
	_accept_dialog_rename.visible = false
	

func _on_AcceptDialog_modal_closed():
	_accept_dialog_rename.visible = false


func _on_SpinBox_at_dungeon_from_changed(value):
	if value <= _at_dungeon_to.value:
		Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["At_dungeon_from"] = value
	
		if _runtime == false:
			save_stats()
	
	else:
		value = _at_dungeon_to.value - 1	


func _on_SpinBox_at_dungeon_to_changed(value):
	# this stops dungeon_to value from a value greater than dungeon_from
	if _at_dungeon_from.value > value:
		_at_dungeon_from.value = value		
	_at_dungeon_from.max_value = value
	
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["At_dungeon_to"] = value

	if _runtime == false:
		save_stats()
		

func _on_SpinBox_at_level_from_changed(value):
	if value <= _at_level_to.value:
		Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["At_level_from"] = value
	
		if _runtime == false:
			save_stats()
	
	else:
		value = _at_level_to.value - 1	


func _on_SpinBox_at_level_to_changed(value):
	# this stops level_to value from a value greater than level_from
	if _at_level_from.value > value:
		_at_level_from.value = value		
	_at_level_from.max_value = value
	
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["At_level_to"] = value

	if _runtime == false:
		save_stats()
		

# is dictionary enabled, displayed at dungeon?
func _on_CheckButton_dictionary_enabled_toggled(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Enabled"] = value

	if _runtime == false:
		save_stats()


func _on_AcceptDialog_return_to_builder_home_confirmed():
	var _s = get_tree().change_scene("res://2d/source/scenes/builder/project_data.tscn")	


func _on_is_artifact_Enabled_toggled(button_pressed):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Is_artifact"] = button_pressed
	
	if _is_artifact.pressed == true:
		_enabled.pressed = false
		_enabled.disabled = true
	
	else:
		_enabled.disabled = false

	if _runtime == false:
		save_stats()


func _on_SpinBox_drop_gold_changed(value):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Drop_gold"] = value

	if _runtime == false:
		save_stats()


func _on_movement_type_ItemList_item_selected(index):
	Json.d[str(Builder._config.game_id)][Variables._dictionary_name][Variables._file_names[_current_sprite_index]]["Movement_type"] = index
	
	if _runtime == false:
		save_stats()
	
