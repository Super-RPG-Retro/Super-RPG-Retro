"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends Node2D


var _slash_sounds := []

@onready var shakeTimer := $Timer

# mobs or group of mobs.
@onready var _mobs := [$SpriteMobs1]

# basic sprite used to damaged mobs. this is a none-magic or none-item sprite. just a normal sprite used for hit effect.
@onready var _mobs_slash := [$SpriteMobsSlash1]

# mobs hit points.
@onready var _mobs_hp := [$TemplateMobs1/GridContainer/LabelHPValue]

@onready var _player := $Player
# sprite used when player is damaged. normal hit sprite. a sprite used for a magic hitting player or an item hitting player are different in appearence than this normal hit sprite.
@onready var _player_slash := $SpritePlayerSlash

@onready var _player_hp := $TemplatePlayer/GridContainer/LabelHPValue

# mobs node passed here from the game_world game script.
var _e_node

# game scene. first node of game_world.
var _game

# when player moves, these values change at try_move func.
var _dx := 0
var _dy := 0

# is it the teams turn to move. false equals mobs turn.
var _is_teams_turn := true


func _ready():
	# random slash sounds.
	_slash_sounds = [Preload._slash_0, Preload._slash_1, Preload._slash_2, Preload._slash_3, Preload._slash_4, Preload._slash_5, Preload._slash_6, Preload._slash_7, Preload._slash_8, Preload._slash_9]

	
func _battle_system(e_node, dx:int, dy:int):
	# mobs node.
	_e_node = e_node
	
	# player's position.
	_dx = dx
	_dy = dy
		
	# update mobs hit points.
	for _e_hp in _mobs_hp:
		_e_hp.text = str(_e_node._hp).pad_zeros(3) + "/" + str(_e_node._hp_max).pad_zeros(3)
		_player_hp.text = str(PC._hp).pad_zeros(3) + "/" + str(PC._hp_max).pad_zeros(3)
	
	# if file exists...
	if FileAccess.file_exists(Variables._project_path + "/builder/objects/images/dictionaries/" + str(Builder_playing._config.game_id + 1) + "/mobs/" + str(Builder_playing._data.dungeon_number + 1) + "/" + str(Builder_playing._data.level_number + 1) + "/" + Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][e_node._name]["Class"] + e_node._name.to_lower() + "/1.png"):
		_mobs[0].texture = Filesystem._load_external_image(Variables._project_path + "/builder/objects/images/dictionaries/" + str(Builder_playing._config.game_id + 1) + "/mobs/" + str(Builder_playing._data.dungeon_number + 1) + "/" + str(Builder_playing._data.level_number + 1) + "/" + Json._directory_number[str(Builder_playing._config.game_id)]["mobs"][e_node._name]["Class"] + e_node._name.to_lower() + "/1.png")


func _on_ButtonFight_pressed():
	# is it teams turn to move, if so then attack mobs.
	if _is_teams_turn == true:
		_player_hits_mobs_normal()

# normal hand to hand combat. for magic or items, use a different func.	
func _player_hits_mobs_normal():
	_is_teams_turn = false
	
	# move the player that is attaching.
	_player.get_node("AnimationPlayerFight").play("fight")
		
	var t = Timer.new()
	t.set_wait_time(0.1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	
	await t.timeout
	
	t.queue_free()
	
	# normal slash sprite at mobs location.
	_mobs_slash[0].get_node("AnimationMobsSlash").play("slash")
	
	t = Timer.new()
	t.set_wait_time(0.1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	
	await t.timeout
	
	# free timer from memory.
	t.queue_free()
	
	# mobs nomral damage taking using hit animation.
	_mobs[0].get_node("AnimationMobsFight").play("hit")
	_sound_slash()
	
	# minus mobs hit points for this battle round.
	_e_node._hp -= 1
	_mobs_hp[0].text = str(_e_node._hp).pad_zeros(3) + "/" + str(_e_node._hp_max).pad_zeros(3)
		
	t = Timer.new()
	t.set_wait_time(1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	
	await t.timeout
	
	t.queue_free()
	
	if _e_node._hp <= 0:
		get_tree().call_group("move", "start_timer_yield")
		get_tree().call_group("player_damage", "start_timer_yield")
		get_tree().call_group("game_audio", "_music_scene")
		
		_music_play()
		
		_is_teams_turn = true
		visible = false
		
		return

	_mobs_hits_player_normal()

# normal hand to hand combat. for magic or items, use a different func.
func _mobs_hits_player_normal():
	# mobs moves slightly to different position, ready for attach.
	_mobs[0].get_node("AnimationMobsFight").play("fight")
		
	var t = Timer.new()
	t.set_wait_time(0.1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	
	await t.timeout
	
	t.queue_free()
		
	# normal slash damage to player.
	_player_slash.get_node("AnimationPlayerSlash").play("slash")
	
	t = Timer.new()
	t.set_wait_time(0.1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	
	await t.timeout
	
	t.queue_free()
	
	# player took hit animation.
	_player.get_node("AnimationPlayerFight").play("hit")
	_sound_slash()
	
	# take hitpoints away from player.
	PC._hp -= 1
	_player_hp.text = str(PC._hp).pad_zeros(3) + "/" + str(PC._hp_max).pad_zeros(3)

	Variables.camera.shake(150, 0.7, 250)
	Variables.camera.shake(300, 0.7, 300)
	# distance, time, shake distance max
	Variables.camera.shake(500, 0.7, 500)	
	
	t = Timer.new()
	t.set_wait_time(0.3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	
	await t.timeout
	
	t.queue_free()
	_is_teams_turn = true	

# slash is a normal hand fighting sound. for magic or itams use a different func.
func _sound_slash():
	if Settings._system.sound == true:
		# if this fails then decrease the value by 1.
		var _sound = randi() % 10 
			
		$SoundSlash.stream = _slash_sounds[_sound]
		$SoundSlash.play()


# return to main map.
func _on_run_Button_pressed():
	get_tree().call_group("move", "start_timer_yield")
	get_tree().call_group("player_damage", "start_timer_yield")
	get_tree().call_group("game_audio", "_music_scene")
	
	_music_play()
	
	_is_teams_turn = true
	
	visible = false
	

func _music_play():
	if Settings._system.music == true:
		Common._music_play(Builder_playing._audio_music.file_name[1], 1, false)
		Variables._last_known_music_id = 1
		
