extends Control

@onready var credits_rect: TextureRect = $TextureRect2
@onready var radio_rect: TextureRect = $TextureRect3
@onready var radio: TextureButton = $TextureRect3/radio_button
@onready var radio_big: TextureRect = $radio
@onready var credits: TextureButton = $TextureRect2/credits_button
@onready var play: TextureButton = $TextureRect4/play_button
@onready var audio_stream_player_5: AudioStreamPlayer = $AudioStreamPlayer5
@onready var music_vol: TextureRect = $radio/HBoxContainer/music_vol
@onready var mstr_vol: TextureRect = $radio/HBoxContainer/mstr_vol
@onready var sfx_vol: TextureRect = $radio/HBoxContainer/sfx_vol
@onready var credits_big: TextureRect = $credits
@onready var fade_in: ColorRect = $ColorRect
@onready var play_rect: TextureRect = $TextureRect4
@onready var paper_sfx: AudioStreamPlayer = $AudioStreamPlayer



const SAVE_FOLDER : String = "user://"
@export var mstr_vol_var: float
@export var sfx_vol_var: float
@export var music_vol_var: float
var tutorial: bool
var crediting : bool = false
var tween1 : Tween
var tween2 : Tween
var tween3 : Tween
# tween1 = reset_tween(tween1)
# tween1.set_parallel(true)
# tween1.tween_property(play, "offset_transform_scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
# tween1.tween_property(play, "offset_transform_rotation", 0.05, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# tween2 = reset_tween(tween2)
# tween2.set_parallel(true)
# tween2.tween_property(play, "offset_transform_scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
# tween2.tween_property(play, "offset_transform_rotation", 0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _ready() -> void:
	fade_in.visible = 1
	fade_in.color.a = 1
	tween3 = reset_tween(tween3)
	tween3.tween_property(fade_in, "color:a", 0, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	load_data()
	if not mstr_vol_var:
		mstr_vol_var = 1.0
		music_vol_var = 1.0
		sfx_vol_var = 1.0
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), clamp(mstr_vol_var, 0, 1))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), clamp(music_vol_var, 0, 1))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), clamp(sfx_vol_var, 0, 1))
	GlobalVars.mstr_vol = mstr_vol_var
	GlobalVars.music_vol = music_vol_var
	GlobalVars.sfx_vol = sfx_vol_var
	await tween3.finished
	fade_in.visible = 0

func _process(_delta: float) -> void:
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
	if crediting and Input.is_action_just_pressed("lmb"):
		tween1 = reset_tween(tween1)
		tween1.tween_property(credits_big, "position", Vector2(375, 700), 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		await tween1.finished
		crediting = 0
	if not radio_big.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("lmb"):
		tween2 = reset_tween(tween2)
		tween2.tween_property(radio_big, "position", Vector2(105, -350), 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)

	if (mstr_vol.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_up")):
		if Input.is_action_pressed("shift"):
			mstr_vol_var += 0.05
		else:
			mstr_vol_var += 0.01
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), clamp(mstr_vol_var, 0, 1))
		save_data()
	elif (mstr_vol.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_down")):
		if Input.is_action_pressed("shift"):
			mstr_vol_var -= 0.05
		else:
			mstr_vol_var -= 0.01
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), clamp(mstr_vol_var, 0, 1))
		save_data()
	if (sfx_vol.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_up")):
		if Input.is_action_pressed("shift"):
			sfx_vol_var += 0.05
		else:
			sfx_vol_var += 0.01
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), clamp(sfx_vol_var, 0, 1))
		save_data()
	elif (sfx_vol.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_down")):
		if Input.is_action_pressed("shift"):
			sfx_vol_var -= 0.05
		else:
			sfx_vol_var -= 0.01
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), clamp(sfx_vol_var, 0, 1))
		save_data()
	if (music_vol.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_up")):
		if Input.is_action_pressed("shift"):
			music_vol_var += 0.05
		else:
			music_vol_var += 0.01
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), clamp(music_vol_var, 0, 1))
		save_data()
	elif (music_vol.get_global_rect().has_point(get_global_mouse_position()) and Input.is_action_just_pressed("scroll_down")):
		if Input.is_action_pressed("shift"):
			music_vol_var -= 0.05
		else:
			music_vol_var -= 0.01
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), clamp(music_vol_var, 0, 1))
		save_data()

func reset_tween(tween) -> Tween:
	if tween:
		tween.kill()
	tween = create_tween()
	return tween
	

##SAVING FUNCTIONS
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
		mstr_vol_var = 1.0
		music_vol_var = 1.0
		sfx_vol_var = 1.0
		tutorial = 1
		save_data()
		return
	var loaded_save = ResourceLoader.load(get_save_file_path()) as SaveData
	for path in loaded_save.data:
		var saver_node = get_node_or_null(path)
		if saver_node:
			saver_node.apply_save_dict(loaded_save.data[path])


func _on_credits_button_button_up() -> void:
	if not crediting:
		paper_sfx.play()
		crediting = 1
		print("wow")
		tween1 = reset_tween(tween1)
		tween1.tween_property(credits_big, "position", Vector2(375, 80), 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)

func _on_radio_button_button_up() -> void:
	tween2 = reset_tween(tween2)
	tween2.tween_property(radio_big, "position", Vector2(105, 162), 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	# tween2 = reset_tween(tween2)
	# tween2.set_parallel(true)
	# tween2.tween_property(play, "offset_transform_scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# tween2.tween_property(play, "offset_transform_rotation", 0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_credits_button_mouse_entered() -> void:
	credits_rect.texture = load("res://textures/credits-highlight-png.png")

func _on_credits_button_mouse_exited() -> void:
	credits_rect.texture = load("res://textures/credits.png")


func _on_radio_button_mouse_entered() -> void:
	radio_rect.texture = load("res://textures/radio-highlight.png")

func _on_radio_button_mouse_exited() -> void:
	radio_rect.texture = load("res://textures/radio.png")


func _on_play_button_button_up() -> void:
	if tutorial == true:
		tutorial = false
		fade_in.visible = 1
		fade_in.color.a = 0
		tween3 = reset_tween(tween3)
		tween3.tween_property(fade_in, "color:a", 1, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		await tween3.finished
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
	else:
		fade_in.visible = 1
		fade_in.color.a = 0
		tween3 = reset_tween(tween3)
		tween3.tween_property(fade_in, "color:a", 1, 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		await tween3.finished
		get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_play_button_mouse_entered() -> void:
	play_rect.texture = load("res://textures/door-open.png")

func _on_play_button_mouse_exited() -> void:
	play_rect.texture = load("res://textures/door.png")


func _on_button_button_up() -> void:
	tutorial = 0
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
