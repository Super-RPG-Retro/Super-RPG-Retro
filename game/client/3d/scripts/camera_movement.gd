"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends KinematicBody

var amountMove = 1 #if you wanna go fast make this big.
var amountAngle = 2

# camera movement in an up or down direction.
var _camera_movement = 0
# camera rotation. player is moving left or right.
var _camera_rotation = 0

# the direction the player is moving in. This does the smooth motion. if moving forward then this var increment in value until it reaches the end value. only then can the player move again.
var _movement_direction = Vector3(0, 0, 0)

# when one of these values are true, a block of code stops player from moving, when player is already movement. we cannot have the player stopping on floor in-between two blocks. that would break code. 
# these vars are used to do the smooth movement when one of these values is true.
var moveUp = false
var moveDown = false
var moveLeft = false
var moveRight = false

# camera rotation.
var targetRotation = 0

func _ready():
	set_process_input(true)


func _process(_delta):
	# continuous rotation of player in one direction would result in a value greater than 360. for easer programming if value is greater than 360, set back to 0
	if targetRotation == -90:
		targetRotation = 270
	if targetRotation == 360:
		targetRotation = 0
	
	rotation_degrees = Vector3(0, targetRotation, 0)


func _physics_process(_delta):
	# Variables._at_library is used to change between library and dungeon while Settings._system.start_3d sets this value when game loads.So return if window is open if not at 3d scene and if tab was pressed because we do not want to walk when these things happen.
	if Variables._at_library == false || Variables._child_scene_open == true || Variables._keyboard_tab_pressed == true:
		return
			
	if Input.is_action_pressed("ui_down") and _camera_movement == 0 and moveUp == false and moveDown == false and moveLeft == false and moveRight == false:
		Variables._compass_update = true
		Hud._loaded.Turns += 1
		
		if targetRotation == 0:
			_movement_direction.z += amountMove
		if targetRotation == 180:
			_movement_direction.z -= amountMove
		if targetRotation == 90:
			_movement_direction.x += amountMove
		if targetRotation == 270:
			_movement_direction.x -= amountMove
		
		moveDown = true
		
	# the player is not moving when moveUp value is false. if everything is ok then player can move.
	if Input.is_action_pressed("ui_up") and _camera_movement == 0 and moveUp == false and moveDown == false and moveLeft == false and moveRight == false:
		Variables._compass_update = true
		Hud._loaded.Turns += 1
		
		# godot has a word bug that they might not ever fix. in 3d think of z coordinate as y and y as z. in this code, player is not moving up and down using the z value. player is moving forward and backwards.
		if targetRotation == 0:
			_movement_direction.z -= amountMove
		if targetRotation == 180:
			_movement_direction.z += amountMove
		if targetRotation == 90:
			_movement_direction.x -= amountMove
		if targetRotation == 270:
			_movement_direction.x += amountMove
			
		moveUp = true
		
	# if player is requesting to move left, set moveLeft var to true so that anymore movement requests are ignore so that the player can finish moving from one block to the next.
	if Variables._compass_update == false && Input.is_action_pressed("ui_left") and moveUp == false and moveDown == false and moveLeft == false and moveRight == false:
		targetRotation += amountAngle
		moveLeft = true
		
	if Variables._compass_update == false && Input.is_action_pressed("ui_right") and moveUp == false and moveDown == false and moveLeft == false and moveRight == false:
		targetRotation -= amountAngle
		moveRight = true
			
	if _camera_movement < 15 and moveDown == true || _camera_movement < 15 and moveUp == true:
		_camera_movement += 1
		var _mas = move_and_slide(_movement_direction, Vector3(0,1,0))
			
		# depending on the direction of targetRotation, move the player.
		if moveDown == true:
			if targetRotation == 0:
				_movement_direction.z += amountMove
			if targetRotation == 180:
				_movement_direction.z -= amountMove
			if targetRotation == 90:
				_movement_direction.x += amountMove
			if targetRotation == 270:
				_movement_direction.x -= amountMove
			
		if moveUp == true:
			if targetRotation == 0:
				_movement_direction.z -= amountMove
			if targetRotation == 180:
				_movement_direction.z += amountMove
			if targetRotation == 90:
				_movement_direction.x -= amountMove
			if targetRotation == 270:
				_movement_direction.x += amountMove
		
		if _camera_movement == 5:
			if Settings._system.sound == true:
				get_tree().call_group("game_audio", "start_walk_timer")
		
	elif _camera_movement == 15  and moveLeft == false and moveRight == false:
		_camera_movement = 0
		_movement_direction = Vector3(0, 0, 0)
		moveUp = false
		moveDown = false
		
	if moveLeft == true or moveRight == true:
		if _camera_rotation < 90 - amountAngle:
			_camera_rotation += amountAngle
						
			if moveLeft == true:
				targetRotation += amountAngle
				
			if moveRight == true:
				targetRotation -= amountAngle
				
		else:
			Variables._compass_update = true
			_camera_rotation = 0
			moveLeft = false
			moveRight = false

	_movement_direction.x = round(_movement_direction.x)
	_movement_direction.z = round(_movement_direction.z)
	
	if Variables._at_library == true:
		Variables._dungeon_coordinates = str(ceil(transform.origin.ceil().x / 2) - 1) + "," + str(ceil(transform.origin.ceil().z / 2) - 1)
	
