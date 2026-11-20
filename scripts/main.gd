class_name Main extends Control
@onready var shoot_self: Button = $Button
@onready var pass_gun: Button = $Button2
@onready var shoot_sky: Button = $Button3
@onready var point_label: Label = $MarginContainer/VBoxContainer/Label
@onready var texture_rect_live: TextureRect = $MarginContainer3/HBoxContainer/TextureRect
@onready var texture_rect_blank: TextureRect = $MarginContainer3/HBoxContainer/TextureRect2
@onready var label_live: Label = $MarginContainer3/HBoxContainer/TextureRect/Label
@onready var label_blank: Label = $MarginContainer3/HBoxContainer/TextureRect2/Label
@onready var barrel_texture: TextureRect = $TextureRect3
@onready var claim_barrel_texture: TextureRect = $TextureRect10
@onready var mult_display: Label = $MarginContainer/VBoxContainer/Label2
@onready var blank_sfx: AudioStreamPlayer = $AudioStreamPlayer
@onready var load_sfx: AudioStreamPlayer = $AudioStreamPlayer2
@onready var shoot_sfx: AudioStreamPlayer = $AudioStreamPlayer3
@onready var pass_sfx: AudioStreamPlayer = $AudioStreamPlayer4
@onready var shatter_sfx: AudioStreamPlayer = $AudioStreamPlayer6
@onready var door_sfx: AudioStreamPlayer = $AudioStreamPlayer7
@onready var empty_sfx: AudioStreamPlayer = $AudioStreamPlayer8
@onready var timer: Timer = $Timer
@onready var blackout: ColorRect = $ColorRect
@onready var bot1_body: AnimatedSprite2D = $bot1/AnimatedSprite2D
@onready var bot2_body: AnimatedSprite2D = $bot2/AnimatedSprite2D
@onready var fade_in: ColorRect = $fade_in
@onready var gun: TextureRect = $TextureRect
@onready var mstr_vol: TextureRect = $VBoxContainer/radio/HBoxContainer/mstr_vol
@onready var music_vol: TextureRect = $VBoxContainer/radio/HBoxContainer/music_vol
@onready var sfx_vol: TextureRect = $VBoxContainer/radio/HBoxContainer/sfx_vol
@onready var radio_big: VBoxContainer = $VBoxContainer
@onready var highscore: Label = $highscore


@export var live: int = 0
@export var blank: int = 0
@export var empty: int = 6
var barrel: Array[int] = [0, 0, 0, 0, 0, 0]
@export var claim_barrel: Array[int] = [0, 0, 0, 0, 0, 0]
@export var player_barrel: Array[int] = [0, 0, 0, 0, 0, 0]
@export var bot1_barrel: Array[int] = [0, 0, 0, 0, 0, 0]
@export var bot2_barrel: Array[int] = [0, 0, 0, 0, 0, 0]
var loaded_barrel: Array[int] = [0, 0, 0, 0, 0, 0]
var loading_claim_barrel: Array[int] = [0, 0, 0, 0, 0, 0]
var legacy_barrel: Array[int] = [0, 0, 0, 0, 0, 0]
@export var claim_live: int = 0
@export var claim_blank: int = 0
@export var high_points : int
@export var mstr_vol_var: float
@export var sfx_vol_var: float
@export var music_vol_var: float
const SAVE_FOLDER : String = "user://"
class bot:
	var aggression: int = 0
	var deceptiveness: float = 0.5
	var live: int = 0
	var blank: int = 0
	var passed: int = 0
	var value: int

#DONE fix bot displaying the actual load that only gets overwritten to their claim shortly after
#DONE implement bot logic thru class bot
#PLAYTEST rework the current blank/empty chamber issue (WIP - heavy test, check if bots don't cheat)
#TODO add faces to represent the agression of bots
#TODO stylize newly added bullets yellow (1/2)
#TODO? make a new prediction bar
#TODO show a dotted bullet in the bar for a moment after shooting empty

var player_live: int = 0
var player_blank: int = 0
var player_reload_live : int
var player_reload_blank : int
var player_reload_claim_live : int
var player_reload_claim_blank : int
var reloading: bool = false
var label_live_value : int
var label_blank_value : int
var mult: float = 1
var points: int = 0
var whose_turn : int = 0
var passed : int = 0
var first_load: int = 0
var missing_shots : int
var rand_skin_bot1 : int
var rand_skin_bot2 : int
var touch : Array[bool]
var tween1 : Tween
var tween2 : Tween
var tween3 : Tween
var tween4 : Tween
var tween5 : Tween
var tween6 : Tween
var tween7 : Tween 
var tween8 : Tween
var tween9 : Tween #gun animations
var tween10 : Tween
var tween11 : Tween
var bot1
var bot2
@export var ammo : Array[TextureRect] = []
@export var claim_barrel_ammo : Array[TextureRect] = []
@export var player_ammo : Array[TextureRect] = []
@export var claim_ammo : Array[TextureRect] = []
const BLACKOUT_TIME = 0.4
var pause: bool = false
var dead : bool = false

func _ready() -> void: 
	for i in ammo.size():
		ammo[i].texture = load("res://textures/Blank.svg")
		ammo[i].visible = 0
	barrel = [0, 0, 0, 0, 0, 0]
	legacy_barrel = [0, 0, 0, 0, 0, 0]
	claim_barrel = [0, 0, 0, 0, 0, 0]
	player_barrel = [0, 0, 0, 0, 0, 0]
	bot1 = bot.new()
	bot2 = bot.new()
	highscore.visible = 0
	load_data()
	if not high_points:
		high_points = 0
	if not mstr_vol_var:
		mstr_vol_var = GlobalVars.mstr_vol
		music_vol_var = GlobalVars.music_vol
		sfx_vol_var = GlobalVars.sfx_vol
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), clamp(mstr_vol_var, 0, 1))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), clamp(sfx_vol_var, 0, 1))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), clamp(music_vol_var, 0, 1))
	dead = 0
	point_label.offset_transform_position = Vector2(0, 0)
	mult_display.offset_transform_position = Vector2(0, 0)
	point_label.z_index = 0
	mult_display.z_index = 0
	fade_in.visible = 1
	fade_in.color.a = 1
	tween3 = reset_tween(tween3)
	tween3.tween_property(fade_in, "color:a", 0, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	blackout.visible = 0
	shoot_self.visible = 0
	shoot_sky.visible = 0
	pass_gun.visible = 0
	barrel_texture.visible = 0
	claim_barrel_texture.visible = 0
	texture_rect_blank.visible = 0
	texture_rect_live.visible = 0
	door_sfx.play()
	whose_turn = randi_range(0, 2)
	if whose_turn == 0:
		gun.position = Vector2(553, 420)
		gun.scale = Vector2(1.0, 1.0)
		gun.rotation = deg_to_rad(328)
	elif whose_turn == 1:
		gun.position = Vector2(306, 389)
		gun.scale = Vector2(0.8, 0.8)
		gun.rotation = deg_to_rad(115)
	elif whose_turn == 2:
		gun.position = Vector2(712, 380)
		gun.scale = Vector2(0.8, 0.8)
		gun.rotation = deg_to_rad(265)
	bot1_body.visible = 0
	bot2_body.visible = 0
	await tween3.finished
	fade_in.visible = 0
	bot1_body.visible = 1
	bot2_body.visible = 0
	rand_skin_bot1 = randi_range(0, 2)
	if rand_skin_bot1 == 0:
		bot1_body.play("mid_appear")
	elif rand_skin_bot1 == 1:
		bot1_body.play("thin_appear")
	elif rand_skin_bot1 == 2:
		bot1_body.play("thick_appear")
	await bot1_body.animation_finished
	bot2_body.visible = 1
	rand_skin_bot2 = randi_range(0, 2)
	if rand_skin_bot2 == 0:
		bot2_body.play("mid_appear")
	elif rand_skin_bot2 == 1:
		bot2_body.play("thin_appear")
	elif rand_skin_bot2 == 2:
		bot2_body.play("thick_appear")
	await bot2_body.animation_finished
	first_load = 1
	print("which hacker is illegal? is .exe evil? am i evil? are we evil? who is evil? trust no one.")
	barrel_texture.visible = 0
	claim_barrel_texture.visible = 0
	texture_rect_live.visible = 0
	texture_rect_blank.visible = 0
	bot1.aggression = randi_range(-1, 2)
	bot1.deceptiveness = randf_range(0.0, 1.0)
	bot2.aggression = randi_range(-1, 2)
	bot2.deceptiveness = randf_range(0.0, 1.0)
	bot1_barrel = [0, 0, 0, 0, 0, 0]
	bot2_barrel = [0, 0, 0, 0, 0, 0]
	
func _process(_delta: float) -> void:
	live = 0
	blank = 0
	claim_live = 0
	claim_blank = 0
	player_live = 0
	player_blank = 0
	bot1.live = 0
	bot2.blank = 0
	bot2.live = 0
	bot2.blank = 0
	for i in barrel:
		if i == 1:
			blank += 1
		if i == 2:
			live += 1
	for i in claim_barrel:
		if i == 1:
			claim_blank += 1
		if i == 2:
			claim_live += 1
	for i in player_barrel:
		if i == 1:
			player_blank += 1
		if i == 2:
			player_live += 1
	for i in bot1_barrel:
		if i == 1:
			bot1.blank += 1
		if i == 2:
			bot1.live += 1
	for i in bot2_barrel:
		if i == 1:
			bot2.blank += 1
		if i == 2:
			bot2.live += 1
	mstr_vol_var = clamp(mstr_vol_var, 0, 1)
	sfx_vol_var = clamp(sfx_vol_var, 0, 1)
	music_vol_var = clamp(music_vol_var, 0, 1)
	mstr_vol.offset_transform_rotation = deg_to_rad(mstr_vol_var*284-142)
	music_vol.offset_transform_rotation = deg_to_rad(music_vol_var*284-142)
	sfx_vol.offset_transform_rotation = deg_to_rad(sfx_vol_var*284-142)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), clamp(mstr_vol_var, 0, 1))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), clamp(music_vol_var, 0, 1))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), clamp(sfx_vol_var, 0, 1))
	GlobalVars.mstr_vol = mstr_vol_var
	GlobalVars.music_vol = music_vol_var
	GlobalVars.sfx_vol = sfx_vol_var
	if (mstr_vol.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_up")):
		if Input.is_action_pressed("shift"):
			mstr_vol_var += 0.05
		else:
			mstr_vol_var += 0.01
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), clamp(mstr_vol_var, 0, 1))
	elif (mstr_vol.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_down")):
		if Input.is_action_pressed("shift"):
			mstr_vol_var -= 0.05
		else:
			mstr_vol_var -= 0.01
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), clamp(mstr_vol_var, 0, 1))

	if (sfx_vol.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_up")):
		if Input.is_action_pressed("shift"):
			sfx_vol_var += 0.05
		else:
			sfx_vol_var += 0.01
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), clamp(sfx_vol_var, 0, 1))

	elif (sfx_vol.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_down")):
		if Input.is_action_pressed("shift"):
			sfx_vol_var -= 0.05
		else:
			sfx_vol_var -= 0.01
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), clamp(sfx_vol_var, 0, 1))

	if (music_vol.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_up")):
		if Input.is_action_pressed("shift"):
			music_vol_var += 0.05
		else:
			music_vol_var += 0.01
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), clamp(music_vol_var, 0, 1))
	elif (music_vol.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_down")):
		if Input.is_action_pressed("shift"):
			music_vol_var -= 0.05
		else:
			music_vol_var -= 0.01
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), clamp(music_vol_var, 0, 1))
	if Input.is_action_just_pressed("esc") and not pause:
		pause = true
		shoot_self.disabled = 1
		shoot_sky.disabled = 1
		pass_gun.disabled = 1
		fade_in.visible = 1
		fade_in.color.a = 0
		tween11 = reset_tween(tween11)
		tween11.set_parallel(true)
		tween11.tween_property(fade_in, "color:a", 0.8, 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		tween11.tween_property(radio_big, "position", Vector2(105, 106), 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		await tween11.finished
	elif Input.is_action_just_pressed("esc") and pause:
		pause = false
		shoot_self.disabled = 0
		shoot_sky.disabled = 0
		pass_gun.disabled = 0
		fade_in.color.a = 0.8
		tween11 = reset_tween(tween11)
		tween11.set_parallel(true)
		tween11.tween_property(fade_in, "color:a", 0., 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		tween11.tween_property(radio_big, "position", Vector2(105, -450), 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		await tween11.finished
		fade_in.visible = 0

	mult = clamp(mult, 1, abs(mult)+1)
	mult_display.text = "x" + str(mult)
	claim_blank = clamp(claim_blank, 0, 6)
	player_blank = clamp(player_blank, 0, 6)
	claim_live = clamp(claim_live, 0, 6)
	player_live = clamp(player_live, 0, 6)
	bot1.blank = clamp(bot1.blank, 0, 6)
	bot2.blank = clamp(bot2.blank, 0, 6)
	bot1.live = clamp(bot1.live, 0, 6)
	bot2.live = clamp(bot2.live, 0, 6)
	claim_blank = clamp(claim_blank, 0, 6 - claim_live)
	player_blank = clamp(player_blank, 0, 6 - player_live)
	bot1.blank = clamp(bot1.blank, 0, 6 - bot1.live)
	bot2.blank = clamp(bot2.blank, 0, 6 - bot2.live)
	if first_load:
		_first_load()
	for i in claim_ammo.size():
		claim_ammo[i].texture = null
	for shot in claim_barrel.size():
		if claim_barrel[shot] == 2:
			claim_ammo[shot].texture = load("res://textures/Live_white.svg")
		if claim_barrel[shot] == 1:
			claim_ammo[shot].texture = load("res://textures/Blank_white.svg")
	for i in player_ammo.size():
		player_ammo[i].texture = null
	for shot in player_barrel.size():
		if player_barrel[shot] == 2:
			player_ammo[shot].texture = load("res://textures/Live_white.svg")
		if player_barrel[shot] == 1:
			player_ammo[shot].texture = load("res://textures/Blank_white.svg")
	points = clamp(points, 0, abs(points))
	blank = clamp(blank, 0, 6)
	live = clamp(live, 0, 6 - blank)
	blank = clamp(blank, 0, 6 - live)
	claim_blank = clamp(claim_blank, 0, 6)
	claim_live = clamp(claim_live, 0, 6 - claim_blank)
	claim_blank = clamp(claim_blank, 0, 6 - claim_live)
	bot1.blank = clamp(bot1.blank, 0, 6)
	bot1.live = clamp(bot1.live, 0, 6 - bot1.blank)
	bot1.blank = clamp(bot1.blank, 0, 6 - bot1.live)
	bot2.blank = clamp(bot2.blank, 0, 6)
	bot2.live = clamp(bot2.live, 0, 6 - bot2.blank)
	bot2.blank = clamp(bot2.blank, 0, 6 - bot2.live)
	if points < 10:
		point_label.text = "0" + str(points)
	else:
		point_label.text = str(points)
	if whose_turn != 0:
		shoot_self.visible = 0
		shoot_sky.visible = 0
		pass_gun.visible = 0
	
	if dead:
		if Input.is_anything_pressed():
			get_tree().reload_current_scene()
	
	if reloading == true:
		for i in ammo.size():
			ammo[i].texture = load("res://textures/Blank.svg")
			ammo[i].visible = 0
		if Input.is_action_just_pressed("lmb") and barrel_texture.get_rect().has_point(get_global_mouse_position()):
			for i in 6:
				if ammo[i].get_global_rect().has_point(get_global_mouse_position()) and barrel[i] == 0:
					loaded_barrel[i] = 2
					load_sfx.play()
					if not touch[i]:
						loading_claim_barrel[i] = 2
						touch[i] = true
					break
		elif Input.is_action_just_pressed("rmb") and barrel_texture.get_rect().has_point(get_global_mouse_position()):
			for i in 6:
				if ammo[i].get_global_rect().has_point(get_global_mouse_position()) and barrel[i] == 0:
					loaded_barrel[i] = 1
					load_sfx.play()
					if not touch[i]:
						loading_claim_barrel[i] = 1
						touch[i] = true
					break
		for i in claim_barrel_ammo.size():
			claim_barrel_ammo[i].texture = load("res://textures/Blank.svg")
			claim_barrel_ammo[i].visible = 0
		if Input.is_action_just_pressed("lmb") and not barrel_texture.get_global_rect().has_point(get_global_mouse_position()):
			for i in 6:
				if claim_barrel_ammo[i].get_global_rect().has_point(get_global_mouse_position()) and barrel[i] == 0:
					loading_claim_barrel[i] = 2
					load_sfx.play()
					touch[i] = true
					break
		elif Input.is_action_just_pressed("rmb") and not barrel_texture.get_rect().has_point(get_global_mouse_position()):
			for i in 6:
				if claim_barrel_ammo[i].get_global_rect().has_point(get_global_mouse_position()) and barrel[i] == 0:
					loading_claim_barrel[i] = 1
					load_sfx.play()
					touch[i] = true
					break
		for round_shot in 6:
			if loaded_barrel[round_shot] == 2:
				ammo[round_shot].texture = load("res://textures/Live_white.svg")
				ammo[round_shot].visible = 1
			if loaded_barrel[round_shot] == 1:
				ammo[round_shot].texture = load("res://textures/Blank_white.svg")
				ammo[round_shot].visible = 1
			if loaded_barrel[round_shot] == 0:
				ammo[round_shot].texture = load("res://textures/Blank.svg")
				ammo[round_shot].visible = 0
			ammo[round_shot].modulate = Color(1, 1, 1)
		for round_shot in 6:
			if loading_claim_barrel[round_shot] == 2:
				claim_barrel_ammo[round_shot].texture = load("res://textures/Live_white.svg")
				claim_barrel_ammo[round_shot].visible = 1
			if loading_claim_barrel[round_shot] == 1:
				claim_barrel_ammo[round_shot].texture = load("res://textures/Blank_white.svg")
				claim_barrel_ammo[round_shot].visible = 1
			if loading_claim_barrel[round_shot] == 0:
				claim_barrel_ammo[round_shot].texture = load("res://textures/Blank.svg")
				claim_barrel_ammo[round_shot].visible = 0
			claim_barrel_ammo[round_shot].modulate = Color(1, 1, 1)
		var iter : int = 0
		for i in 6:
			if loaded_barrel[i] != 0 and loading_claim_barrel[i] != 0:
				iter += 1
			if loaded_barrel[i] != 0 and barrel[i] == 0:
				ammo[i].modulate = Color(0.888, 0.888, 0.202)
				claim_barrel_ammo[i].modulate = Color(0.888, 0.888, 0.202)
		if iter == 6:
			pass_gun.visible = 1

func _on_button_3_button_up() -> void: ##SHOOT THE SKY
	shoot_self.visible = 0
	shoot_sky.visible = 0
	pass_gun.visible = 0
	if reloading == false:
		_shoot_sky()

func _on_button_2_button_up() -> void: ##PASS
	shoot_self.visible = 0
	shoot_sky.visible = 0
	pass_gun.visible = 0
	if reloading == false and passed <= 0:
		pass_sfx.play()
		passed = 2
		_pass()
	else:
		for i in 6:
			if barrel[i] == 0 and loaded_barrel[i] != 0:
				if loaded_barrel[i] != loading_claim_barrel[i]:
					mult -= 0.25
				if loaded_barrel[i] == loading_claim_barrel[i]:
					mult += 0.25
		mult = clamp(mult, 1, abs(mult)+1)
		reloading = 0
		barrel = loaded_barrel
		blank = 0
		live = 0
		for i in loaded_barrel.size():
			if loaded_barrel[i] == 1:
				blank += 1
			if loaded_barrel[i] == 2:
				live += 1
		claim_barrel = loading_claim_barrel
		bot1_barrel = loading_claim_barrel
		bot2_barrel = loading_claim_barrel
		player_blank = blank
		player_live = live
		player_barrel = loaded_barrel
		claim_live += label_live_value
		claim_blank += label_blank_value
		bot1.blank += label_blank_value
		bot1.live += label_live_value
		bot2.blank += label_blank_value
		bot2.live += label_live_value
		for iter in label_live_value:
			var i := 0
			while 1==1:
				if i >= 6:
					break
				if claim_barrel[i] == 0:
					claim_barrel[i] = 2
					bot1_barrel[i] = 2
					bot2_barrel[i] = 2
					break
				i += 1
		for iter in label_blank_value:
			var i := 0
			while 1==1:
				if i >= 6:
					break
				if claim_barrel[i] == 0:
					claim_barrel[i] = 1
					bot1_barrel[i] = 1
					bot2_barrel[i] = 1
					break
				i += 1
		barrel_texture.visible = 0
		claim_barrel_texture.visible = 0
		texture_rect_live.visible = 0
		texture_rect_blank.visible = 0
		_pass()

func _on_button_button_up() -> void: ##SHOOT SELF
	shoot_self.visible = 0
	shoot_sky.visible = 0
	pass_gun.visible = 0
	if reloading == false:
		_shoot_self()

func _shoot_self() -> void:
	tween9 = reset_tween(tween9)
	tween9.set_parallel(true)
	tween9.tween_property(gun, "position", Vector2(667, 157), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween9.tween_property(gun, "scale", Vector2(3.0, 3.0), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween9.tween_property(gun, "rotation", deg_to_rad(204.5), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween9.finished
	timer.start(0.3)
	await timer.timeout
	var index := randi_range(1, 5)
	if barrel[index] == 2:
		shoot_sfx.play()
		fade_in.visible = 1
		fade_in.color.a = 1
		highscore.visible = 1
		highscore.position = Vector2(535, 700)
		point_label.z_index = 7
		mult_display.z_index = 7
		if points > high_points:
			high_points = points
			save_data()
		if high_points < 10:
			highscore.text = "0" + str(high_points)
		else:
			highscore.text = str(high_points)
		tween10 = reset_tween(tween10)
		tween10.set_parallel(true)
		tween10.tween_property(point_label, "offset_transform_position", Vector2(-600, -250), 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		tween10.tween_property(mult_display, "offset_transform_position", Vector2(-400, -190), 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		await tween10.finished
		tween10 = reset_tween(tween10)
		tween10.tween_property(highscore, "global_position", Vector2(535, 450), 0.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		await tween10.finished
		dead = 1
	else:
		blank_sfx.play()
		load_sfx.play()
		tween9 = reset_tween(tween9)
		tween9.set_parallel(true)
		tween9.tween_property(gun, "position", Vector2(790, 450), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween9.tween_property(gun, "scale", Vector2(1.8, 1.8), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween9.tween_property(gun, "rotation", deg_to_rad(328), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween9.finished
		player_reload_blank = 0
		player_reload_live = 0
		shoot_self.visible = 0
		shoot_sky.visible = 0
		pass_gun.visible = 0
		barrel_texture.visible = 1
		claim_barrel_texture.visible = 1
		texture_rect_live.visible = 0
		texture_rect_blank.visible = 0
		points += mult
		if barrel[index] == 1:
			blank -= 1
			blank = clamp(blank, 0, abs(blank))
			barrel[index] = 0
			claim_barrel[index] = 0
			player_barrel[index] = 0
			bot1_barrel[index] = 0
			bot2_barrel[index] = 0
		else:
			empty_sfx.play()
		missing_shots = 0
		for i in barrel:
			if i == 0:
				missing_shots += 1
		reloading = 1
		touch = [false, false, false, false, false, false]
		loaded_barrel = barrel.duplicate(true)
		loading_claim_barrel = claim_barrel.duplicate(true)
		player_barrel = barrel.duplicate(true)
		label_blank_value = missing_shots
		label_live_value = 0

func _shoot_sky() -> void:
	tween9 = reset_tween(tween9)
	tween9.set_parallel(true)
	tween9.tween_property(gun, "position", Vector2(620, 196), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween9.tween_property(gun, "scale", Vector2(1.1, 1.1), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween9.tween_property(gun, "rotation", deg_to_rad(350), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween9.finished
	timer.start(0.3)
	var index := randi_range(1, 5)
	if barrel[index] == 2:
		shoot_sfx.play()
		shatter_sfx.play()
		fade_in.color.a = 1
		timer.start(BLACKOUT_TIME)
		await timer.timeout
		fade_in.visible = 1
		timer.start(BLACKOUT_TIME)
		await timer.timeout
		tween8 = reset_tween(tween8)
		tween8.tween_property(fade_in, "color:a", 0, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		await tween8.finished
		fade_in.visible = 0
		live -= 1
		barrel[index] = 0
		claim_barrel[index] = 0
		player_barrel[index] = 0
		bot1_barrel[index] = 0
		bot2_barrel[index] = 0
	else:
		if barrel[index] == 1:
			blank -= 1
			blank = clamp(blank, 0, abs(blank))
			barrel[index] = 0
			claim_barrel[index] = 0
			player_barrel[index] = 0
			bot1_barrel[index] = 0
			bot2_barrel[index] = 0
			blank_sfx.play()
		else:
			empty_sfx.play()
		mult -= 0.25
		mult = clamp(mult, 1, abs(mult)+1)
		points -= mult
	_pass()

func _pass() -> void:
	whose_turn += 1
	shoot_self.visible = 0
	shoot_sky.visible = 0
	pass_gun.visible = 0
	if whose_turn > 2:
		whose_turn = 0
	if whose_turn == 1:
		bot1.passed -= 1
		tween9 = reset_tween(tween9)
		tween9.set_parallel(true)
		tween9.tween_property(gun, "position", Vector2(306, 389), 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween9.tween_property(gun, "scale", Vector2(0.8, 0.8), 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween9.tween_property(gun, "rotation", deg_to_rad(115), 0.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		await tween9.finished
		bot_one()
	elif whose_turn == 2:
		bot2.passed -= 1
		tween9 = reset_tween(tween9)
		tween9.set_parallel(true)
		tween9.tween_property(gun, "position", Vector2(712, 380), 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween9.tween_property(gun, "scale", Vector2(0.8, 0.8), 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween9.tween_property(gun, "rotation", deg_to_rad(265), 0.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		await tween9.finished
		bot_two()
	elif whose_turn == 0:
		tween9 = reset_tween(tween9)
		tween9.set_parallel(true)
		tween9.tween_property(gun, "position", Vector2(553, 420), 0.6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween9.tween_property(gun, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween9.tween_property(gun, "rotation", deg_to_rad(328), 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		await tween9.finished
		passed -= 1
		shoot_self.visible = 1
		shoot_sky.visible = 1
		if passed <= 0:
			pass_gun.visible = 1
		else:
			pass_gun.visible = 0

func bot_one() -> void:
	bot1.aggression = clamp(bot1.aggression, -1, 2)
	if bot1.blank == 6:
		shoot_bot1()
		return
	if bot1.live == 6:
		shoot_sky_bot1()
		return
	if randi_range(0, 3 + bot1.aggression) == 0 and bot1.passed <= 0:
		bot1.passed = 2
		pass_sfx.play()
		_pass()
		return
	else:
		if bot1.live < bot1.aggression + 3:
			shoot_bot1()
		elif bot1.live > bot1.aggression + 3:
			shoot_sky_bot1()
		else:
			if randi_range(0, 1) == 0:
				shoot_bot1()
			else:
				shoot_sky_bot1()

func bot_two() -> void:
	bot2.aggression = clamp(bot2.aggression, -1, 2)
	if bot2.blank == 6:
		shoot_bot2()
		return
	if bot2.live == 6:
		shoot_sky_bot2()
		return
	if randi_range(0, 3 + bot2.aggression) == 0 and bot2.passed <= 0:
		bot2.passed = 2
		pass_sfx.play()
		_pass()
		return
	else:
		if bot2.live < bot2.aggression + 3:
			shoot_bot2()
		elif bot2.live > bot2.aggression + 3:
			shoot_sky_bot2()
		else:
			if randi_range(0, 1) == 0:
				shoot_bot2()
			else:
				shoot_sky_bot2()

func loading_bot1() -> void:
	blank_sfx.play()
	await blank_sfx.finished
	tween9 = reset_tween(tween9)
	tween9.tween_property(gun, "rotation", deg_to_rad(156), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween9.finished
	bot1.live = 0
	bot1.blank = 0
	for shot in barrel:
		if shot == 2:
			bot1.live += 1
		if shot == 1:
			bot1.blank += 1
	bot1.value = 0
	var iter := 0
	for i in barrel.size():
		if barrel[i] == 0:
			iter += 1
	for shot in iter:
		var shot_type : bool
		if bot1.aggression < 2:
			if randi_range(0, 1) == 0:
				shot_type = 1
			else:
				shot_type = 0
		else:
			if randi_range(0, 2) > 0:
				shot_type = 1
			else:
				shot_type = 0
		if randf_range(0.0, 1.0) <= bot1.deceptiveness:
			if shot_type:
				barrel_update(true, true, false)
			else:
				barrel_update(false, true, false)
		else:
			if not shot_type:
				barrel_update(true, false, false)
			else:
				barrel_update(false, false, false)
		load_sfx.play()
		timer.start(0.1)
		await timer.timeout
	timer.start(0.3)
	await timer.timeout
	_pass()

func loading_bot2() -> void:
	blank_sfx.play()
	await blank_sfx.finished
	tween9 = reset_tween(tween9)
	tween9.tween_property(gun, "rotation", deg_to_rad(210), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween9.finished
	bot2.live = 0
	bot2.blank = 0
	for shot in live:
		bot2.live += 1
	for shot in blank:
		bot2.blank += 1
	bot2.value = 0
	var iter := 0
	for i in barrel.size():
		if barrel[i] == 0:
			iter += 1
	for shot in iter:
		var shot_type : bool
		if bot2.aggression < 2:
			if randi_range(0, 1) == 0:
				shot_type = 1
			else:
				shot_type = 0
		else:
			if randi_range(0, 2) > 0:
				shot_type = 1
			else:
				shot_type = 0
		if randf_range(0.0, 1.0) <= bot2.deceptiveness:
			if shot_type:
				barrel_update(true, false, true)
			else:
				barrel_update(false, false, true)
		else:
			if not shot_type:
				barrel_update(true, false, false)
			else:
				barrel_update(false, false, false)
		load_sfx.play()
		timer.start(0.1)
		await timer.timeout
	timer.start(0.3)
	await timer.timeout
	_pass()

func _first_load():
	if whose_turn == 0:
		shoot_self.visible = 0
		shoot_sky.visible = 0
		pass_gun.visible = 0
		barrel_texture.visible = 1
		texture_rect_live.visible = 0
		texture_rect_blank.visible = 0
		
		for i in ammo.size():
			ammo[i].texture = load("res://textures/Blank.svg")
			ammo[i].visible = 0
		if Input.is_action_just_pressed("lmb") and barrel_texture.get_rect().has_point(get_global_mouse_position()):
			for i in 6:
				if ammo[i].get_global_rect().has_point(get_global_mouse_position()) and barrel[i] == 0:
					barrel[i] = 2
					claim_barrel[i] = 2
					player_barrel[i] = 2
					bot1_barrel[i] = 2
					bot2_barrel[i] = 2
					load_sfx.play()
					break
			if not load_sfx.playing:
				var it = 0
				while 1==1:
					if it >= 6:
						break
					if claim_barrel[it] == 0:
						barrel[it] = 2
						claim_barrel[it] = 2
						player_barrel[it] = 2
						bot1_barrel[it] = 2
						bot2_barrel[it] = 2
						load_sfx.play()
						break
					it += 1
		elif Input.is_action_just_pressed("rmb") and barrel_texture.get_rect().has_point(get_global_mouse_position()):
			for i in 6:
				if ammo[i].get_global_rect().has_point(get_global_mouse_position()) and barrel[i] == 0:
					barrel[i] = 1
					claim_barrel[i] = 1
					player_barrel[i] = 1
					bot1_barrel[i] = 1
					bot2_barrel[i] = 1
					load_sfx.play()
					break
			if not load_sfx.playing:
				var it = 0
				while 1==1:
					if it >= 6:
						break
					if claim_barrel[it] == 0:
						barrel[it] = 1
						claim_barrel[it] = 1
						player_barrel[it] = 1
						bot1_barrel[it] = 1
						bot2_barrel[it] = 1
						load_sfx.play()
						break
					it += 1
		for round_shot in 6:
			if barrel[round_shot] == 2:
				ammo[round_shot].texture = load("res://textures/Live_white.svg")
				ammo[round_shot].visible = 1
			if barrel[round_shot] == 1:
				ammo[round_shot].texture = load("res://textures/Blank_white.svg")
				ammo[round_shot].visible = 1
			if barrel[round_shot] == 0:
				ammo[round_shot].texture = load("res://textures/Blank.svg")
				ammo[round_shot].visible = 0
			ammo[round_shot].modulate = Color(1, 1, 1)
		var iter : int = 0
		blank = 0
		live = 0
		for i in 6:
			if loaded_barrel[i] != 0 and loading_claim_barrel[i] != 0:
				iter += 1
			if loaded_barrel[i] != 0 and barrel[i] == 0:
				ammo[i].modulate = Color(0.888, 0.888, 0.202)
				claim_barrel_ammo[i].modulate = Color(0.888, 0.888, 0.202)
			if barrel[i] == 1:
				blank += 1
			if barrel[i] == 2:
				live += 1
		bot2.blank = blank
		bot2.live = live
		bot1.blank = blank
		bot1.live = live
		player_blank = blank
		player_live = live
		claim_blank = blank
		claim_live = live 
		
		if live + blank == 6: 
			first_load = 0
			barrel_texture.visible = 0
			claim_barrel_texture.visible = 0
			_pass()
			return
	else:
		first_load = 0
		barrel_texture.visible = 0
		claim_barrel_texture.visible = 0
		for i in 6:
			if randi_range(0, 1) == 1:
				barrel[i] = 2
				claim_barrel[i] = 2
				player_barrel[i] = 2
				bot1_barrel[i] = 2
				bot2_barrel[i] = 2
			else:
				barrel[i] = 1
				claim_barrel[i] = 1
				player_barrel[i] = 1
				bot1_barrel[i] = 1
				bot2_barrel[i] = 1
			load_sfx.play()
			await load_sfx.finished
		bot1.blank = blank
		bot1.live = live
		bot2.blank = blank
		bot2.live = live
		claim_blank = blank
		claim_live = live
		player_blank = blank
		player_live = live
		_pass()
		return

func resolve_claim_issues_blank() -> void:
	if claim_blank > 0:
		claim_blank -= 1
	elif claim_live == 6:
		claim_live -= 1
	
	if player_blank > 0:
		player_blank -= 1
	elif player_live == 6:
		player_live -= 1
	
	if bot1.blank > 0:
		bot1.blank -= 1
	elif bot1.live == 6:
		bot1.live -= 1
	
	if bot2.blank > 0:
		bot2.blank -= 1
	elif bot2.live == 6:
		bot2.live -= 1
	
func resolve_claim_issues_live() -> void:
	if claim_live > 0:
		claim_live -= 1
	else:
		claim_blank -= 1
	
	if player_live > 0:
		player_live -= 1
	else:
		player_blank -= 1
	
	if bot1.live > 0:
		bot1.live -= 1
	else:
		bot1.blank -= 1
	
	if bot2.live > 0:
		bot2.live -= 1
	else:
		bot2.blank -= 1
	
func shoot_bot1() -> void:
	tween9 = reset_tween(tween9)
	tween9.set_parallel(true)
	tween9.tween_property(gun, "position", Vector2(377, 240), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween9.tween_property(gun, "scale", Vector2(0.8, 0.8), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween9.tween_property(gun, "rotation", deg_to_rad(285), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween9.finished
	timer.start(0.3)
	var index := randi_range(1, 5)
	if barrel[index] == 2:
		shoot_sfx.play()
		bot1.aggression = randi_range(-1, 2)
		bot1.deceptiveness = randf_range(0.0, 1.0)
		bot1.live = claim_live
		bot1.blank = claim_blank
		if rand_skin_bot1 == 0:
			bot1_body.play("mid_disappear")
		elif rand_skin_bot1 == 1:
			bot1_body.play("thin_disappear")
		elif rand_skin_bot1 == 2:
			bot1_body.play("thick_disappear")
		await bot1_body.animation_finished
		rand_skin_bot1 = randi_range(0, 2)
		if rand_skin_bot1 == 0:
			bot1_body.play("mid_appear")
		elif rand_skin_bot1 == 1:
			bot1_body.play("thin_appear")
		elif rand_skin_bot1 == 2:
			bot1_body.play("thick_appear")
		await bot1_body.animation_finished
		mult += 0.75
		live -= 1
		barrel[index] = 0
		claim_barrel[index] = 0
		player_barrel[index] = 0
		bot1_barrel[index] = 0
		bot2_barrel[index] = 0
		_pass()
		return
	else:
		if barrel[index] == 1:
			blank -= 1
			blank = clamp(blank, 0, abs(blank))
			barrel[index] = 0
			claim_barrel[index] = 0
			player_barrel[index] = 0
			bot1_barrel[index] = 0
			bot2_barrel[index] = 0
			blank_sfx.play()
		else:
			empty_sfx.play()
		loading_bot1()

func shoot_sky_bot1() -> void:
	tween9 = reset_tween(tween9)
	tween9.set_parallel(true)
	tween9.tween_property(gun, "position", Vector2(390, 213), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween9.tween_property(gun, "scale", Vector2(0.8, 0.8), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween9.tween_property(gun, "rotation", deg_to_rad(41.5), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween9.finished
	timer.start(0.3)
	await timer.timeout
	var index := randi_range(1, 5)
	if barrel[index] == 2:
		if randi_range(0, 2) == 0:
			bot1.aggression -= 1
		shoot_sfx.play()
		shatter_sfx.play()
		fade_in.color.a = 1
		timer.start(BLACKOUT_TIME)
		await timer.timeout
		fade_in.visible = 1
		timer.start(BLACKOUT_TIME)
		await timer.timeout
		tween8 = reset_tween(tween8)
		tween8.tween_property(fade_in, "color:a", 0, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		await tween8.finished
		fade_in.visible = 0
		live -= 1
		barrel[index] = 0
		claim_barrel[index] = 0
		player_barrel[index] = 0
		bot1_barrel[index] = 0
		bot2_barrel[index] = 0
		_pass()
	else:
		if randi_range(0,2) == 0:
			bot1.aggression += 1
		if barrel[index] == 1:
			blank -= 1
			blank = clamp(blank, 0, abs(blank))
			barrel[index] = 0
			claim_barrel[index] = 0
			player_barrel[index] = 0
			bot1_barrel[index] = 0
			bot2_barrel[index] = 0
			blank_sfx.play()
		else:
			empty_sfx.play()
		_pass()

func shoot_bot2() -> void:
	tween9 = reset_tween(tween9)
	tween9.set_parallel(true)
	tween9.tween_property(gun, "position", Vector2(718, 257), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween9.tween_property(gun, "scale", Vector2(0.8, 0.8), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween9.tween_property(gun, "rotation", deg_to_rad(448), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween9.finished
	timer.start(0.3)
	await timer.timeout
	var index := randi_range(1, 5)
	if barrel[index] == 2:
		shoot_sfx.play()
		live -= 1
		barrel[index] = 0
		claim_barrel[index] = 0
		player_barrel[index] = 0
		bot1_barrel[index] = 0
		bot2_barrel[index] = 0
		bot2.aggression = randi_range(-1, 2)
		bot2.deceptiveness = randf_range(0.0, 1.0)
		bot2.live = claim_live
		bot2.blank = claim_blank
		if rand_skin_bot2 == 0:
			bot2_body.play("mid_disappear")
		elif rand_skin_bot2 == 1:
			bot2_body.play("thin_disappear")
		elif rand_skin_bot2 == 2:
			bot2_body.play("thick_disappear")
		await bot2_body.animation_finished
		rand_skin_bot2 = randi_range(0, 2)
		if rand_skin_bot2 == 0:
			bot2_body.play("mid_appear")
		elif rand_skin_bot2 == 1:
			bot2_body.play("thin_appear")
		elif rand_skin_bot2 == 2:
			bot2_body.play("thick_appear")
		await bot2_body.animation_finished
		mult += 0.75
		_pass()
	else:
		if barrel[index] == 1:
			blank -= 1
			blank = clamp(blank, 0, abs(blank))
			barrel[index] = 0
			claim_barrel[index] = 0
			player_barrel[index] = 0
			bot1_barrel[index] = 0
			bot2_barrel[index] = 0
			blank_sfx.play()
		else:
			empty_sfx.play()
		loading_bot2()

func shoot_sky_bot2() -> void:
	tween9 = reset_tween(tween9)
	tween9.set_parallel(true)
	tween9.tween_property(gun, "position", Vector2(676, 192), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween9.tween_property(gun, "scale", Vector2(0.8, 0.8), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween9.tween_property(gun, "rotation", deg_to_rad(329), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween9.finished
	timer.start(0.3)
	await timer.timeout
	var index := randi_range(1, 5)
	if barrel[index] == 2:
		if randi_range(0, 2) == 0:
			bot2.aggression -= 1
		shoot_sfx.play()
		shatter_sfx.play()
		fade_in.color.a = 1
		timer.start(BLACKOUT_TIME)
		await timer.timeout
		fade_in.visible = 1
		timer.start(BLACKOUT_TIME)
		await timer.timeout
		tween8 = reset_tween(tween8)
		tween8.tween_property(fade_in, "color:a", 0, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		await tween8.finished
		fade_in.visible = 0
		live -= 1
		barrel[index] = 0
		claim_barrel[index] = 0
		player_barrel[index] = 0
		bot1_barrel[index] = 0
		bot2_barrel[index] = 0

		_pass()
	else:
		if randi_range(0,2) == 0:
			bot2.aggression += 1
		if barrel[index] == 1:
			blank -= 1
			blank = clamp(blank, 0, abs(blank))
			barrel[index] = 0
			claim_barrel[index] = 0
			player_barrel[index] = 0
			bot1_barrel[index] = 0
			bot2_barrel[index] = 0
			blank_sfx.play()
		else:
			empty_sfx.play()
		_pass()

func barrel_update(shot : bool, lie_bot1 : bool, lie_bot2 : bool) -> void:
	if shot:
		var i := 0
		while 1==1:
			if i >= 6:
				break
			if barrel[i] == 0:
				barrel[i] = 2
				break
			i += 1
		i = 0
		while 1==1:
			if i >= 6:
				break
			if claim_barrel[i] == 0:
				if lie_bot1 or lie_bot2:
					claim_barrel[i] = 1
					player_barrel[i] = 1
				else:
					claim_barrel[i] = 2
					player_barrel[i] = 2
				break
			i += 1
		i = 0
		while 1==1:
			if i >= 6:
				break
			if bot1_barrel[i] == 0:
				if lie_bot2:
					bot1_barrel[i] = 1
				else:
					bot1_barrel[i] = 2
				break
			i += 1
		i = 0
		while 1==1:
			if i >= 6:
				break
			if bot2_barrel[i] == 0:
				if lie_bot1:
					bot2_barrel[i] = 1
				else:
					bot2_barrel[i] = 2
				break
			i += 1
	elif not shot:
		var i := 0
		while 1==1:
			if i >= 6:
				break
			if barrel[i] == 0:
				barrel[i] = 1
				break
			i += 1
		i = 0
		while 1==1:
			if i >= 6:
				break
			if claim_barrel[i] == 0:
				if lie_bot1 or lie_bot2:
					claim_barrel[i] = 2
					player_barrel[i] = 2
				else:
					claim_barrel[i] = 1
					player_barrel[i] = 1
				break
			i += 1
		i = 0
		while 1==1:
			if i >= 6:
				break
			if bot1_barrel[i] == 0:
				if lie_bot2:
					bot1_barrel[i] = 2
				else:
					bot1_barrel[i] = 1
				break
			i += 1
		i = 0
		while 1==1:
			if i >= 6:
				break
			if bot2_barrel[i] == 0:
				if lie_bot1:
					bot2_barrel[i] = 2
				else:
					bot2_barrel[i] = 1
				break
			i += 1

func reset_tween(tween) -> Tween:
	if tween:
		tween.kill()
	tween = create_tween()
	return tween

##SHOOT SELF BUTTON ANIMATIONS
func _on_button_mouse_entered() -> void:
	tween1 = reset_tween(tween1)
	tween1.set_parallel(true)
	tween1.tween_property(shoot_self, "offset_transform_scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween1.tween_property(shoot_self, "offset_transform_rotation", -0.05, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
func _on_button_mouse_exited() -> void:
	tween2 = reset_tween(tween2)
	tween2.set_parallel(true)
	tween2.tween_property(shoot_self, "offset_transform_scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween2.tween_property(shoot_self, "offset_transform_rotation", 0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

##PASS BUTTON ANIMS
func _on_button_2_mouse_entered() -> void:
	tween3 = reset_tween(tween3)
	tween3.set_parallel(true)
	tween3.tween_property(pass_gun, "offset_transform_scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween3.tween_property(pass_gun, "offset_transform_rotation", 0.05, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_button_2_mouse_exited() -> void:
	tween4 = reset_tween(tween4)
	tween4.set_parallel(true)
	tween4.tween_property(pass_gun, "offset_transform_scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween4.tween_property(pass_gun, "offset_transform_rotation", 0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

##SHOOT SKY BUTTON ANIMS
func _on_button_3_mouse_entered() -> void:
	tween5 = reset_tween(tween5)
	tween5.set_parallel(true)
	tween5.tween_property(shoot_sky, "offset_transform_scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween5.tween_property(shoot_sky, "offset_transform_rotation", 0.05, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_button_3_mouse_exited() -> void:
	tween6 = reset_tween(tween6)
	tween6.set_parallel(true)
	tween6.tween_property(shoot_sky, "offset_transform_scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween6.tween_property(shoot_sky, "offset_transform_rotation", 0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

##SAVING FUNCS
func get_save_file_path() -> String:
	return SAVE_FOLDER + str("settings.res")

func save_data() -> void:
	var new_save = SaveData.new()
	for saver : SaverNode in get_tree().get_nodes_in_group(SaverNode.SAVER_NODE_GROUP):
		var node_path = get_path_to(saver)
		new_save.data[node_path] = saver.get_save_dict()
	ResourceSaver.save(new_save, get_save_file_path())

func load_data() -> void:
	if not FileAccess.file_exists(get_save_file_path()):
		print("WARN: a save-file does not exist, creating a new one...")
		high_points = 0
		mstr_vol_var = 1.0
		music_vol_var = 1.0
		sfx_vol_var = 1.0
		save_data()
		return
	var loaded_save = ResourceLoader.load(get_save_file_path()) as SaveData
	for path in loaded_save.data:
		var saver_node = get_node_or_null(path)
		if saver_node:
			saver_node.apply_save_dict(loaded_save.data[path])

##BUTTON ACTIONS
func _on_continue_button_up() -> void:
	pause = false
	shoot_self.disabled = 0
	shoot_sky.disabled = 0
	pass_gun.disabled = 0
	fade_in.color.a = 0.8
	tween11 = reset_tween(tween11)
	tween11.set_parallel(true)
	tween11.tween_property(fade_in, "color:a", 0., 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween11.tween_property(radio_big, "position", Vector2(105, -450), 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	await tween11.finished
	fade_in.visible = 0

func _on_return_to_menu_button_up() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_restart_button_up() -> void:
	get_tree().reload_current_scene()
