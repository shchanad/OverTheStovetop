extends Node2D

@onready var knobs: Array[Knob] = [get_node('1/knob'), get_node('2/knob'), get_node('3/knob'), get_node('4/knob')]
var selected_knob: int = -1

func _ready() -> void:
	knobs[0].state_changed.connect(_on_knob1_state_changed)
	knobs[1].state_changed.connect(_on_knob2_state_changed)
	knobs[2].state_changed.connect(_on_knob3_state_changed)
	knobs[3].state_changed.connect(_on_knob4_state_changed)

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_1):
		if selected_knob != -1 and selected_knob != 0:
			knobs[selected_knob].disable_highlight()
		selected_knob = 0
		knobs[0].enable_highlight()
	elif Input.is_key_pressed(KEY_2):
		if selected_knob != -1 and selected_knob != 1:
			knobs[selected_knob].disable_highlight()
		selected_knob = 1
		knobs[1].enable_highlight()
	elif Input.is_key_pressed(KEY_3):
		if selected_knob != -1 and selected_knob != 2:
			knobs[selected_knob].disable_highlight()
		selected_knob = 2
		knobs[2].enable_highlight()
	elif Input.is_key_pressed(KEY_4):
		if selected_knob != -1 and selected_knob != 3:
			knobs[selected_knob].disable_highlight()
		selected_knob = 3
		knobs[3].enable_highlight()

	if selected_knob >= 0 and selected_knob <= 3:
		if Input.is_action_just_pressed("ui_right"):
			knobs[selected_knob].step_forward()
		elif Input.is_action_just_pressed("ui_left"):
			knobs[selected_knob].step_backward()


func _on_knob1_state_changed(new_state: int) -> void:
	print("Knob1 is now at state: ", new_state)

func _on_knob2_state_changed(new_state: int) -> void:
	print("Knob2 is now at state: ", new_state)

func _on_knob3_state_changed(new_state: int) -> void:
	print("Knob3 is now at state: ", new_state)

func _on_knob4_state_changed(new_state: int) -> void:
	print("Knob4 is now at state: ", new_state)
