extends Node2D

@onready var my_knob: Knob = $knob

func _ready() -> void:
	# Listen for when the knob changes state
	my_knob.state_changed.connect(_on_knob_state_changed)

func _process(delta: float) -> void:
	# Example: using the keyboard to control the knob steps
	if Input.is_action_just_pressed("ui_right"):
		my_knob.step_forward()
	elif Input.is_action_just_pressed("ui_left"):
		my_knob.step_backward()
		
	# Example: jumping directly to state 3 (135 degrees)
	if Input.is_action_just_pressed("ui_accept"):
		my_knob.set_state(3)

func _on_knob_state_changed(new_state: int) -> void:
	print("The knob is now at state: ", new_state)
