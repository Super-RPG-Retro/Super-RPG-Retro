"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


@onready var _select_button:= $SelectButton

# this is the number of the OptionButton selected. the other var that also refer to this number is _i which is used in a loop at ready func and also as _on_focus_entered() parameter
var _num := -1
# this var does not get reset back to -1. it is used to save the pressed state of the OptionButton to builder.
var _num_current := -1

# the builder menu.
@onready var _menu = null

var _padding 	:= 	[] # grid row padding
var _padding2 	:= 	[]
var _padding3 	:= 	[]

var _scene_name := 	[] # name of scene where music is played.
var _music_name := 	[] # name of the music assigned to the scene.

var _play_button := [] # play the music.
var _stop_button := [] # stop playing the music.

@onready var _grid := $Container/Grid


func _ready():
	Variables._at_scene = Enum.Scene.Builder
	# used at title_bar/ see HeaderMenu node. if changing this data then change it also at next_event.gd
	Variables._scene_title = "Builder: Audio Music."
	
	for _i in range (Variables._music_scenes.size()):
		_padding.append([])
		_padding[_i] = Label.new()
		_padding[_i].text = ""
		_grid.add_child(_padding[_i])
		
		_scene_name.append([])
		_scene_name[_i] = Label.new()
		_scene_name[_i].text = Variables._music_scenes[str(_i)]
		_grid.add_child(_scene_name[_i])
		
		_music_name.append([])
		_music_name[_i] = OptionButton.new()
		_populate_button_options(_i)
		_grid.add_child(_music_name[_i])
		if _i == 0:
			_music_name[_i].grab_focus()
		
				
		# here are the signals for all OptionButton. these signals will capture the entering and exiting of any OptionButton and will then go to the respective func. The toggle signal will also to a toggle func when the mouse or space/enter key is pressed.
		if _music_name[_i].is_connected("focus_entered", Callable(self, "_on_focus_entered")):
			_music_name[_i].disconnect("focus_entered", self, "_on_focus_entered", [_i])
			
		# create the signals for the mouse entering /exiting the nodes.
		var _x = _music_name[_i].connect("focus_entered", Callable(self, "_on_focus_entered").bind(_i))
		
		_padding2.append([])
		_padding2[_i] = Label.new()
		_padding2[_i].text = ""
		_grid.add_child(_padding2[_i])
		
		_play_button.append([])
		_play_button[_i] = Button.new()
		_play_button[_i].icon_alignment = HORIZONTAL_ALIGNMENT_CENTER 
		_play_button[_i].theme = load("res://2d/assets/themes/rounded_button.tres") 
		_play_button[_i].icon = load("res://2d/assets/images/audio_play_button.png")
		_grid.add_child(_play_button[_i])

		if _play_button[_i].is_connected("pressed", Callable(self, "_on_music_play")):
			_play_button[_i].disconnect("pressed", self, "_on_music_play", [_i])
			
		var _y = _play_button[_i].connect("pressed", Callable(self, "_on_music_play").bind(_i))
			
			
	
		_stop_button.append([])
		_stop_button[_i] = Button.new()
		_stop_button[_i].icon_alignment = HORIZONTAL_ALIGNMENT_CENTER 
		_stop_button[_i].theme = load("res://2d/assets/themes/rounded_button.tres") 
		_stop_button[_i].icon = load("res://2d/assets/images/audio_stop_button.png")
		_grid.add_child(_stop_button[_i])
		
		if _stop_button[_i].is_connected("pressed", Callable(self, "_on_music_stop")):
			_stop_button[_i].disconnect("pressed", Callable(self, "_on_music_stop"))
			
		var _z = _stop_button[_i].connect("pressed", Callable(self, "_on_music_stop"))
		
		
		_padding3.append([])
		_padding3[_i] = Label.new()
		_padding3[_i].text = ""
		_grid.add_child(_padding3[_i])
		

func _process(_delta):
	# current position of the mouse cursor.
	Variables._mouse_cursor_position.x = get_global_mouse_position().x
	Variables._mouse_cursor_position.y = get_global_mouse_position().y
	
	if Variables._mouse_cursor_position.y <= 391: # bottom of screen.
		# this is the button that follows the cursor.
		_select_button.position.y = 135
		
	elif Variables._mouse_cursor_position.y >= 791: # bottom of screen.
		# this is the button that follows the cursor.
		_select_button.position.y = 535
		
	else:
		# -16 -128 will center button to tip of cursor.
		_select_button.position.y = Variables._mouse_cursor_position.y - 16
		
	
	# hide the _select_button when clicked, so that the OptionButton can show the options for that _music_text. Once a selection is made, the OptionButton will close and then the _select_button will be set back to visible. 
	var _found = false
	for _i in range (9):
		if _music_name[_i].button_pressed == true:
			_num_current = _i
			Builder._audio_music.data.file_name[_i] = _music_name[_i].get_item_index(Builder._audio_music.data.id[_i])
			_found = true
			
			
	if _found == false and _select_button.visible == false:
		_select_button.visible = true
		_save_builder_data()
		
	
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_button.visible = false
		
	
func _save_builder_data():
	Builder._audio_music.data.file_name[_num_current] = _music_name[_num_current].get_item_text(_music_name[_num_current].get_selected_id())
	
	Builder._audio_music.data.id[_num_current] = _music_name[_num_current].get_selected_id()
	
	
func _populate_button_options(_i):
	for _r in range (9):
		_music_name[_i].add_item(Variables._music[str(_r)])
		
	_music_name[_i].select(Builder._audio_music.data.id[_i])


# _i refers to the checkbox node.
func _on_focus_entered(_i:int = 0):
	pass
	# this code is for using the arrow keys.
	#_num = _i
	#_num_current = _num

		
func _on_focus_exited():
	pass


func _on_music_play(_i:int = 0):
	Common._music_play(Builder._audio_music.data.file_name[Builder._audio_music.data.id[_i]], Builder._audio_music.data.id[_i], false)
	
	
func _on_music_stop():
	Common._music_stop()
	
		
func _on_StatusBar_tree_exiting():
	call_deferred("remove_child", _menu)
	call_deferred("queue_free", _menu)
	
	queue_free()


func _return_to_main_menu():
	var _s = get_tree().change_scene_to_file("res://3d/scenes/gridmap.tscn")

