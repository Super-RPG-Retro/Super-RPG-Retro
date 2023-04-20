"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# magic_panel.gd
extends Node2D

# if "inventory" panel is hidded, a value is set to this var so that this scene's RuneSummary node can be moved to its new position.
var _offset_y:int = 0
var _rune_current_amount = 0
const _magic_icons = []

# a value is set to Variables._rune_currently_selected when the mouse clicks a rune location. when mouse hovers an item, a value is set to this var when the mouse enters or leaves a rune location. both vars will be the same value when a rune has been selected to cast it.
var _rune_currently_selected = -1

# name of the rune currently selected when hovering the rune. for clicking the rune, see: Variables._rune_current_selected_name
var _rune_current_selected_name = ""

# draw runes to scene.
func _ready():
	draw_rune_icons(Variables._rune_current_group_selected)
	Variables._rune_currently_selected = _rune_currently_selected
	
	player_stats_panel_size()
	
		
func _process(_delta):
	if get_node("Node2D/RuneSummary").visible == true:
		if _rune_currently_selected != -1:
			$Node2D/RuneSummary/Label.text = "(MP " + str(Json._magic[_rune_current_selected_name]["MP"]) + ") " + Json._magic[_rune_current_selected_name]["Short_Description"]

		
func _input(event):
	if Variables._game_over == true:
		return
		
	if Variables._child_scene_open == true:
		return
	
	if get_node("Runes").visible == true:
		if event is InputEventMouseMotion:	
			if Variables._mouse_cursor_position.x > 529 && Variables._mouse_cursor_position.y >= 35 + _offset_y  && Variables._mouse_cursor_position.y <= 135 + _offset_y:
				
				$Node2D/RuneSummary.rect_position.y = get_global_mouse_position().y + 26
					
				$Node2D/RuneSummary.visible = true
				
			else:
				$Node2D/RuneSummary.visible = false
				
			if get_node("Runes/RuneSelect").visible == true && Variables._mouse_cursor_position.x <= 529:
				get_node("Runes/RuneSelect").visible = false
				
	
	# enter this code block when up arrow is in focus and mouse click on that node.
	if event is InputEventMouseButton:
		if event.is_action_pressed("ui_left_mouse_click"):
			# hide rune summary when casting is automatic because the dialog box will stop rune summary from being closed when mouse is no longer at the magic panel.
			
			if Settings._system.automatic_rune_casting == false:
				get_node("Node2D/RuneSummary").visible = false
			
			if get_node("Runes/ArrowUp").has_focus() == true:
				if Settings._system.sound == true:
					if $SoundClick.is_playing() == false:
						$SoundClick.play()
					
				# change group then redraw rune buttons.
				Variables._rune_current_group_selected += 1
				Variables._rune_current_group_selected =  clamp(Variables._rune_current_group_selected, 1, Variables._rune_group_total)	
				draw_rune_icons(Variables._rune_current_group_selected);
			
			# if pressed mouse on down button.
			if get_node("Runes/ArrowDown").has_focus() == true:
				if Settings._system.sound == true:
					if $SoundClick.is_playing() == false:
						$SoundClick.play()
					
				# change group then redraw rune buttons.
				Variables._rune_current_group_selected -= 1
				Variables._rune_current_group_selected =  clamp(Variables._rune_current_group_selected, 1, Variables._rune_group_total)	
				draw_rune_icons(Variables._rune_current_group_selected);
			
		# rune currently selected.
		if event.button_index == BUTTON_LEFT && event.is_action_pressed("ui_left_mouse_click") && _rune_currently_selected != -1:
			# can only select a rune to cast is the rune amount player has is greater than zero and if player has the required magic points.
			if _rune_current_amount > 0 && P._mp >= Json._magic[_rune_current_selected_name]["MP"]:
				# name of rune that was set at _on_mouse_entered func.				
				Variables._rune_current_selected_name = _rune_current_selected_name
				
				# if there is a rune to cast.
				Variables._rune_currently_selected = _rune_currently_selected
				
				if Settings._system.sound == true:
					if $SoundClick.is_playing() == false:
						$SoundClick.play()
				
			elif Settings._system.sound == true:
					if $SoundBuzz.is_playing() == false:
						$SoundBuzz.play()
				
					
			if Json._magic[_rune_current_selected_name]["Stack_amount"] == 0:
				if $SoundClick.is_playing() == false:
					get_node("SoundBuzz").play()
					return


# this func is called when a dialog box displays.
func rune_summary_visible_false():
	if $Node2D/RuneSummary.visible == true:
		$Node2D/RuneSummary.visible = false
		$Runes/RuneSelect.visible = false


func player_stats_panel_size():
	# hide the magic panel scene if true.
	if Settings._system.player_stats_panel_size == 1 || Settings._system.player_stats_panel_size == 3:
		get_node("Runes").visible = false
		get_node("Node2D/RuneSummary").visible = false
	
	else:
		get_node("Runes").visible = true
		get_node("Runes").position.y = 5
		_offset_y = 0
		
	# "inventory" panel hidden?
	if Settings._system.player_stats_panel_size == 2:	
		get_node("Runes").position.y = 148
		_offset_y = 148
	
		 
# draw runes to scene.
func draw_rune_icons(_group: int = 1):
	if Variables._child_scene_open == true:
		return
		
	# this code block clears everything back to default except the _group var.
	var _i = -1
	_magic_icons.clear()
	rune_panel_title(-1)
	_rune_currently_selected = - 1
	Variables._rune_currently_selected = -1
	
	# loop through all magic runes.
	for _key in Json._magic.keys():
		# the value passed here is the group. the reason is because keyboard number 1, 2 and 3 changes the display of the runes at the rune panel. 1: refers to all self runes, 2: attack and 3: support. the value of _group refers to that keypress.
		if Json._magic[_key]["Group"] == "Self" && _group == 1 || Json._magic[_key]["Group"] == "Attack" && _group == 2 || Json._magic[_key]["Group"] == "Support" && _group == 3:
			_i += 1
			_magic_icons.push_back(null)
			
			# set the image textures to the nodes used to display the runes. those nodes are TextureRect. so to get the mouse entering and mouse exiting those nodes.
			_magic_icons[_i] = load("res://bundles/assets/images/magic/" + _key
 + ".png")
			get_node("Runes/Sprite" + str(_i + 1)).texture = _magic_icons[_i]
			
			# this command will expand /strink the image to the dimention of the node.
			get_node("Runes/Sprite" + str(_i + 1)).expand = true
			
			# remove signals because we are about to add new signals for this group.
			if get_node("Runes/Sprite" + str(_i + 1)).is_connected("mouse_entered", self, "_on_mouse_entered"):
				get_node("Runes/Sprite" + str(_i + 1)).disconnect("mouse_entered", self, "_on_mouse_entered")
				
				get_node("Runes/Sprite" + str(_i + 1)).disconnect("mouse_exited", self, "_on_mouse_exited")
				
			# create the signals for the mouse entering/exiting the nodes.
			var _y = get_node("Runes/Sprite" + str(_i + 1)).connect("mouse_entered", self, "_on_mouse_entered", [_i])

			var _z = get_node("Runes/Sprite" + str(_i + 1)).connect("mouse_exited", self, "_on_mouse_exited")
			
			if _i == 23:
				break
	
	# when changing groups, a new list of runes will draw to the scene when entering this func. therefore, all empty button need to have any signals cleared because those signals could have been from a previous group that was drawn before this group.	
	for _r in range (_i + 1, 24, 1):
		get_node("Runes/Sprite" + str(_r + 1)).texture = null
		
		if get_node("Runes/Sprite" + str(_r + 1)).is_connected("mouse_entered", self, "_on_mouse_entered"):
			get_node("Runes/Sprite" + str(_r + 1)).disconnect("mouse_entered", self, "_on_mouse_entered")
			
			get_node("Runes/Sprite" + str(_r + 1)).disconnect("mouse_exited", self, "_on_mouse_exited")
		
func rune_panel_title(_num: int = -1):
	if Variables._child_scene_open == true:
		return
	
	if Variables._rune_currently_selected != -1:
		return
	
	var _i = -1
	var _group = Variables._rune_current_group_selected
	
	# this is the title displayed above the rune panel. middle-right side of scene. 
	get_node("Runes/Title").text = "Rune Panel (" + str(Variables._rune_current_group_selected) + ")"
	
	for _key in Json._magic.keys():
		if Json._magic[_key]["Group"] == "Self" && _group == 1 || Json._magic[_key]["Group"] == "Attack" && _group == 2 || Json._magic[_key]["Group"] == "Support" && _group == 3:
			_i += 1
			
			if _i == _num:
				# this is the title displayed above the rune panel. middle-right side of scene. 
				get_node("Runes/Title").text = "Rune Panel (" + str(Variables._rune_current_group_selected) + ") - " + str(_key).replace("_", " ") + " (" + str(Json._magic[_key]["Stack_amount"]) + ")"
		
				_rune_current_selected_name = str(_key)
				
				_rune_current_amount = Json._magic[_key]["Stack_amount"]
						
# _num is the value of the image that was mouse entered.
func _on_mouse_entered(_num: int = 0):
	if Variables._child_scene_open == true:
		return
		
	_rune_currently_selected = _num
	
	rune_panel_title(_num)
	rune_select(_num)

# _num:			rune index number	
func rune_select(_num = 0):
	if Variables._child_scene_open == true:
		return
		
	# rune sprite starts at 1 not 0. return: if click on an empty icon.
	if get_node("Runes/Sprite" + str(_num + 1)) == null:
		return
		
	elif get_node("Runes/Sprite" + str(_num + 1)).texture == null:
		return
		
	# the "RuneSelect" is the square image that borders and selected rune. this image flashes in animation.
	get_node("Runes/RuneSelect").position.x = get_node("Runes/Sprite" + str(_num + 1)).rect_position.x + 18
	get_node("Runes/RuneSelect").position.y = get_node("Runes/Sprite" + str(_num + 1)).rect_position.y + 18
	
	get_node("Runes/RuneSelect").visible = true

# this event is fired when leaving a rune button. when this value is -1, the flashing image that borders the button/rune will have its visibility hidden until mouse cursor reenters or enters another button/rune location.
func _on_mouse_exited():
	if Variables._child_scene_open == true:
		return
		
	_rune_currently_selected = -1


func _on_rune_ArrowUp_mouse_entered():
	if Variables._child_scene_open == true:
		return
		
	get_node("Runes/ArrowUp").modulate = Color(1, 0.5, 0.5, 1)
	get_node("Runes/ArrowUp").grab_focus()


func _on_rune_ArrowUp_mouse_exited():
	if Variables._child_scene_open == true:
		return
		
	get_node("Runes/ArrowUp").modulate = Color(1, 1, 1, 1)
	get_node("Runes/ArrowUp").release_focus()


func _on_rune_ArrowDown_mouse_entered():
	if Variables._child_scene_open == true:
		return
		
	get_node("Runes/ArrowDown").modulate = Color(1, 0.5, 0.5, 1)
	get_node("Runes/ArrowDown").grab_focus()


func _on_rune_ArrowDown_mouse_exited():
	if Variables._child_scene_open == true:
		return
		
	get_node("Runes/ArrowDown").modulate = Color(1, 1, 1, 1)
	get_node("Runes/ArrowDown").release_focus()


