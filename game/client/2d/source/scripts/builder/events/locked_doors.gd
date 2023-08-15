"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


@onready var _event_number := $Container/Grid/Grid1/EventSpinbox

@onready var _event_enabled := $Container/Grid/Grid6/EventEnabled

@onready var _dungeon_number := $Container/Grid/Grid3/DungeonSpinbox

@onready var _level_number := $Container/Grid/Grid2/LevelSpinbox

@onready var _unlock_at_dungeon_number := $Container/Grid/Grid4/UnlockAtDungeonSpinbox

@onready var _unlock_at_level_number := $Container/Grid/Grid5/UnlockAtLevelSpinbox

@onready var _sprite := $Container/Grid/GridContainer/Sprite2D

@onready var _image_textures := []

# selecting an item list will change the sprite appearence.
@onready var _image_item_list := $Container/Grid/GridContainer/ImageItemList

# when selecting the sprite with the arrows keys, this var is used to change that sprite texture. the value of 2 will display the third sprite in the Variables._file_paths array.
@onready var _sprite_index := 0

# this is used to change the json dictionary sprite texture.
@onready var _arrow_left := $Container/Grid/GridContainer/ArrowLeft

# this is used to stop a trigger of a left arrow when the mouse is not at the left arrow image. the problem is that when first clicking the left arrow image, the code will remember that state even when the mouse is no longer at that location.
var _arrow_left_hover := false

@onready var _arrow_right := $Container/Grid/GridContainer/ArrowRight
var _arrow_right_hover := false

# this is the story about the event before you are asked if you accept the event. this story could be about the dungeon, level, an NPC talking to you.
@onready var _story := $Container/Grid/StoryTextEdit

# the builder menu.
@onready var _menu = null


func _ready():
	Variables._at_scene = Enum.Scene.Builder
	Variables._scene_title = "Builder: Event Locked Doors."
	
	#load the keys image into the array.
	for _i in range(9 + 1):
		_image_textures.append([])	
		_image_textures[_i] = "res://bundles/assets/images/keys/" + str(_i) + ".png"
		
		# add those images to this list.
		_image_item_list.add_item(str(_i), null, true)
	
	_event_number.value = Builder._event_locked_doors.data.event_number + 1
	_on_event_number_Spinbox_value_changed(_event_number.value)
	
	if _menu == null:
		_menu = load("res://2d/source/scenes/builder/menu.tscn").instantiate()
		add_child( _menu )


func _input(event):
	# these arrows are used to change to the next dictionary,
	if _arrow_left.has_focus() == true && _arrow_left_hover == true:
		if (event.is_action_released("ui_left", true)) || event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
			
			_sprite_index -= 1
			_sprite_index = clamp(_sprite_index, 0, 9)
				
			# display the sprite texture.
			if _sprite_index >= 0:
				_sprite.texture = load(_image_textures[_sprite_index])
				
				_image_item_list.select(_sprite_index)
				_image_item_list.ensure_current_is_visible()
					
			Builder._event_locked_doors.data.sprite_index[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number] = _sprite_index
	
	if _arrow_right.has_focus() == true && _arrow_right_hover == true:
		if (event.is_action_released("ui_right", true)) || event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
			
			_sprite_index += 1
			_sprite_index = clamp(_sprite_index, 0, 9)
			
			if _sprite_index <= 9:
				_sprite.texture = load(_image_textures[_sprite_index])
			
				_image_item_list.select(_sprite_index)
				_image_item_list.ensure_current_is_visible()
				
			Builder._event_locked_doors.data.sprite_index[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number] = _sprite_index
			
			
func _on_event_number_Spinbox_value_changed(value):
	Builder._event_locked_doors.data.event_number = value - 1
	
	if bool(Builder._event_locked_doors.data.event_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number]) == true:
		_event_enabled.button_pressed = true
	else:
		_event_enabled.button_pressed = false	
	
	
	_sprite_index = Builder._event_locked_doors.data.sprite_index[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number]
	
	_image_item_list.select(_sprite_index)
	_image_item_list.ensure_current_is_visible()
	
	_sprite.texture = load(_image_textures[_sprite_index])
	
	_story.text = Builder._event_locked_doors.data.story_text[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number]
	
	_dungeon_number.value = Builder._event_locked_doors.data.dungeon_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number] + 1
	
	_unlock_at_dungeon_number.value = Builder._event_locked_doors.data.unlock_at_dungeon_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number] + 1
	
	_level_number.value = Builder._event_locked_doors.data.level_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number] + 1
	
	_unlock_at_level_number.value = Builder._event_locked_doors.data.unlock_at_level_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number] + 1
	

func _on_EventEnabled_toggled(button_pressed):
	# update the builder event_enabled data. 	
	Builder._event_locked_doors.data.event_enabled[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number] = button_pressed
			
	
func _on_StatusBar_tree_exiting():
	
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()


func _return_to_main_menu():
	var _s = get_tree().change_scene_to_file("res://3d/scenes/Gridmap.tscn")


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


func _on_dungeon_Spinbox_value_changed(value):
	# store the current value in to the builder var.
	Builder._event_locked_doors.data.dungeon_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number] = value - 1
	
	
func _on_unlock_at_dungeon_number_Spinbox_value_changed(value):
	Builder._event_locked_doors.data.unlock_at_dungeon_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number] = value - 1
	

func _on_level_number_Spinbox_value_changed(value):
	Builder._event_locked_doors.data.level_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number] = value - 1
	

func _on_unlock_at_level_number_Spinbox_value_changed(value):
	Builder._event_locked_doors.data.unlock_at_level_number[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number] = value - 1
	

func _on_StoryTextEdit_text_changed():
	Builder._event_locked_doors.data.story_text[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number] = _story.text
	

func _on_image_ItemList_item_selected(index):
	_sprite_index = clamp(index, 0, 9)
	
	# display the sprite texture.
	if _sprite_index >= 0:
		_sprite.texture = load(_image_textures[_sprite_index])
		
	Builder._event_locked_doors.data.sprite_index[Builder._config.game_id][Builder._data.dungeon_number][Builder._event_locked_doors.data.event_number] = _sprite_index
	
	_image_item_list.ensure_current_is_visible()
	
