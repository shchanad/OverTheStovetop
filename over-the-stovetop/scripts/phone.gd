extends Sprite2D

@export var normal_texture: Texture2D
@export var ringing_texture: Texture2D
@export var shake_amount: float = 3.0

@onready var timer: Timer = $Timer
@onready var audio_player: AudioStreamPlayer2D = $RingSound
@onready var click_area: Area2D = $Area2D

@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var dialogue_label: Label = $DialogueUI/Panel/Label
@onready var closeup_phone: TextureRect = $DialogueUI/BigPhone 

@onready var forgot_label: Panel = $DialogueUI/Thoughts
@onready var rules_panel: Control = $DialogueUI/RulePanel

var is_ringing: bool = false
var is_talking: bool = false
var current_line_index: int = 0

var intro_step: int = 0

var dialogue_lines: Array[String] = [
	"Hello, sleepyhead! Are you up yet?",
	"Just calling to make sure — did you turn off the stove when you got up?",
	"I left your lunch warming up there and rushed straight to work.",
	"Good boy! I was starting to get worried.",
	"I'll be home soon, my shift is ending.",
	"Go get washed up then, when I get back we'll have dinner. Bye!"	
]

func _ready() -> void:
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.start()
	
	timer.timeout.connect(_on_timer_timeout)
	click_area.input_event.connect(_on_phone_clicked)
	
	dialogue_ui.visible = false
	forgot_label.visible = false
	rules_panel.visible = false

func _process(_delta: float) -> void:
	if is_ringing:
		offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)

func _on_timer_timeout() -> void:
	start_ringing()

func start_ringing() -> void:
	is_ringing = true
	if ringing_texture:
		texture = ringing_texture
	audio_player.play()

func stop_ringing() -> void:
	is_ringing = false
	if normal_texture:
		texture = normal_texture
	offset = Vector2.ZERO
	audio_player.stop()

func _on_phone_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_ringing and not is_talking:
			stop_ringing()
			start_dialogue()

func start_dialogue() -> void:
	is_talking = true
	current_line_index = 0
	dialogue_ui.visible = true
	closeup_phone.visible = true
	show_current_line()

func show_current_line() -> void:
	dialogue_label.text = dialogue_lines[current_line_index]

func end_dialogue() -> void:
	is_talking = false
	
	closeup_phone.visible = false
	$DialogueUI/Panel.visible = false 
	
	forgot_label.visible = true
	intro_step = 1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_talking:
			current_line_index += 1
			if current_line_index < dialogue_lines.size():
				show_current_line()
			else:
				end_dialogue()
		
		else:
			if intro_step == 1:

				forgot_label.visible = false
				rules_panel.visible = true
				intro_step = 2
			elif intro_step == 2:

				start_game_level()

func start_game_level() -> void:

	get_tree().change_scene_to_file("res://scenes/testing_scene.tscn")
