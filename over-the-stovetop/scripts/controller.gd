extends Node2D

@onready var knobs: Array[Knob] = [get_node('1/knob'), get_node('2/knob'), get_node('3/knob'), get_node('4/knob')]
var selected_knob: int = -1

# Drop your Level resource into this slot in the Inspector!
@export var current_level: PuzzleLevel

# This array holds the live numbers the player is trying to get to 0
var current_variables: Array[int] = [0, 0, 0, 0]

func _ready() -> void:
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

func _process(delta: float) -> void:
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
			knobs[selected_knob].step_forward()
		elif Input.is_action_just_pressed("ui_left"):
			knobs[selected_knob].step_backward()

# Helper function to clean up your _process selection code
func _select_knob(index: int) -> void:
	if selected_knob != -1 and selected_knob != index:
		knobs[selected_knob].disable_highlight()
	selected_knob = index
	knobs[index].enable_highlight()

# The core puzzle logic
func _on_any_knob_turned(new_state: int, delta: int, knob_index: int) -> void:
	if not current_level:
		return
		
	var rule = current_level.knob_rules[knob_index]
	
	# 1. Apply the math to your internal data
	# (Converting the Vector4i to an Array makes the loop much cleaner)
	var rule_array: Array[int] = [rule.x, rule.y, rule.z, rule.w]
	
	for i in range(4):
		current_variables[i] += delta * rule_array[i]
		current_variables[i] = clampi(current_variables[i], 0, 5)
		
	# 2. Update the visual knobs WITHOUT triggering infinite loops
	for i in range(4):
		# Turn off signals for this knob temporarily
		knobs[i].set_block_signals(true)
		
		# Visually update the knob to match the new variable state.
		# (Passing 'true' here ensures it still animates smoothly)
		knobs[i].set_state(current_variables[i], true)
		
		# Turn signals back on so the player can interact with it later
		knobs[i].set_block_signals(false)

	print("Current Puzzle State: ", current_variables)
	_check_win_condition()

func _check_win_condition() -> void:
	# If any variable is not 0, we haven't won yet
	for val in current_variables:
		if val != 0:
			return 
	
	print("Level Complete! All variables are 0!")
