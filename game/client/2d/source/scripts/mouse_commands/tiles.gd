"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# When moving the mouse at the region of the main map, the map where the player moves, display either tile text, such as the player, mobs, or item, and also displays a summary, after a short delay, of what each mouse button does. clicking the button at the main map will display this tile overview panel that has all the node's stats.

extends Control


@onready var _tile_image := $ScrollContainer/GridContainer/Label/TileImage
@onready var _overview_text := $ScrollContainer/GridContainer/Label


func _ready():
	_tile_image.visible = false


func _process(_delta):
	if Variables._game_over == true:
		return
	
	if Variables._child_scene_open == false:
		if Variables._mouse_cursor_position.x >= -129 && Variables._mouse_cursor_position.x <= 529:
			get_tree().call_group("unit_description", "unit_description")	
	

# this displays the stats, description, summary and other things about the tile that was mouse clicked.
func overview(p_node, e_node, i_node, t_node):
	get_node("TileSummary").visible = false
	
	Variables._child_scene_open = true
	Variables._scene_title = "Tile overview."
		
	get_node("SceneHeader/Label").text = "Unit Description: " + str(Variables._dungeon_coordinates + " " + Variables._compass)
		
	if _overview_text.text != "":
		return
		
	get_node("MouseSummary").visible = false
	
	Variables._at_scene = Enum.Scene.Game_UI
	
	# path and name referring to the image located at this scene.		
	var _texture
	var _is_player
	var node	

	for _type in Variables._type:
		if _type == "player":
			node = p_node
		
			_is_player = true
			_texture = load("res://bundles/assets/images/player_characters/" + str(P._number) + ".png")
			
		if _type == "mobs":
			node = e_node

			_is_player = false
			_texture = Filesystem._load_external_image(Variables._project_path + "/builder/objects/images/dictionaries/" + str(Builder_playing._config.game_id + 1) + "/mobs/" + str(Builder_playing._data.dungeon_number + 1) + "/" + str(Builder_playing._data.level_number + 1) + "/" + Json.d[str(Builder_playing._config.game_id)]["mobs"][e_node._name]["Class"] + e_node._name.to_lower() + "/1.png")
			
		get_tree().call_group("game_ui", "mouse_command_image", _texture, _is_player)
		
		# player and mobs share these vars.
		var _str:int 	= 0
		var _def:int 	= 0 
		var _con:int 	= 0
		var	_dex:int 	= 0
		var	_int:int 	= 0
		var	_cha:int 	= 0
		var	_wis:int 	= 0
		var	_wil:int 	= 0
		var	_per:int 	= 0
		var	_luc:int 	= 0
		var _hp_max:int = 0
		var _hp:int 	= 0
		var _mp_max:int = 0
		var _mp:int 	= 0
		var _gold:int 	= 0
		var _level:int 	= 1
		var _xp:int 	= 0
		
		# display the text of the overview panel.
		if _type == "player":
			_str = P._str
			_def = P._def 
			_con = P._con 
			_dex = P._dex
			_int = P._int
			_cha = P._cha
			_wis = P._wis
			_wil = P._wil
			_per = P._per
			_luc = P._luc
			_hp_max = P._hp_max
			_hp = P._hp 
			_mp_max = P._mp_max
			_mp = P._mp
			_gold = Hud._gold
			_level = P._level + 1
			_xp = P._xp
		
		if _type == "mobs":
			_str 	= node._str
			_def 	= node._def 
			_con 	= node._con
			_dex 	= node._dex
			_int 	= node._int
			_cha 	= node._cha
			_wis 	= node._wis
			_wil 	= node._wil
			_per 	= node._per
			_luc 	= node._luc
			_hp_max = node._hp_max
			_hp 	= node._hp
			_mp_max = node._mp_max
			_mp 	= node._mp
			_gold 	= node._gold
			_xp 	= node._xp_given
		
		_overview_text.text += "[p full][/p]"
		
		if _type == "player":	
			_tile_image.visible = true
			_overview_text.text += "[table=10][cell][color=#00cccc] Entity.[/color][/cell][/table]"
			_overview_text.text += "[p full][/p] [table=10][cell] " + node._name.replace("_", " ") + "[/cell][/table] [p full][/p] [p full][/p] " + "[table=10][cell] HP. [/cell][cell][color=#00cc00]" + str(_hp).pad_zeros(4) + "/" + str(_hp_max).pad_zeros(4) + "[/color][/cell][cell]   MP. [/cell][cell][color=#00cc00]" + str(_mp).pad_zeros(4) + "/" + str(_mp_max).pad_zeros(4) + "[/color][/cell]"
			
			_overview_text.text += "[/table]"
			
			_overview_text.text += "[p full][/p][table=10][cell] Gold. [/cell][cell][color=#00cc00]" + str(_gold).pad_zeros(14) + "[/color][/cell]"
			
			_overview_text.text += "[cell]   Level. [/cell][cell][color=#00cc00]" + str(_level).pad_zeros(2) + "[/color][/cell]"
				
			_overview_text.text += "[/table]" + "[p full][/p] [p full][/p] [table=10][cell] STR.[/cell][cell][color=#00cc00]" + str(_str).pad_zeros(3) + "[/color][/cell][cell]   CHA.[/cell][cell][color=#00cc00]" + str(_cha).pad_zeros(3) + "[/color][/cell][cell]   DEF.[/cell][cell][color=#00cc00]" + str(_def).pad_zeros(3) + "[/color][/cell][cell]   WIS.[/cell][cell][color=#00cc00]" + str(_wis).pad_zeros(3) + "[/color][/cell][cell]   CON.[/cell]\r\n[cell][color=#00cc00]" + str(_con).pad_zeros(3) + "[/color][/cell][cell] WIL.[/cell][cell][color=#00cc00]" + str(_wil).pad_zeros(3) + "[/color][/cell][cell]   DEX.[/cell][cell][color=#00cc00]" + str(_dex).pad_zeros(3) + "[/color][/cell][cell]   PER.[/cell][cell][color=#00cc00]" + str(_per).pad_zeros(3) + "[/color][/cell][cell]   INT.[/cell][cell][color=#00cc00]" + str(_int).pad_zeros(3) + "[/color][/cell][cell]   LUC.[/cell][cell][color=#00cc00]" + str(_luc).pad_zeros(3) + "[/color][/cell][/table] [p full][/p]"
			
			_overview_text.text += "[center][table=10][cell]\r[u]                                                                           [/u][/cell][/table][/center] [p full][/p]"
			
		if _type == "mobs":	
			_tile_image.visible = true
			_overview_text.text += "[table=10][cell][color=#00cccc] Entity.[/color][/cell][/table]"
			_overview_text.text += "[p full][/p] [table=10][cell] " + node._name.replace("_", " ") + "[/cell][/table] [p full][/p] [table=10][cell] HP.[/cell][cell][color=#00cc00]" + str(_hp).pad_zeros(4) + "/" + str(_hp_max).pad_zeros(4) + "[/color][/cell][cell]   MP.[/cell][cell][color=#00cc00]" + str(_mp).pad_zeros(4) + "/" + str(_mp_max).pad_zeros(4) + "[/color][/cell]"
			
			_overview_text.text += "[/table]"
			
			_overview_text.text += "[p full][/p] [table=10][cell] Gold.[/cell][cell][color=#00cc00]" + str(_gold).pad_zeros(4) + "[/color][/cell]"
			
			_overview_text.text += "[cell]   XP Given.[/cell][cell][color=#00cc00]" + str(_xp).pad_zeros(14) + "[/color][/cell][/table]"
				
			_overview_text.text += "[p full][/p] [p full][/p] [table=10][cell] STR.[/cell][cell][color=#00cc00]" + str(_str).pad_zeros(3) + "[/color][/cell][cell]   CHA.[/cell][cell][color=#00cc00]" + str(_cha).pad_zeros(3) + "[/color][/cell][cell]   DEF.[/cell][cell][color=#00cc00]" + str(_def).pad_zeros(3) + "[/color][/cell][cell]   WIS.[/cell][cell][color=#00cc00]" + str(_wis).pad_zeros(3) + "[/color][/cell][cell]   CON.[/cell]\r\n[cell][color=#00cc00]" + str(_con).pad_zeros(3) + "[/color][/cell][cell] WIL.[/cell][cell][color=#00cc00]" + str(_wil).pad_zeros(3) + "[/color][/cell][cell]   DEX.[/cell][cell][color=#00cc00]" + str(_dex).pad_zeros(3) + "[/color][/cell][cell]   PER.[/cell][cell][color=#00cc00]" + str(_per).pad_zeros(3) + "[/color][/cell][cell]   INT.[/cell][cell][color=#00cc00]" + str(_int).pad_zeros(3) + "[/color][/cell][cell]   LUC.[/cell][cell][color=#00cc00]" + str(_luc).pad_zeros(3) + "[/color][/cell][/table] [p full][/p]"
			
			_overview_text.text += "[center][table=10][cell]\r[u]                                                                           [/u][/cell][/table][/center] [p full][/p]"
			
		if _type == "item":
			_overview_text.text += "[table=10][cell][color=#00cccc] Item.[/color][/cell][/table] [p full][/p]"
			
			for _i in range (0, i_node.size()): 
				node = i_node[_i]
			
				_overview_text.text += "[table=10][cell] " + node._name.replace("_", " ") + "[/cell][/table][p full][/p][table=10][/cell][cell] " + node._description + "[/cell][/table] [p full][/p] [p full][/p]"
			
			_overview_text.text += "[center][table=10][cell][u]                                                                           [/u][/cell][/table][/center]"
		
		
		# tiles
		_overview_text.text += "[p full][/p][table=10][cell][color=#00cccc] Tile[/color][/cell][/table]"

		node = t_node
		
		_overview_text.text += "[p full][/p] [table=10][cell] " + node._name.replace("_", " ") + "[/cell][/table] [p full][/p] [table=10][/cell][cell] " + node._description + "[/cell][/table] [p full][/p] [p full][/p]" 

		
	get_node("ScrollContainer/GridContainer").position.x = 30
	get_node("ScrollContainer/GridContainer").position.y = 45
	get_node("ScrollContainer/GridContainer").visible = true
	get_node("RightSidePanel").visible = true
	get_node("SceneHeader").visible = true
	
	get_node("ScrollContainer").visible = true
	get_node("MarginPanel").visible = true
	
	# show the overview panel.
	_overview_text.position.x = 10
	_overview_text.position.y = 10
	_overview_text.visible = true

# hides this scene.	
func unit_text_clear():	
	get_node("MarginPanel").visible = false
	get_node("TileSummary").text = ""	
	_tile_image.visible = false
	get_node("RightSidePanel").visible = false


# display the short tile information, such as the name of the sprite or name of a wall.
func unit_text():
	var _mouse_pos = get_local_mouse_position()
	
	get_node("TileSummary").position.x = _mouse_pos.x + 15
	get_node("TileSummary").position.y = _mouse_pos.y
	
	if Variables._name.size() > 0:
		get_node("TileSummary").text = ""
		
		for _i in range (Variables._name.size()):
			get_node("TileSummary").text += Variables._name[_i] + "\r\n"	
		


# display the mouse summary panel with text, such as, left mouse click to use 1 game turn or right mouse click to go to tile overview panel.	
func summary():
	if Variables._child_scene_open == true:
		return
	
	get_node("TileSummary").visible = false
		
	get_node("MouseSummary").position = get_node("TileSummary").position
	get_node("MouseSummary").visible = true
	
	# set text to mouse summary menu then show it.
	get_node("MouseSummary/Label").text = "L-Click - Wait one turn\n\rR-Click - Overview"
