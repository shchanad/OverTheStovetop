extends Node2D

@onready var score_manager: ScoreManager = get_node("ScoreManager")
@onready var result_ui = $ResultUI
@onready var score_label = $ResultUI/ScoreLabel
@onready var next_button = $ResultUI/NextButton
@onready var knobs: Array[Knob] = [get_node('1/knob'), get_node('2/knob'), get_node('3/knob'), get_node('4/knob')]
@onready var bars: Array[ProgressBar] = [get_node('1/ProgressBar'), get_node('2/ProgressBar'), get_node('3/ProgressBar'), get_node('4/ProgressBar')]

@onready var result_image_rect = $ResultUI/ResultImage
# Drag your different images into these arrays in the inspector!
@export_group("Result Images")
@export var nice_images: Array[Texture2D]
@export var almost_images: Array[Texture2D]
@export var like_images: Array[Texture2D]
@export var meh_images: Array[Texture2D]
@export var bad_images: Array[Texture2D]


@onready var pause_menu = $PauseMenu
@onready var resume_button: Button = $PauseMenu/BackgroundDimmer/CenterContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $PauseMenu/BackgroundDimmer/CenterContainer/VBoxContainer/RestartButton
var paused: bool = false

var selected_knob: int = -1

# Drop your Level resource into this slot in the Inspector!
@export var level_list: Array[PuzzleLevel] = []
var current_level_index: int = 0
var current_level: PuzzleLevel

# NEW: Toggle this in the inspector to switch between Clamp (true) and Modulo (false)
@export var use_clamp_mode: bool = false

# This array holds the live numbers the player is trying to get to 0
var current_variables: Array[int] = [0, 0, 0, 0]
# Used for score change calculation
var bar_overflow_time: Array[float] = [0.0, 0.0, 0.0, 0.0]


# Get a reference to your audio node
@onready var background_sound: AudioStreamPlayer2D = $BackgroundSound

func _ready() -> void:
	next_button.pressed.connect(_on_next_button_pressed)

	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	
	if level_list.size() > 0:
		load_level(0) # Загружаем самый первый уровень из списка
		
	# Load the starting variables from the resource
	if current_level:
		current_variables[0] = current_level.starting_variables.x
		current_variables[1] = current_level.starting_variables.y
		current_variables[2] = current_level.starting_variables.z
		current_variables[3] = current_level.starting_variables.w
	
	# Connect all signals to the SAME function, but pass the knob index
	for i in range(knobs.size()):
		# We bind the index 'i' so the function knows WHICH knob sent the signal
		knobs[i].state_changed.connect(_on_any_knob_turned.bind(i))
		knobs[i].set_block_signals(true)
		knobs[i].set_state(current_variables[i], true)
		knobs[i].set_block_signals(false)
	
	for i in range(bars.size()):
		bars[i].overflow_detected.connect(_on_any_bar_overflow.bind(i))

func _process(_delta: float) -> void:
	if result_ui.visible:
		return
	
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_pause()
	# ... (Your exact Input logic for KEY_1 to KEY_4 remains here unchanged!) ...
	if Input.is_key_pressed(KEY_1):
		_select_knob(0)
	elif Input.is_key_pressed(KEY_2):
		_select_knob(1)
	elif Input.is_key_pressed(KEY_3):
		_select_knob(2)
	elif Input.is_key_pressed(KEY_4):
		_select_knob(3)

	if selected_knob >= 0 and selected_knob <= 3:
		if Input.is_action_just_pressed("ui_right"):
			score_manager.register_move()
			knobs[selected_knob].step_forward(use_clamp_mode)
		elif Input.is_action_just_pressed("ui_left"):
			score_manager.register_move()
			knobs[selected_knob].step_backward(use_clamp_mode)

func load_level(index: int) -> void:
	if index >= level_list.size():
		print("Finish!")
		return
	
	current_level_index = index
	current_level = level_list[index]
	score_manager.reset_score(current_level.minimum_steps)
	
	current_variables[0] = current_level.starting_variables.x
	current_variables[1] = current_level.starting_variables.y
	current_variables[2] = current_level.starting_variables.z
	current_variables[3] = current_level.starting_variables.w
	
	for i in range(knobs.size()):
		knobs[i].set_block_signals(true)
		knobs[i].set_state(current_variables[i], true)
		knobs[i].set_block_signals(false)

	for i in range(4):
		bars[i].reset()
		
	print("Level loaded: ", index + 1)
	_update_background_audio()

# Helper function to clean up your _process selection code
func _select_knob(index: int) -> void:
	if selected_knob != -1 and selected_knob != index:
		knobs[selected_knob].disable_highlight()
	selected_knob = index
	knobs[index].enable_highlight()

func _on_any_bar_overflow(delta: float, bar_index: int) -> void:
	bar_overflow_time[bar_index] += delta
	score_manager.recalculate_score(delta, bar_overflow_time[bar_index])

# The core puzzle logic
func _on_any_knob_turned(new_state: int, delta: int, knob_index: int) -> void:
	if not current_level:
		return
		
	var rule = current_level.knob_rules[knob_index]
	
	# 1. Apply the math to your internal data
	# (Converting the Vector4i to an Array makes the loop much cleaner)
	var rule_array: Array[int] = [rule.x, rule.y, rule.z, rule.w]
	
	for i in range(4):
		var change = delta * rule_array[i]
		
		if use_clamp_mode:
			# Hard limits: gets stuck at 0 or 5
			current_variables[i] = clampi(current_variables[i] + change, 0, 5)
		else:
			# Wrap-around: loops seamlessly between 0 and 5
			current_variables[i] += change
			# The +6 ensures negative numbers wrap backwards correctly in Godot
			current_variables[i] = (current_variables[i] % 6 + 6) % 6 
		
	# 2. Update the visual knobs WITHOUT triggering infinite loops
	for i in range(4):
		# Turn off signals for this knob temporarily
		knobs[i].set_block_signals(true)
		
		# Visually update the knob to match the new variable state.
		# (Passing 'true' here ensures it still animates smoothly)
		knobs[i].set_state(current_variables[i], true)
		
		# Turn signals back on so the player can interact with it later
		knobs[i].set_block_signals(false)

	_update_background_audio()
	print("Current Puzzle State: ", current_variables)
	_check_win_condition()

func show_level_complete(final_score: int) -> void:
	result_ui.visible = true
	var dimmer = $ResultUI/Dimmer
	dimmer.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(dimmer, "modulate:a", 1.0, 0.5)

	
	var moves_number_str__ = "Moves number: " + str(score_manager.moves_number) + "\n"
	var level_score_str__ = "Level score: " + str(final_score) + "\n"
	var total_score_str__ = "Total score: " + str(score_manager.total_score) + "\n"
	score_label.text = "Survived!\n" + moves_number_str__ + level_score_str__ + total_score_str__
	if current_level_index >= level_list.size() - 1:
		next_button.text = "Finish Game"
	else:
		next_button.text = "Next Level"

	var selected_texture: Texture2D = null
	# 1. Check the score ranges and pick a random image from the correct array
	# (Adjust these numbers to match your actual scoring system thresholds!)
	if final_score >= 900:
		selected_texture = _get_random_image(nice_images)
	elif final_score >= 700:
		selected_texture = _get_random_image(almost_images)
	elif final_score >= 500:
		selected_texture = _get_random_image(like_images)
	elif final_score >= 300:
		selected_texture = _get_random_image(meh_images)
	else:
		selected_texture = _get_random_image(bad_images)
		
	# 2. Assign the chosen image to the TextureRect
	if selected_texture != null:
		result_image_rect.texture = selected_texture
		
	# 3. Finally, show the UI
	result_ui.visible = true

# Helper function to prevent crashes if an array is accidentally left empty
func _get_random_image(image_array: Array[Texture2D]) -> Texture2D:
	if image_array.is_empty():
		push_warning("Tried to load a random image, but the array is empty!")
		return null
		
	# pick_random() is a built-in Godot 4 feature that grabs one random item
	return image_array.pick_random()

func _check_win_condition() -> void:
	# If any variable is not 0, we haven't won yet
	for val in current_variables:
		if val != 0:
			return 
	
	print("Level Complete! All variables are 0!")
	var final_score = score_manager.calculate_final_score()
	score_manager.commit_final_score(final_score)

	selected_knob = -1
	# disables bars
	for bar in bars:
		bar.active = false
	# reset bars overflow timers
	for i in range(4):
		bar_overflow_time[i] = 0.0
	# show menu
	show_level_complete(final_score)
	
func _on_next_button_pressed() -> void:
	result_ui.visible = false
	for bar in bars:
		bar.reset()
	
	if current_level_index < level_list.size() - 1:
		current_level_index += 1
		load_level(current_level_index)
	else:
		get_tree().change_scene_to_file("res://scenes/finish_scena.tscn")

# PAUSE
func _toggle_pause() -> void:
	var new_pause_state: bool = not paused
	paused = new_pause_state
	pause_menu.visible = new_pause_state
	for bar in bars:
		bar.active = not new_pause_state

func _on_resume_pressed() -> void:
	_toggle_pause()

func _on_restart_pressed() -> void:
	_toggle_pause()
	load_level(current_level_index)

# Audio
func _update_background_audio() -> void:
	# 1. Find the highest number currently in the array (0 to 5)
	# Godot 4 has a built-in .max() function for arrays!
	var highest_value: int = current_variables.max()
	
	# 2. Convert that to a percentage from 0.0 to 1.0
	# (We divide by 5.0 as a float, so it doesn't do integer rounding)
	var volume_percent: float = highest_value / 5.0
	
	# 3. Convert the percentage to Decibels and apply it
	background_sound.volume_db = linear_to_db(volume_percent)
