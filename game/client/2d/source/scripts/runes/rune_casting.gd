"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D

onready var game = get_parent()
onready var build = get_parent().get_node("BuildLevel")
onready var _timer_rune_zorder = get_parent().get_node("TimerRuneZorder")

# after clicking a rune to cast, guide images on map, refering to locations where a rune can be casted, unless you disable that feature at config scene.
var _rune_guide_value = []
var _rune_guide_sprite = []

onready var x = 0
onready var y = 0

# the animation of the rune at the map after casting it. this var is populated when the player casts the rune.	
onready var _rune_animation = []

# a rune could have 5 turns. after the player walks 5 steps then the rune will be removed from the map. each step decrements this value by 1. this var is populated when the player casts the rune.
onready var _rune_turns_animation = []

# the rune name will be used to set the total turns of the casted rune. this var is populated when the player casts the rune.
onready var _rune_name_animation = []

func _ready():
	# all rune guide images default at the position of player.
	x = get_parent().get_node("Player/EntityChildScene/RuneGuide1").position.x
	y = get_parent().get_node("Player/EntityChildScene/RuneGuide1").position.y
	
func build_guides():
	# Clears the array. This is equivalent to using resize() with a size of 0.
	_rune_animation.clear()
	_rune_turns_animation.clear()
	_rune_name_animation.clear()
	
	_rune_guide_value.clear()
	_rune_guide_sprite.clear()
		
	# create a 2-dimensional array that will hold the rune guides.
	for _x in range (11):
		_rune_guide_value.append([])
		_rune_guide_value[_x] = []
				
		_rune_guide_sprite.append([])
		_rune_guide_sprite[_x] = []
					
		for _y in range (11):
			_rune_guide_value[_x].append([])
			_rune_guide_value[_x][_y] = 0
				
			_rune_guide_sprite[_x].append([])
			_rune_guide_sprite[_x][_y] = 0
								
# display the rune on main map. Runes on the map will be hidden when turns for that rune runs out. runes will only be reset when entering a new dungeon level. a rune casted will not use the current created rune tiles but instead will create new tiles for that rune. therefore, you can have many runes active on the map. the runes are limited only to how many amount of runes you have to cast. 
func create_rune_casting_units():
	# first create a 3-dimensional array that will hold the rune effects.
	_rune_animation.append([])
	_rune_turns_animation.append(Json._magic[Variables._rune_current_selected_name]["Turns"])
	_rune_name_animation.append(Variables._rune_current_selected_name)
	
	# if there are two runes on the map, this will get the third array element.
	var _num = _rune_animation.size() - 1 
	
	# this will hold the rows where the guide tiles are set to. 5 will be used here to create all the posible tiles in a row but will later only set those tiles as active from the guide tiles that have a value of 1.
	for _x in range (11):
		_rune_animation[_num].append([])
		_rune_animation[_num][_x] = []
			
		# create the array for the second dimension. this will be used the same as rows but will refer to columns.
		for _y in range (11):
			_rune_animation[_num][_x].append([])
			_rune_animation[_num][_x][_y] = []
				
			_rune_animation[_num][_x][_y] = AnimatedSprite.new()
			
			# each rune has an animation effects to use. the animaton is taken from the magic dictionary, animation element. the name of the rune is set when clicking the rune button at the rune panel.
			var _rune_image1 = ImageTexture.new()
			_rune_image1 = load("res://bundles/assets/images/magic/animation/" + str(Json._magic[Variables._rune_current_selected_name]["Animation"]) + "a.png")
			
			var _rune_image2 = ImageTexture.new()
			_rune_image2 = load("res://bundles/assets/images/magic/animation/" + str(Json._magic[Variables._rune_current_selected_name]["Animation"]) + "b.png")
			
			var _rune_image3 = ImageTexture.new()
			_rune_image3 = load("res://bundles/assets/images/magic/animation/" + str(Json._magic[Variables._rune_current_selected_name]["Animation"]) + "c.png")
			
			# add the animation frames for this rune.
			_rune_animation[_num][_x][_y].frames = SpriteFrames.new()
			_rune_animation[_num][_x][_y].frames.add_animation(str(Json._magic[Variables._rune_current_selected_name]["Animation"]))
			_rune_animation[_num][_x][_y].frames.add_frame(str(Json._magic[Variables._rune_current_selected_name]["Animation"]), _rune_image1, 0)
			_rune_animation[_num][_x][_y].frames.add_frame(str(Json._magic[Variables._rune_current_selected_name]["Animation"]), _rune_image2, 1)
			_rune_animation[_num][_x][_y].frames.add_frame(str(Json._magic[Variables._rune_current_selected_name]["Animation"]), _rune_image3, 2)
			_rune_animation[_num][_x][_y].frames.set_animation_loop(str(Json._magic[Variables._rune_current_selected_name]["Animation"]), true)
			_rune_animation[_num][_x][_y].frames.set_animation_speed(str(Json._magic[Variables._rune_current_selected_name]["Animation"]), 5.0)
			
			# add the animation to the scene.
			add_child(_rune_animation[_num][_x][_y])

	# go to this func to set the position of where this rune will be located at the main map.
	cast_the_Selected_rune(_num)

# play the rune animation to display rune at main map.
func cast_the_Selected_rune(_num):
	rune_position_hide()
	
	for _y in range (0, 11):
		for _x in range (0, 11):
			# if guide has a value of 1 then guide is at map. for every guild at map, place a rune at that location.
			if _rune_guide_value[_x][_y] == 1:
				_rune_animation[_num][_x][_y].position = Vector2((game._player_tile.x * 32 ) + _rune_guide_sprite[_x][_y].position.x + 5, (game._player_tile.y * 32) + _rune_guide_sprite[_x][_y].position.y + 8)
				_rune_animation[_num][_x][_y].z_index = 4000
				_rune_animation[_num][_x][_y].play(str(Json._magic[Variables._rune_current_selected_name]["Animation"]))
				_rune_animation[_num][_x][_y].visible = true	

	# the rune will be displayed overtop of all entities and objects but for only a short time because this func will change the z-order to display it underneath all entities and objects.
	_timer_rune_zorder.start()
		
# rune will be removed from main map after rune "turns" equals 0. turns will decrease in value with each player step.
func rune_turns():
	var _i = -1
	for _num in _rune_animation:
		_i += 1
		
		# decrease casted rune turns.
		_rune_turns_animation[_i] -= 1
		
		# remove rune from scene if turns equals zero.
		if (_rune_turns_animation[_i] + 1) <= 0:		
			for _y in range (0, 11):
				for _x in range (0, 11):
					# if guide has a value of 1 then guide is at map.
					if _num[_x][_y].visible == true:
						_num[_x][_y].stop()
						_num[_x][_y].visible = false
						remove_child(_num[_x][_y])

# change the z-order to display the rune underneath all entities and objects.
func _on_TimerRuneZorder_timeout():
	for _num in _rune_animation:
		for _y in range (0, 11):
			for _x in range (0, 11):
				_num[_x][_y].z_index = -1000
				
	_timer_rune_zorder.stop()

# show the guides for the rune at the main map but only if the guides are enabled at configuration scene.			
func rune_position_show():
	if Variables._rune_current_selected_name == "":
		return
		
	if Json._magic[Variables._rune_current_selected_name]["Stack_amount"] == 0:
		# no rune to cast because no rune bought at the selected rune panel.
		return
	
	if Settings._system.rune_guides == false:
		return
	
	# clear the previous guides if any.
	rune_position_hide()
			
	var _i = -1
	
	for _y in range (0, 11):
		for _x in range (0, 11):
			_i += 1
			
			_rune_guide_value[_x][_y] = Json._magic[Variables._rune_current_selected_name]["Units"][_i]
				
			_rune_guide_sprite[_x][_y] = get_parent().get_node("Player/EntityChildScene/RuneGuide" + str(_i + 1))
			
			if Settings._system.rune_guides == true:
				if _rune_guide_value[_x][_y] == 1:
					_rune_guide_sprite[_x][_y].play("0")
					_rune_guide_sprite[_x][_y].visible = true
					
			else:
				_rune_guide_sprite[_x][_y].texture = load("res://2d/assets/images/all_transparent.png")
	
	# this draws the guides to the scene.
	set_rune_guides()
		
	# should the rune be casted automatically?
	if Settings._system.automatic_rune_casting && Variables._rune_currently_selected != -1:	
		create_rune_casting_units()
		Json._magic[Variables._rune_current_selected_name]["Stack_amount"] -= 1
		get_tree().call_group("rune_casted", "cast_at_object_self")
		
		rune_position_hide()
		
func set_rune_guides():
	x = game._player_tile.x
	y = game._player_tile.y	
	
	# north -----------------------------
	var _break_at_north:bool = false
	
	if game.map[x][y-1] != Enum.Tile.Floor && game.map[x][y-1] != Enum.Tile.Floor_rooms:
		_rune_guide_sprite[5][4].visible = false
		_rune_guide_value[5][4] = 0 
	
		_break_at_north = true
		
	if game.map[x][y-2] != Enum.Tile.Floor && game.map[x][y-2] != Enum.Tile.Floor_rooms || _break_at_north == true:
		_rune_guide_sprite[5][3].visible = false
		_rune_guide_value[5][3] = 0
	
		_break_at_north = true

	if game.map[x][y-3] != Enum.Tile.Floor && game.map[x][y-3] != Enum.Tile.Floor_rooms || _break_at_north == true:
		_rune_guide_sprite[5][2].visible = false
		_rune_guide_value[5][2] = 0
	
		_break_at_north = true

	if game.map[x][y-4] != Enum.Tile.Floor && game.map[x][y-4] != Enum.Tile.Floor_rooms || _break_at_north == true:
		_rune_guide_sprite[5][1].visible = false
		_rune_guide_value[5][1] = 0
	
		_break_at_north = true
		
	if game.map[x][y-5] != Enum.Tile.Floor && game.map[x][y-5] != Enum.Tile.Floor_rooms || _break_at_north == true:
		_rune_guide_sprite[5][0].visible = false
		_rune_guide_value[5][0] = 0
	
		_break_at_north = true		
	
	
	# north-east -----------------------------
	var _break_at_north_east:bool = false
	
	if game.map[x+1][y-1] != Enum.Tile.Floor && game.map[x+1][y-1] != Enum.Tile.Floor_rooms:
		_rune_guide_sprite[6][4].visible = false
		_rune_guide_value[6][4] = 0
	
		_break_at_north_east = true
		
	if game.map[x+2][y-2] != Enum.Tile.Floor && game.map[x+2][y-2] != Enum.Tile.Floor_rooms || _break_at_north_east == true:
		_rune_guide_sprite[7][3].visible = false
		_rune_guide_value[7][3] = 0
	
		_break_at_north_east = true
	
	if game.map[x+3][y-3] != Enum.Tile.Floor && game.map[x+3][y-3] != Enum.Tile.Floor_rooms || _break_at_north_east == true:
		_rune_guide_sprite[8][2].visible = false
		_rune_guide_value[8][2] = 0
	
		_break_at_north_east = true

	if game.map[x+4][y-4] != Enum.Tile.Floor && game.map[x+4][y-4] != Enum.Tile.Floor_rooms || _break_at_north_east == true:
		_rune_guide_sprite[9][1].visible = false
		_rune_guide_value[9][1] = 0
	
		_break_at_north_east = true
			
	if game.map[x+5][y-5] != Enum.Tile.Floor && game.map[x+5][y-5] != Enum.Tile.Floor_rooms || _break_at_north_east == true:
		_rune_guide_sprite[10][0].visible = false
		_rune_guide_value[10][0] = 0
	
		_break_at_north_east = true
		
		
	# east -----------------------------
	var _break_at_east:bool = false
	
	if game.map[x+1][y] != Enum.Tile.Floor && game.map[x+1][y] != Enum.Tile.Floor_rooms:
		_rune_guide_sprite[6][5].visible = false
		_rune_guide_value[6][5] = 0 
	
		_break_at_east = true
		
	if game.map[x+2][y] != Enum.Tile.Floor && game.map[x+2][y] != Enum.Tile.Floor_rooms || _break_at_east == true:
		_rune_guide_sprite[7][5].visible = false
		_rune_guide_value[7][5] = 0
	
		_break_at_east = true

	if game.map[x+3][y] != Enum.Tile.Floor && game.map[x+3][y] != Enum.Tile.Floor_rooms || _break_at_east == true:
		_rune_guide_sprite[8][5].visible = false
		_rune_guide_value[8][5] = 0
	
		_break_at_east = true

	if game.map[x+4][y] != Enum.Tile.Floor && game.map[x+4][y] != Enum.Tile.Floor_rooms || _break_at_east == true:
		_rune_guide_sprite[9][5].visible = false
		_rune_guide_value[9][5] = 0
	
		_break_at_east = true
			
	if game.map[x+5][y] != Enum.Tile.Floor && game.map[x+5][y] != Enum.Tile.Floor_rooms || _break_at_east == true:
		_rune_guide_sprite[10][5].visible = false
		_rune_guide_value[10][5] = 0
	
		_break_at_east = true	
		
	# south-east -----------------------------
	var _break_at_south_east:bool = false
	
	if game.map[x+1][y+1] != Enum.Tile.Floor && game.map[x+1][y+1] != Enum.Tile.Floor_rooms:
		_rune_guide_sprite[6][6].visible = false
		_rune_guide_value[6][6] = 0
	
		_break_at_south_east = true
		
	if game.map[x+2][y+2] != Enum.Tile.Floor && game.map[x+2][y+2] != Enum.Tile.Floor_rooms || _break_at_south_east == true:
		_rune_guide_sprite[7][7].visible = false
		_rune_guide_value[7][7] = 0
	
		_break_at_south_east = true

	if game.map[x+3][y+3] != Enum.Tile.Floor && game.map[x+3][y+3] != Enum.Tile.Floor_rooms || _break_at_south_east == true:
		_rune_guide_sprite[8][8].visible = false
		_rune_guide_value[8][8] = 0
	
		_break_at_south_east = true

	if game.map[x+4][y+4] != Enum.Tile.Floor && game.map[x+4][y+4] != Enum.Tile.Floor_rooms || _break_at_south_east == true:
		_rune_guide_sprite[9][9].visible = false
		_rune_guide_value[9][9] = 0
	
		_break_at_south_east = true
			
	if game.map[x+5][y+5] != Enum.Tile.Floor && game.map[x+5][y+5] != Enum.Tile.Floor_rooms || _break_at_south_east == true:
		_rune_guide_sprite[10][10].visible = false
		_rune_guide_value[10][10] = 0
	
		_break_at_south_east = true
			
	# south -----------------------------
	var _break_at_south:bool = false
	
	if game.map[x][y+1] != Enum.Tile.Floor && game.map[x][y+1] != Enum.Tile.Floor_rooms:
		_rune_guide_sprite[5][6].visible = false
		_rune_guide_value[5][6] = 0 
	
		_break_at_south = true
		
	if game.map[x][y+2] != Enum.Tile.Floor && game.map[x][y+2] != Enum.Tile.Floor_rooms || _break_at_south == true:
		_rune_guide_sprite[5][7].visible = false
		_rune_guide_value[5][7] = 0
	
		_break_at_south = true

	if game.map[x][y+3] != Enum.Tile.Floor && game.map[x][y+3] != Enum.Tile.Floor_rooms || _break_at_south == true:
		_rune_guide_sprite[5][8].visible = false
		_rune_guide_value[5][8] = 0
	
		_break_at_south = true

	if game.map[x][y+4] != Enum.Tile.Floor && game.map[x][y+4] != Enum.Tile.Floor_rooms || _break_at_south == true:
		_rune_guide_sprite[5][9].visible = false
		_rune_guide_value[5][9] = 0
	
		_break_at_south = true
			
	if game.map[x][y+5] != Enum.Tile.Floor && game.map[x][y+5] != Enum.Tile.Floor_rooms || _break_at_south == true:
		_rune_guide_sprite[5][10].visible = false
		_rune_guide_value[5][10] = 0
	
		_break_at_south = true
			
	
	# south-west -----------------------------
	var _break_at_south_west:bool = false
	
	if game.map[x-1][y+1] != Enum.Tile.Floor && game.map[x-1][y+1] != Enum.Tile.Floor_rooms:
		_rune_guide_sprite[4][6].visible = false
		_rune_guide_value[4][6] = 0
	
		_break_at_south_west = true
		
	if game.map[x-2][y+2] != Enum.Tile.Floor && game.map[x-2][y+2] != Enum.Tile.Floor_rooms || _break_at_south_west == true:
		_rune_guide_sprite[3][7].visible = false
		_rune_guide_value[3][7] = 0
	
		_break_at_south_west = true
	
	if game.map[x-3][y+3] != Enum.Tile.Floor && game.map[x-3][y+3] != Enum.Tile.Floor_rooms || _break_at_south_west == true:
		_rune_guide_sprite[2][8].visible = false
		_rune_guide_value[2][8] = 0
	
		_break_at_south_west = true

	if game.map[x-4][y+4] != Enum.Tile.Floor && game.map[x-4][y+4] != Enum.Tile.Floor_rooms || _break_at_south_west == true:
		_rune_guide_sprite[1][9].visible = false
		_rune_guide_value[1][9] = 0
	
		_break_at_south_west = true
			
	if game.map[x-5][y+5] != Enum.Tile.Floor && game.map[x-5][y+5] != Enum.Tile.Floor_rooms || _break_at_south_west == true:
		_rune_guide_sprite[0][10].visible = false
		_rune_guide_value[0][10] = 0
	
		_break_at_south_west = true
	
	
	# west -----------------------------
	var _break_at_west:bool = false
	
	if game.map[x-1][y] != Enum.Tile.Floor && game.map[x-1][y] != Enum.Tile.Floor_rooms:
		_rune_guide_sprite[4][5].visible = false
		_rune_guide_value[4][5] = 0 
	
		_break_at_west = true
		
	if game.map[x-2][y] != Enum.Tile.Floor && game.map[x-2][y] != Enum.Tile.Floor_rooms || _break_at_west == true:
		_rune_guide_sprite[3][5].visible = false
		_rune_guide_value[3][5] = 0
	
		_break_at_west = true
	
	if game.map[x-3][y] != Enum.Tile.Floor && game.map[x-3][y] != Enum.Tile.Floor_rooms || _break_at_west == true:
		_rune_guide_sprite[2][5].visible = false
		_rune_guide_value[2][5] = 0
	
		_break_at_west = true

	if game.map[x-4][y] != Enum.Tile.Floor && game.map[x-4][y] != Enum.Tile.Floor_rooms || _break_at_west == true:
		_rune_guide_sprite[1][5].visible = false
		_rune_guide_value[1][5] = 0
	
		_break_at_west = true
			
	if game.map[x-5][y] != Enum.Tile.Floor && game.map[x-5][y] != Enum.Tile.Floor_rooms || _break_at_west == true:
		_rune_guide_sprite[0][5].visible = false
		_rune_guide_value[0][5] = 0
	
		_break_at_west = true
			
			
	# north-west -----------------------------
	var _break_at_north_west:bool = false
	
	if game.map[x-1][y-1] != Enum.Tile.Floor && game.map[x-1][y-1] != Enum.Tile.Floor_rooms:
		_rune_guide_sprite[4][4].visible = false
		_rune_guide_value[4][4] = 0
	
		_break_at_north_west = true
		
	if game.map[x-2][y-2] != Enum.Tile.Floor && game.map[x-2][y-2] != Enum.Tile.Floor_rooms || _break_at_north_west == true:
		_rune_guide_sprite[3][3].visible = false
		_rune_guide_value[3][3] = 0
	
		_break_at_north_west = true
	
	if game.map[x-3][y-3] != Enum.Tile.Floor && game.map[x-3][y-3] != Enum.Tile.Floor_rooms || _break_at_north_west == true:
		_rune_guide_sprite[2][2].visible = false
		_rune_guide_value[2][2] = 0
	
		_break_at_north_west = true

	if game.map[x-4][y-4] != Enum.Tile.Floor && game.map[x-4][y-4] != Enum.Tile.Floor_rooms || _break_at_north_west == true:
		_rune_guide_sprite[1][1].visible = false
		_rune_guide_value[1][1] = 0
		
		_break_at_north_west = true
		
	if game.map[x-5][y-5] != Enum.Tile.Floor && game.map[x-5][y-5] != Enum.Tile.Floor_rooms || _break_at_north_west == true:
		_rune_guide_sprite[0][0].visible = false
		_rune_guide_value[0][0] = 0
		_break_at_north_west = true
		
	
func rune_position_hide():	
	for _x in range (0, 11):
		for _y in range (0, 11):
			if _rune_guide_sprite.size() != 0:
				if _rune_guide_value[_x][_y] == 1:	
					if _rune_guide_sprite[_x][_y] != null:
						_rune_guide_sprite[_x][_y].visible = false
