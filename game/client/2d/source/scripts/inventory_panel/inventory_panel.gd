"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# inventory_panel.gd
extends Node2D


var _inventory_icons := []

var _inventory_current_amount := 0

# a value is set to Variables._inventory_currently_selected when the mouse clicks a inventory location. when mouse hovers an item, a value is set to this var when the mouse enters or leaves a inventory location. both vars will be the same value when a inventory has been selected to cast it.
var _inventory_currently_selected := -1

# name of the inventory currently selected when hovering the inventory. for clicking the inventory, see: Variables._inventory_current_selected_name
var _inventory_current_selected_name := ""


# draw Inventory to scene.
func _ready():
	draw_inventory_icons(Variables._inventory_current_group_selected)
	Variables._inventory_currently_selected = _inventory_currently_selected
	
	player_stats_panel_size()
	

func _process(_delta):
	if get_node("Node2D/InventorySummary").visible == true:
		if _inventory_currently_selected != -1: $Node2D/InventorySummary/Label.text = Json.d[str(Builder_playing._config.game_id)][Inventory._directory_name[_inventory_currently_selected]][Inventory._file_name[_inventory_currently_selected]]["Description"]
	
	
func _input(event):
	if Variables._game_over == true:
		return
		
	if Variables._child_scene_open == true:
		return

	if get_node("Inventory").visible == true:
		if event is InputEventMouseMotion:	
			if Variables._mouse_cursor_position.x > 529 && Variables._mouse_cursor_position.y >= 178 && Variables._mouse_cursor_position.y <= 278:
				
				$Node2D/InventorySummary.position.y = get_global_mouse_position().y + 24
		
				$Node2D/InventorySummary.visible = true
				
			else:
				$Node2D/InventorySummary.visible = false
		
			
			if get_node("Inventory/InventorySelect").visible == true && Variables._mouse_cursor_position.x <= 529:
				get_node("Inventory/InventorySelect").visible = false
				
				
	# enter this code block when up arrow is in focus and mouse click on that node.
	if event is InputEventMouseButton:
		if event.is_action_pressed("ui_left_mouse_click"):			
			if get_node("Inventory/ArrowUp").has_focus() == true:
				if Settings._system.sound == true:
					if $SoundClick.is_playing() == false:
						$SoundClick.play()
					
				Variables._inventory_current_group_selected += 1
				Variables._inventory_current_group_selected =  clamp(Variables._inventory_current_group_selected, 1, Variables._inventory_group_total)	
				
				# change group then redraw inventory buttons.
				draw_inventory_icons(Variables._inventory_current_group_selected);
			
			# if pressed mouse on down button.
			if get_node("Inventory/ArrowDown").has_focus() == true:
				if Settings._system.sound == true:
					if $SoundClick.is_playing() == false:
						$SoundClick.play()
					
				Variables._inventory_current_group_selected -= 1
				Variables._inventory_current_group_selected =  clamp(Variables._inventory_current_group_selected, 1, Variables._inventory_group_total)	
				
				# change group then redraw inventory buttons.
				draw_inventory_icons(Variables._inventory_current_group_selected);
			
		# inventory currently selected.
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_action_pressed("ui_left_mouse_click") && _inventory_currently_selected != -1:
			Inventory.use(((Variables._inventory_current_group_selected - 1) * 24) + _inventory_currently_selected)
			

func player_stats_panel_size():
	if Settings._system.player_stats_panel_size == 2 || Settings._system.player_stats_panel_size == 3:
		get_node("Inventory").visible = false
		get_node("Node2D/InventorySummary").visible = false

	else:
		get_node("Inventory").visible = true
	

# this func is called when a dialog box displays
func inventory_summary_visible_false():
	if Variables._child_scene_open == true:
		return
		
	$Node2D/InventorySummary.visible = false
	$Inventory/InventorySelect.visible = false
	

# draw Inventory to scene.
func draw_inventory_icons(_group: int = 1):
	if Variables._child_scene_open == true:
		return
		
	# this code block clears everything back to default except the _group var.
	_inventory_icons.clear()
	_inventory_currently_selected = - 1
	Variables._inventory_currently_selected = -1
	
	# build of list, including the name and image of all available inventory in this game that was created at the inventory section at builder.
	Inventory.build()
	
	var _i = -1
	# loop through all inventory items
	for _r in range (((Variables._inventory_current_group_selected - 1) * 24), Inventory._item_total):
		_i += 1
		
		if Inventory._file_name[((Variables._inventory_current_group_selected - 1) * 24) + _i] != "":
			_inventory_icons.push_back(null)
		
			# set the image textures to the nodes used to display the inventory. those nodes are TextureRect so to get the mouse entering and mouse exiting those nodes.
			_inventory_icons[_i] = load(Inventory._image_texture[((Variables._inventory_current_group_selected - 1) * 24) + _i])
			
			get_node("Inventory/Sprite" + str(_i + 1)).texture = _inventory_icons[_i]
			
			# this command will expand/strink the image to the dimention of the node.
			get_node("Inventory/Sprite" + str(_i + 1)).expand = true
			
			# remove signals because we are about to add new signals for this group.
			if get_node("Inventory/Sprite" + str(_i + 1)).is_connected("mouse_entered", Callable(self, "_on_mouse_entered")):
				get_node("Inventory/Sprite" + str(_i + 1)).disconnect("mouse_entered", Callable(self, "_on_mouse_entered"))
				
				get_node("Inventory/Sprite" + str(_i + 1)).disconnect("mouse_exited", Callable(self, "_on_mouse_exited"))
				
			# create the signals for the mouse entering/exiting the nodes.
			var _y = get_node("Inventory/Sprite" + str(_i + 1)).connect("mouse_entered", Callable(self, "_on_mouse_entered").bind(_i))

			var _z = get_node("Inventory/Sprite" + str(_i + 1)).connect("mouse_exited", Callable(self, "_on_mouse_exited"))
			
			if _i == 23:
				break

		# when changing groups, a new list of inventory items will draw to the scene when entering this func. therefore, all empty button need to have any signals cleared because those signals could have been from a previous group that was drawn before this group.	
	for _r in range (_i + 1, 24, 1):
		get_node("Inventory/Sprite" + str(_r + 1)).texture = null
		
		if get_node("Inventory/Sprite" + str(_r + 1)).is_connected("mouse_entered", Callable(self, "_on_mouse_entered")):
			get_node("Inventory/Sprite" + str(_r + 1)).disconnect("mouse_entered", Callable(self, "_on_mouse_entered"))
			
			get_node("Inventory/Sprite" + str(_r + 1)).disconnect("mouse_exited", Callable(self, "_on_mouse_exited"))


# _num is the value of the image that was mouse entered.
func _on_mouse_entered(_num: int = 0):
	if Variables._child_scene_open == true:
		return
		
	_inventory_currently_selected = _num
	
	inventory_select(_num)

# _num:			inventory index number	
func inventory_select(_num = 0):
	if Variables._child_scene_open == true:
		return
		
	# inventory sprite starts at 1 not 0. return: if click on an empty icon.
	if get_node("Inventory/Sprite" + str(_num + 1)) == null:
		return
		
	elif get_node("Inventory/Sprite" + str(_num + 1)).texture == null:
		return
		
	# the "InventorySelect" is the square image that borders and selected inventory.
	get_node("Inventory/InventorySelect").position.x = get_node("Inventory/Sprite" + str(_num + 1)).position.x + 18
	get_node("Inventory/InventorySelect").position.y = get_node("Inventory/Sprite" + str(_num + 1)).position.y + 18
	
	get_node("Inventory/InventorySelect").visible = true

# this event is fired when leaving a inventory button. when this value is -1, the flashing image that borders the inventory will have its visibility hidden until mouse cursor reenters or enters another inventory location.
func _on_mouse_exited():
	if Variables._child_scene_open == true:
		return
		
	_inventory_currently_selected = -1


func _on_ArrowUp_mouse_entered():
	if Variables._child_scene_open == true:
		return
		
	get_node("Inventory/ArrowUp").modulate = Color(1, 0.5, 0.5, 1)
	get_node("Inventory/ArrowUp").grab_focus()


func _on_ArrowUp_mouse_exited():
	if Variables._child_scene_open == true:
		return
		
	get_node("Inventory/ArrowUp").modulate = Color(1, 1, 1, 1)
	get_node("Inventory/ArrowUp").release_focus()


func _on_ArrowDown_mouse_entered():
	if Variables._child_scene_open == true:
		return
		
	get_node("Inventory/ArrowDown").modulate = Color(1, 0.5, 0.5, 1)
	get_node("Inventory/ArrowDown").grab_focus()


func _on_ArrowDown_mouse_exited():
	if Variables._child_scene_open == true:
		return
		
	get_node("Inventory/ArrowDown").modulate = Color(1, 1, 1, 1)
	get_node("Inventory/ArrowDown").release_focus()

