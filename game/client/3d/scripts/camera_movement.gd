"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends CharacterBody3D

var _dx := 0
var _dz := 0

var amountMove := 1 #make this big if you want to go fast.
var amountAngle := 2

# camera movement in an up or down direction.
var _camera_movement := 0
# camera rotation. player is moving left or right.
var _camera_rotation := 0

# the direction the player is moving in. This does the smooth motion. if moving forward then this var increment in value until it reaches the end value. only then can the player move again.
var _movement_direction := Vector3(0, 0, 0)

# when one of these values are true, a block of code stops player from moving, when player is already movement. we cannot have the player stopping on floor in-between two blocks. that would break code. 
# these vars are used to do the smooth movement when one of these values is true.
var moveUp 		:= false
var moveDown 	:= false
var moveLeft 	:= false
var moveRight 	:= false


func _ready():
	set_process_input(true)
	

func _process(_delta):
	# continuous rotation of player in one direction would result in a value greater than 360. for easer programming if value is greater than 360, set back to 0
	if Variables._player_target_rotation == -90:
		Variables._player_target_rotation = 270
	if Variables._player_target_rotation == 360:
		Variables._player_target_rotation = 0
	
	rotation_degrees = Vector3(0, Variables._player_target_rotation, 0)


func _physics_process(_delta):
	# Variables._at_library is used to change between library and dungeon while Settings._system.start_3d sets this value when game loads.So return if window is open if not at 3d scene and if tab was pressed because we do not want to walk when these things happen.
	if Variables._at_library == false || Variables._child_scene_open == true || Variables._keyboard_tab_pressed == true:
		return
			
	if Input.is_action_pressed("ui_down") and _camera_movement == 0 and moveUp == false and moveDown == false and moveLeft == false and moveRight == false:
		if Variables._player_stop_moving == false:
			Variables._compass_update = true
			Hud._loaded.Turns += 1
			
			if Variables._player_target_rotation == 0:
				_movement_direction.z += amountMove
				_dx = int(round(position.x))
				_dz = int(round(position.z)) + 1
			
			if Variables._player_target_rotation == 180:
				_movement_direction.z -= amountMove
				_dx = int(round(position.x))
				_dz = int(round(position.z)) - 1
				
			if Variables._player_target_rotation == 90:
				_movement_direction.x += amountMove
				_dx = int(round(position.x)) + 1
				_dz = int(round(position.z))
				
			if Variables._player_target_rotation == 270:
				_movement_direction.x -= amountMove
				_dx = int(round(position.x)) - 1
				_dz = int(round(position.z))
				
			moveDown = true
			
		else:
			Variables._player_stop_moving = false
			
	# the player is not moving when moveUp value is false. if everything is ok then player can move.
	if Input.is_action_pressed("ui_up") and _camera_movement == 0 and moveUp == false and moveDown == false and moveLeft == false and moveRight == false:
		if Variables._player_stop_moving == false:
			Variables._compass_update = true
			Hud._loaded.Turns += 1
			
			# in 3d think of z coordinate as y and y as z. in this code, player is not moving up and down using the z value. player is moving forward and backwards.
			if Variables._player_target_rotation == 0:
				_movement_direction.z -= amountMove
				_dx = int(round(position.x))
				_dz = int(round(position.z)) - 1
				
			if Variables._player_target_rotation == 180:
				_movement_direction.z += amountMove
				_dx = int(round(position.x))
				_dz = int(round(position.z)) + 1
				
			if Variables._player_target_rotation == 90:
				_movement_direction.x -= amountMove
				_dx = int(round(position.x)) - 1
				_dz = int(round(position.z))
				
			if Variables._player_target_rotation == 270:
				_movement_direction.x += amountMove
				_dx = int(round(position.x)) + 1
				_dz = int(round(position.z))
				
			moveUp = true
			
		else:
			Variables._player_stop_moving = false
			
	# if player is requesting to move left, set moveLeft var to true so that anymore movement requests are ignore so that the player can finish moving from one block to the next.
	if Variables._compass_update == false && _camera_movement == 0 && Input.is_action_pressed("ui_left") and moveUp == false and moveDown == false and moveLeft == false and moveRight == false:
		Variables._player_target_rotation += amountAngle
		moveLeft = true
		
	if Variables._compass_update == false && _camera_movement == 0 && Input.is_action_pressed("ui_right") and moveUp == false and moveDown == false and moveLeft == false and moveRight == false:
		Variables._player_target_rotation -= amountAngle
		moveRight = true
			
	if _camera_movement < 10 and moveDown == true || _camera_movement < 10 and moveUp == true:
		_camera_movement += 1
		
		# move player if cell is empty or a player cell.
		if $"..".get_cell_item(Vector3i(_dx, 0, _dz)) == -1 || $"..".get_cell_item(Vector3i(_dx, 0, _dz)) >= 90:
			set_velocity(_movement_direction)
			set_up_direction(Vector3(0,1,0))
			move_and_slide()
			
		# depending on the direction of Variables._player_target_rotation, move the player.
		if moveDown == true:
			if Variables._player_target_rotation == 0:
				_movement_direction.z += amountMove
			if Variables._player_target_rotation == 180:
				_movement_direction.z -= amountMove
			if Variables._player_target_rotation == 90:
				_movement_direction.x += amountMove
			if Variables._player_target_rotation == 270:
				_movement_direction.x -= amountMove
			
		if moveUp == true:
			if Variables._player_target_rotation == 0:
				_movement_direction.z -= amountMove
			if Variables._player_target_rotation == 180:
				_movement_direction.z += amountMove
			if Variables._player_target_rotation == 90:
				_movement_direction.x -= amountMove
			if Variables._player_target_rotation == 270:
				_movement_direction.x += amountMove
		
		if _camera_movement == 10:
			if Settings._system.sound == true:
				get_tree().call_group("game_audio", "start_walk_timer")
		
	elif _camera_movement == 10 and moveLeft == false and moveRight == false:
		position.x = round(position.x)
		position.z = round(position.z)

		_camera_movement = 0
		_movement_direction = Vector3(0, 0, 0)
		moveUp = false
		moveDown = false
		
	if moveLeft == true or moveRight == true:
		if _camera_rotation < 90 - amountAngle:
			_camera_rotation += amountAngle
						
			if moveLeft == true:
				Variables._player_target_rotation += amountAngle
				
			if moveRight == true:
				Variables._player_target_rotation -= amountAngle
				
		else:
			Variables._compass_update = true
			_camera_rotation = 0
			moveLeft = false
			moveRight = false

	_movement_direction.x = round(_movement_direction.x)
	_movement_direction.z = round(_movement_direction.z)
	
	if Variables._at_library == true:
		Variables._dungeon_coordinates = str(ceil(transform.origin.ceil().x / 2)) + "," + str(ceil(transform.origin.ceil().z / 2))
	
