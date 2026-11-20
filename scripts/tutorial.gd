class_name Tutorial extends Control

@onready var shoot_self: Button = $Button
@onready var pass_gun: Button = $Button2
@onready var shoot_sky: Button = $Button3
@onready var point_label: Label = $MarginContainer/VBoxContainer/Label
@onready var texture_rect_live: TextureRect = $MarginContainer3/HBoxContainer/TextureRect
@onready var texture_rect_blank: TextureRect = $MarginContainer3/HBoxContainer/TextureRect2
@onready var label_live: Label = $MarginContainer3/HBoxContainer/TextureRect/Label
@onready var label_blank: Label = $MarginContainer3/HBoxContainer/TextureRect2/Label
@onready var barrel: TextureRect = $TextureRect3
@onready var label: Label = $Label
@onready var label_2: Label = $Label2
@onready var label_3: Label = $Label3
@onready var label_4: Label = $Label4
@onready var label_5: Label = $Label5
@onready var label_6: Label = $Label6
@onready var label_7: Label = $Label7
@onready var label_8: Label = $Label8
@onready var label_9: Label = $Label9
@onready var label_10: Label = $Label10
@onready var mult_display: Label = $MarginContainer/VBoxContainer/Label2
@onready var blank_sfx: AudioStreamPlayer = $AudioStreamPlayer
@onready var load_sfx: AudioStreamPlayer = $AudioStreamPlayer2
@onready var shoot_sfx: AudioStreamPlayer = $AudioStreamPlayer3
@onready var pass_sfx: AudioStreamPlayer = $AudioStreamPlayer4
@onready var shatter_sfx: AudioStreamPlayer = $AudioStreamPlayer6
@onready var door_sfx: AudioStreamPlayer = $AudioStreamPlayer7
@onready var timer: Timer = $Timer
@onready var blackout: ColorRect = $ColorRect
@onready var bot1_body: AnimatedSprite2D = $bot1/AnimatedSprite2D
@onready var bot2_body: AnimatedSprite2D = $bot2/AnimatedSprite2D
@onready var fade_in: ColorRect = $fade_in
@onready var tutorial_label_load: Label = $Tutorial_label_load
@onready var tutorial_label: Label = $Tutorial_label

@export var live: int = 0
@export var blank: int = 0
@export var claim_live: int = 0
@export var claim_blank: int = 0

var tutorial_turn: int = 0

var agression_bot1: int = 0
var agression_bot2: int = 0
var deceptiveness_bot1: float = 0.5
var deceptiveness_bot2: float = 0.5
var bot1_live: int = 0
var bot1_blank: int = 0
var player_live: int = 0
var player_blank: int = 0
var bot2_live: int = 0
var bot2_blank: int = 0
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
var passed_bot1 : int = 0
var passed_bot2 : int = 0
var first_load: int = 0
var missing_shots : int
var rand_skin_bot1 : int
var rand_skin_bot2 : int
var tween1 : Tween
var tween2 : Tween
var tween3 : Tween
var tween4 : Tween
var tween5 : Tween
var tween6 : Tween
var tween7 : Tween
@export var ammo : Array[TextureRect] = []
@export var player_ammo : Array[TextureRect] = []
@export var claim_ammo : Array[TextureRect] = []

func _ready() -> void: 
	
	tutorial_label.visible = 0
	tutorial_label_load.visible = 0
	fade_in.visible = 1
	fade_in.color.a = 1
	tween7 = reset_tween(tween7)
	tween7.tween_property(fade_in, "color:a", 0, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	
	blackout.visible = 0
	shoot_self.visible = 0
	shoot_sky.visible = 0
	pass_gun.visible = 0
	barrel.visible = 0
	texture_rect_blank.visible = 0
	texture_rect_live.visible = 0
	door_sfx.play()
	bot1_body.visible = 0
	bot2_body.visible = 0
	await tween7.finished
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
	bot2_body.visible = 1
	rand_skin_bot2 = randi_range(0, 2)
	if rand_skin_bot2 == 0:
		bot2_body.play("mid_appear")
	elif rand_skin_bot2 == 1:
		bot2_body.play("thin_appear")
	elif rand_skin_bot2 == 2:
		bot2_body.play("thick_appear")
	first_load = 1
	whose_turn = 2
	print("which hacker is illegal? is .exe evil? am i evil? are we evil? who is evil? trust no one.")
	barrel.visible = 0
	texture_rect_live.visible = 0
	texture_rect_blank.visible = 0
	agression_bot1 = randi_range(-1, 2)
	deceptiveness_bot1 = randf_range(0.0, 1.0)
	agression_bot2 = randi_range(-1, 2)
	deceptiveness_bot2 = randf_range(0.0, 1.0)
	tutorial_label.text = "Hello.
	The goal in this game is to survive and to get as many points as possible.
	On your turn you have three actions to pick from.
	
	Shooting yourself exposes you to the risk of getting shot,
	but it is the only way of getting points.
	If you shoot yourself with a live round, you well...lose.
	Otherwise you get points multiplied by your current multiplier."
	
func _process(_delta: float) -> void:
	mult = clamp(mult, 1, abs(mult)+1)
	mult_display.text = "x" + str(mult)
	if first_load:
		_first_load()
	for i in claim_ammo.size():
		claim_ammo[i].texture = null
	for shot in claim_live:
		claim_ammo[shot].texture = load("res://textures/Live_white.svg")
	for shot in claim_blank:
		claim_ammo[claim_live+shot].texture = load("res://textures/Blank_white.svg")
	for i in player_ammo.size():
		player_ammo[i].texture = null
	for shot in player_live:
		player_ammo[shot].texture = load("res://textures/Live_white.svg")
	for shot in player_blank:
		player_ammo[player_live+shot].texture = load("res://textures/Blank_white.svg")
	label.text = str(live)
	label_2.text = str(blank)
	label_3.text = str(claim_live)
	label_4.text = str(claim_blank)
	label_5.text = str(player_live)
	label_6.text = str(player_blank)
	label_7.text = str(bot2_live)
	label_8.text = str(bot2_blank)
	label_9.text = str(bot1_live)
	label_10.text = str(bot1_blank)
	points = clamp(points, 0, abs(points))
	blank = clamp(blank, 0, 6)
	live = clamp(live, 0, 6 - blank)
	blank = clamp(blank, 0, 6 - live)
	claim_blank = clamp(claim_blank, 0, 6)
	claim_live = clamp(claim_live, 0, 6 - claim_blank)
	claim_blank = clamp(claim_blank, 0, 6 - claim_live)
	bot1_blank = clamp(bot1_blank, 0, 6)
	bot1_live = clamp(bot1_live, 0, 6 - bot1_blank)
	bot1_blank = clamp(bot1_blank, 0, 6 - bot1_live)
	bot2_blank = clamp(bot2_blank, 0, 6)
	bot2_live = clamp(bot2_live, 0, 6 - bot2_blank)
	bot2_blank = clamp(bot2_blank, 0, 6 - bot2_live)
	if points < 10:
		point_label.text = "0" + str(points)
	else:
		point_label.text = str(points)
	if whose_turn != 0:
		shoot_self.visible = 0
		shoot_sky.visible = 0
		pass_gun.visible = 0
			
	if tutorial_turn == 1:
		pass_gun.disabled = 1
		shoot_sky.disabled = 1
	elif tutorial_turn == 2:
		tutorial_label.text = ""
		tutorial_label_load.text = "This game is all about gaslighting.
		If you shoot yourself with a blank, you get to load the gun until the barrel's full.
		Pressing LMB on the barrel loads a live round and pressing RMB loads a blank round. There are two numbers underneath the barrel. You can modify them with the scroll wheel on your mouse. This is the amount of lives and blanks you CLAIM you added. It doesn't have to be true.
		For each round you lied about you get -0.25 multiplier.
		For every round you didn't lie about you get +0.25 multiplier.
		After you finish setting up the barrel and claims, just pass the gun to the next player."
		pass_gun.disabled = 0
		shoot_sky.disabled = 1
		shoot_self.disabled = 1
	if tutorial_turn == 3:
		tutorial_label.text = "If you think a live round is going to come out of the gun, shoot the light.
		Be aware that if you shoot a blank this way,
		you lose points times the multiplier and you lose 0.1 multiplier.
		
		When you start a game, one player will be randomly chosen to load the whole barrel. The first load is always truthful."
		tutorial_turn = 10
		pass_gun.disabled = 1
		shoot_self.disabled = 1
		whose_turn = 0
		shoot_sky.disabled = 0
		shoot_self.visible = 1
		shoot_sky.visible = 1
		pass_gun.visible = 1
	elif tutorial_turn == 4 :
		tutorial_label.text = "You can also pass to completely skip your turn.
		You can't pass two times in a row.
		
		Let's take a peek at your opponents. They have the same goal as you. To survive. You gain 0.75 multiplier if one dies. They immediately get replaced by a new opponent after death.
		They also have different personalities. Try to watch their behaviour as this greatly simplifies the gameplay. Be aware that they can lie in their claims. My suggestion is that you trust no one."
		pass_gun.disabled = 0
		shoot_self.disabled = 1
		shoot_sky.disabled = 1
		whose_turn = 0
		shoot_sky.disabled = 1
		shoot_self.visible = 1
		shoot_sky.visible = 1
		pass_gun.visible = 1
		tutorial_turn = 11
		
	if tutorial_turn == 6:
		tutorial_label.text = "The bars in the left bottom corner are predictions of the barrel.
		The white one is your best guess at the barrel as it is based on what you saw in the barrel when you were reloading and claims of the opponents.
		The gray one is the claimed barrel based on claims of all the players.
		Mind that opponents don't make decisions based on this bar as they have their own reasoning system based on their knowledge of the barrel.
		
		This is the end of the tutorial. If you click the door in the main menu you will enter the actual game."
		tutorial_turn = 8
		pass_gun.disabled = 1
		shoot_self.disabled = 0
		shoot_sky.disabled = 1
		whose_turn = 0
		shoot_self.visible = 1
		shoot_sky.visible = 1
		pass_gun.visible = 1
		
	if reloading == true:
		if Input.is_action_just_pressed("lmb") and live + blank < 6 and live + blank >= 0 and barrel.get_rect().has_point(get_global_mouse_position()):
			live += 1
			player_reload_live += 1
			load_sfx.play()
		elif Input.is_action_just_pressed("rmb") and live + blank < 6 and live + blank >= 0 and barrel.get_rect().has_point(get_global_mouse_position()):
			blank += 1
			player_reload_blank += 1
			load_sfx.play()
		elif (texture_rect_live.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_up")) or (texture_rect_blank.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_down")):
			label_live_value += 1
			label_blank_value -= 1
		elif (texture_rect_live.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_down")) or (texture_rect_blank.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_up")):
			label_live_value -= 1
			label_blank_value += 1
		for shot in ammo:
			shot.visible = 0
		blank = clamp(blank, 0, 6)
		live = clamp(live, 0, 6 - blank)
		blank = clamp(blank, 0, 6 - live)
		for round_shot in live:
			ammo[round_shot].texture = load("res://textures/Live_white.svg")
			ammo[round_shot].visible = 1
		for round_shot in blank:
			ammo[live + round_shot].texture = load("res://textures/Blank_white.svg")
			ammo[live + round_shot].visible = 1
		label_live_value = clamp(label_live_value, 0, missing_shots)
		label_blank_value = clamp(label_blank_value, 0, missing_shots)
		label_live.text = str(label_live_value)
		label_blank.text = str(label_blank_value)
		player_reload_claim_live = label_live_value
		player_reload_claim_blank = label_blank_value
		player_blank = blank
		player_live = live
		if blank + live >= 6:
			pass_gun.visible = 1
func _on_button_3_button_up() -> void:
	shoot_self.visible = 0
	shoot_sky.visible = 0
	pass_gun.visible = 0
	if reloading == false:
		_shoot_sky()

func _on_button_2_button_up() -> void:
	shoot_self.visible = 0
	shoot_sky.visible = 0
	pass_gun.visible = 0
	if reloading == false and passed <= 0:
		pass_sfx.play()
		passed = 2
		_pass()
	else:
		if live + blank >= 6:
			var mult_times := 0
			var mult_minus := 0
			if player_reload_live > player_reload_claim_live:
				mult_times += player_reload_live - abs(player_reload_live - player_reload_claim_live)
				mult_minus += abs(player_reload_live - player_reload_claim_live)
			else:
				mult_times += player_reload_claim_live - abs(player_reload_live - player_reload_claim_live)
				mult_minus += player_reload_claim_live - player_reload_live
			if player_reload_blank > player_reload_claim_blank:
				mult_times += player_reload_blank - abs(player_reload_blank - player_reload_claim_blank)
				mult_minus += abs(player_reload_blank - player_reload_claim_blank)
			else:
				mult_times += player_reload_claim_blank - abs(player_reload_blank - player_reload_claim_blank)
				mult_minus += abs(player_reload_claim_blank - player_reload_blank)
			for i in mult_times:
				mult += 0.25
			for i in mult_minus/2:
				mult -= 0.25
			mult = clamp(mult, 1, abs(mult)+1)
			reloading = 0
			claim_live += label_live_value
			claim_blank += label_blank_value
			bot1_blank += label_blank_value
			bot1_live += label_live_value
			bot2_blank += label_blank_value
			bot2_live += label_live_value
			barrel.visible = 0
			texture_rect_live.visible = 0
			texture_rect_blank.visible = 0
			_pass()

func _on_button_button_up() -> void:
	shoot_self.visible = 0
	shoot_sky.visible = 0
	pass_gun.visible = 0
	if reloading == false:
		_shoot_self()
func _shoot_self() -> void:
	if randi_range(1, 6) <= live:
		tutorial_label.visible = 0
		shoot_sfx.play()
		fade_in.visible = 1
		tween7 = reset_tween(tween7)
		tween7.tween_property(fade_in, "color:a", 1, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		await tween7.finished
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	else:
		blank_sfx.play()
		tutorial_label.visible = 0
		tutorial_label_load.visible = 1
		tutorial_turn = 2
		player_reload_blank = 0
		player_reload_live = 0
		shoot_self.visible = 0
		shoot_sky.visible = 0
		pass_gun.visible = 0
		barrel.visible = 1
		texture_rect_live.visible = 1
		texture_rect_blank.visible = 1
		points += mult
		blank -= 1
		blank = clamp(blank, 0, abs(blank))
		missing_shots = 6 - blank - live
		resolve_claim_issues_blank()
		reloading = 1
		label_blank_value = missing_shots
		label_live_value = 0
	
func _shoot_sky() -> void:
	if randi_range(1, 6) <= live:
		tutorial_turn = 4
		shoot_sfx.play()
		shatter_sfx.play()
		fade_in.visible = 1
		fade_in.color.a = 1
		tween7 = reset_tween(tween7)
		tween7.tween_property(fade_in, "color:a", 0, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		live = 3
		blank = 6 - live
		bot1_blank = blank
		bot1_live = live
		bot2_blank = blank
		bot2_live = live
		claim_blank = blank
		claim_live = live
		player_blank = blank
		player_live = live
		for i in claim_ammo.size():
			claim_ammo[i].texture = null
		for shot in claim_live:
			claim_ammo[shot].texture = load("res://textures/Live_white.svg")
		for shot in claim_blank:
			claim_ammo[claim_live+shot].texture = load("res://textures/Blank_white.svg")
		for i in player_ammo.size():
			player_ammo[i].texture = null
		for shot in player_live:
			player_ammo[shot].texture = load("res://textures/Live_white.svg")
		for shot in player_blank:
			player_ammo[player_live+shot].texture = load("res://textures/Blank_white.svg")
		tween7 = reset_tween(tween7)
		tween7.tween_property(fade_in, "color:a", 0, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		await tween7.finished
		fade_in.visible = 0
		live -= 1
		resolve_claim_issues_live()

	else:
		blank_sfx.play()
		blank -= 1
		resolve_claim_issues_blank()
		mult -= 0.10
		mult = clamp(mult, 1, abs(mult)+1)
		points -= mult

func _pass() -> void:
	whose_turn += 1
	shoot_self.visible = 0
	shoot_sky.visible = 0
	pass_gun.visible = 0
	if tutorial_turn == 2:
		tutorial_label_load.visible = 0
		tutorial_label.visible = 0
		fade_in.visible = 1
		fade_in.color.a = 1
		tween7 = reset_tween(tween7)
		tween7.tween_property(fade_in, "color:a", 0, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		live = 6
		blank = 6 - live
		mult = 1
		points = 0
		bot1_blank = blank
		bot1_live = live
		bot2_blank = blank
		bot2_live = live
		claim_blank = blank
		claim_live = live
		player_blank = blank
		player_live = live
		for i in claim_ammo.size():
			claim_ammo[i].texture = null
		for shot in claim_live:
			claim_ammo[shot].texture = load("res://textures/Live_white.svg")
		for shot in claim_blank:
			claim_ammo[claim_live+shot].texture = load("res://textures/Blank_white.svg")
		for i in player_ammo.size():
			player_ammo[i].texture = null
		for shot in player_live:
			player_ammo[shot].texture = load("res://textures/Live_white.svg")
		for shot in player_blank:
			player_ammo[player_live+shot].texture = load("res://textures/Blank_white.svg")
		tween7 = reset_tween(tween7)
		tutorial_turn = 3
		tween7.tween_property(fade_in, "color:a", 0, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		await tween7.finished
		tutorial_label.visible = 1
		fade_in.visible = 0
	if tutorial_turn == 11:
		tutorial_label.visible = 0
		fade_in.visible = 1
		fade_in.color.a = 1
		tween7 = reset_tween(tween7)
		tween7.tween_property(fade_in, "color:a", 0, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		live = 6
		blank = 6 - live
		bot1_blank = blank
		bot1_live = live
		bot2_blank = blank
		bot2_live = live
		claim_blank = blank
		claim_live = live
		player_blank = blank
		player_live = live
		for i in claim_ammo.size():
			claim_ammo[i].texture = null
		for shot in claim_live:
			claim_ammo[shot].texture = load("res://textures/Live_white.svg")
		for shot in claim_blank:
			claim_ammo[claim_live+shot].texture = load("res://textures/Blank_white.svg")
		for i in player_ammo.size():
			player_ammo[i].texture = null
		for shot in player_live:
			player_ammo[shot].texture = load("res://textures/Live_white.svg")
		for shot in player_blank:
			player_ammo[player_live+shot].texture = load("res://textures/Blank_white.svg")
		tutorial_turn = 6
		tween7 = reset_tween(tween7)
		tween7.tween_property(fade_in, "color:a", 0, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		await tween7.finished
		tutorial_label.visible = 1
		fade_in.visible = 0
	if whose_turn > 2:
		whose_turn = 0
	if whose_turn == 1:
		passed_bot1 -= 1
		timer.start()
		await timer.timeout
	elif whose_turn == 2:
		passed_bot2 -= 1
		timer.start()
		await timer.timeout
	elif whose_turn == 0:
		timer.start()
		await timer.timeout
		passed -= 1
		shoot_self.visible = 1
		shoot_sky.visible = 1
		tutorial_label.visible = 1
		if passed <= 0:
			pass_gun.visible = 1
		else:
			pass_gun.visible = 0

func _first_load():
	tutorial_turn = 1
	shoot_self.visible = 0
	shoot_sky.visible = 0
	pass_gun.visible = 0
	barrel.visible = 0
	texture_rect_live.visible = 0
	texture_rect_blank.visible = 0
	
	
	live = 0
	blank = 6 - live
	first_load = 0
	for i in 6:
		load_sfx.play()
		await load_sfx.finished
	bot1_blank = blank
	bot1_live = live
	bot2_blank = blank
	bot2_live = live
	claim_blank = blank
	claim_live = live
	player_blank = blank
	player_live = live
	_pass()
	return
	
func resolve_claim_issues_blank() -> void:
	if claim_blank > 0:
		claim_blank -= 1
	else:
		claim_live -= 1
	
	if player_blank > 0:
		player_blank -= 1
	else:
		player_live -= 1
	
	if bot1_blank > 0:
		bot1_blank -= 1
	else:
		bot1_live -= 1
	
	if bot2_blank > 0:
		bot2_blank -= 1
	else:
		bot2_live -= 1
func resolve_claim_issues_live() -> void:
	if claim_live > 0:
		claim_live -= 1
	else:
		claim_blank -= 1
	
	if player_live > 0:
		player_live -= 1
	else:
		player_blank -= 1
	
	if bot1_live > 0:
		bot1_live -= 1
	else:
		bot1_blank -= 1
	
	if bot2_live > 0:
		bot2_live -= 1
	else:
		bot2_blank -= 1
		
func reset_tween(tween) -> Tween:
	if tween:
		tween.kill()
	tween = create_tween()
	return tween
##SHOOT SELF BUTTON ANIMATIONS
func _on_button_mouse_entered() -> void:
	if not shoot_self.disabled:
		tween1 = reset_tween(tween1)
		tween1.set_parallel(true)
		tween1.tween_property(shoot_self, "offset_transform_scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween1.tween_property(shoot_self, "offset_transform_rotation", -0.05, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
func _on_button_mouse_exited() -> void:
	if not shoot_self.disabled:
		tween2 = reset_tween(tween2)
		tween2.set_parallel(true)
		tween2.tween_property(shoot_self, "offset_transform_scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween2.tween_property(shoot_self, "offset_transform_rotation", 0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

##PASS BUTTON ANIMS
func _on_button_2_mouse_entered() -> void:
	if not pass_gun.disabled:
		tween3 = reset_tween(tween3)
		tween3.set_parallel(true)
		tween3.tween_property(pass_gun, "offset_transform_scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween3.tween_property(pass_gun, "offset_transform_rotation", 0.05, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_button_2_mouse_exited() -> void:
	if not pass_gun.disabled:
		tween4 = reset_tween(tween4)
		tween4.set_parallel(true)
		tween4.tween_property(pass_gun, "offset_transform_scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween4.tween_property(pass_gun, "offset_transform_rotation", 0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

##SHOOT SKY BUTTON ANIMS
func _on_button_3_mouse_entered() -> void:
	if not shoot_sky.disabled:
		tween5 = reset_tween(tween5)
		tween5.set_parallel(true)
		tween5.tween_property(shoot_sky, "offset_transform_scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween5.tween_property(shoot_sky, "offset_transform_rotation", 0.05, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_button_3_mouse_exited() -> void:
	if not shoot_sky.disabled:
		tween6 = reset_tween(tween6)
		tween6.set_parallel(true)
		tween6.tween_property(shoot_sky, "offset_transform_scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween6.tween_property(shoot_sky, "offset_transform_rotation", 0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
