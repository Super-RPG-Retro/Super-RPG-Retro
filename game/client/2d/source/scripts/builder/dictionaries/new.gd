"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node

onready var _accept_dialog = $AcceptDialog
onready var _file_dialog = $FileDialog
onready var _sprite = $Sprite

# builder nenu.
onready var _menu = null


func _ready():
	# this is needed so when clicking the red button at the top right corner of sceme, the code will jump to the correct scene.
	Variables._at_scene = Enum.Scene.Builder
	
	# this is the title of the scene.
	Variables._scene_title = "Builder: Dictionary New."

	$Container/Grid/GridContainer/Label2.text = Variables._dictionary_name.capitalize() + " Image must be 32x32 .png. File will be uploaded to the custom folder."
	
	if _menu == null:
		_menu = load("res://2d/source/scenes/builder/menu.tscn").instance()
		add_child( _menu )

	
func _on_FileDialog_file_selected(path):
	_sprite.texture = Filesystem._load_external_image(path)
	var _texture = load(path)
	#_sprite.texture = load(path)
	Variables._image_textures.push_front(path)
	
	var _file_name = _file_dialog.current_file.replace(".png", "")
	var _path_image = Variables._project_path + "/builder/objects/images/dictionaries/" + str(Builder._config.game_id + 1) + "/" + Variables._dictionary_name + "/custom/" + _file_name
	
	var _bool = Common._is_letters(_file_name)
	
	if _bool == false:
		_accept_dialog.dialog_text = Variables._dictionary_name.capitalize() + " name must contain only letters with optional underscore and have a .png file extension."
		
		_accept_dialog.popup_centered()
	
	# is this an 32x32 image?
	elif _texture.get_size() == Vector2(32, 32):
		var dir = Directory.new()
		var _err
		
		var _custom_data_dir = Variables._project_path + "/builder/objects/data/" + str(Builder._config.game_id + 1) + "/" + Variables._dictionary_name + "/custom"
	
		if !dir.dir_exists(_custom_data_dir):
			dir.make_dir(_custom_data_dir)
		
		#create custom folder at image folder.
		var _custom_image_dir = Variables._project_path + "/builder/objects/images/dictionaries/" + str(Builder._config.game_id + 1) + "/" + Variables._dictionary_name + "/custom"
	
		if !dir.dir_exists(_custom_image_dir):
			dir.make_dir(_custom_image_dir)
		
		# create image folder inside of custom folder.
		if !dir.dir_exists(_path_image):
			dir.make_dir(_path_image)
		
		# copy file to custom image folder
		_err =  dir.copy(path, _path_image + "/1.png")
						
		if _err != OK:
			_accept_dialog.dialog_text = "Error copying image to resource path. Code " + str(_err)
			
		var _file_to = Variables._project_path + "/builder/objects/data/"+ str(Builder._config.game_id + 1) + "/" + Variables._dictionary_name + "/custom/" + _file_name + ".json"
		
		# copy default json file to custom folder.
		_err = dir.copy(Variables._project_path + "/builder/objects/system/data/custom.json", _file_to)
		
		# get the content of the file...
		var _data = {}
		var file = File.new()
		
		if file.file_exists(_file_to):
			var _o = file.open(_file_to, File.READ)
							
			var text = file.get_as_text()
			_data = parse_json(text)
			
			file.close()
		
		# then encrypt it so that nobody can edit it.
		file = File.new()
		file.open_encrypted_with_pass(_file_to, File.WRITE, "r85v&D4vHw3!df3Gd")
		file.store_line(to_json(_data))
		file.close()
	
		
		if _err != OK:
			_accept_dialog.dialog_text = "Error copying json file to custom folder. Code " + str(_err)
			
				
		if _err == OK:
			_accept_dialog.dialog_text = "A " + _file_name + ".json file was copied to the data custom directory and the " + _file_name + " image was copied to images custom directory."
			
			# this needs to be cleared, so that this new item can be later added to the list. at event, if this array element does not exists, a push_back(0) will be used to set the value. later a value of 1 is given to selected items.
			Variables._event_id.clear()
	else:
		_accept_dialog.dialog_text = "Image is not 32x32 pixels."
		
	_accept_dialog.popup_centered()

func _on_upload_file_Button_pressed():
	_file_dialog.popup_centered()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	_file_dialog.visible = true


func _on_AcceptDialog_focus_exited():
	_accept_dialog.visible = false


func _on_AcceptDialog_popup_hide():
	_accept_dialog.visible = false
	

func _on_AcceptDialog_modal_closed():
	_accept_dialog.visible = false
	
	
func _return_to_main_menu():
	var _s = get_tree().change_scene("res://2d/source/scenes/main_menu.tscn")
