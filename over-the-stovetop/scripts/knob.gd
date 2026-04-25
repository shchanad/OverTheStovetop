extends Node2D
class_name Knob

@onready var inner_knob: Sprite2D = $inner
@onready var outer_knob: Sprite2D = $outer
@onready var progress_bar = get_node("../ProgressBar")
@onready var fire = get_node("../fireParticles")
var HIGHLIGHTING_VALUE = 6 # how much highlighted

# Emitted whenever the state successfully changes, useful for the parent node
signal state_changed(new_state: int, delta: int)

# ANGLES
const STATES: Array[float] = [0.0, 36.0, 72.0, 108.0, 144.0, 180.0]

# Exposed to the inspector so you can set the starting state
@export_range(0, 5) var current_state: int = 0

@export_group("Animation")
@export var anim_duration: float = 0.3
# Assign a new Curve in the inspector to visually control the animation speed.
@export var custom_curve: Curve 
# Fallback transition if no custom curve is provided
@export var fallback_transition: Tween.TransitionType = Tween.TRANS_SINE 

var _tween: Tween

func _ready() -> void:
	# Snap to the initial state immediately on load without animating
	inner_knob.rotation_degrees = STATES[current_state]


# --- Public Methods (Call these from your parent scene) ---
func set_state(new_state: int, animate: bool = true) -> void:
	new_state = new_state % STATES.size()
	var delta = new_state - current_state
	
	if current_state == new_state and (_tween == null or not _tween.is_running()):
		return # We are already in this state and not moving

	current_state = new_state
	var target_degrees = STATES[current_state]

	if animate:
		_animate_rotation(target_degrees)
	else:
		inner_knob.rotation_degrees = target_degrees

	state_changed.emit(current_state, delta)
	progress_bar.set_heat_power(current_state)
	fire.update_fire(current_state)

func get_state() -> int:
	return current_state

func step_forward() -> void:
	set_state(clampi(current_state + 1, 0, STATES.size() - 1))

func step_backward() -> void:
	set_state(clampi(current_state - 1, 0, STATES.size() - 1))

# Call this to turn the highlight on
func enable_highlight() -> void:
	# Access the shader material and change the thickness to 4.5 pixels
	outer_knob.material.set_shader_parameter("line_thickness", HIGHLIGHTING_VALUE)
	# You can also change the color on the fly!
	# outer_knob.material.set_shader_parameter("line_color", Color.YELLOW)

# Call this to turn the highlight off
func disable_highlight() -> void:
	outer_knob.material.set_shader_parameter("line_thickness", 0.0)

# --- Internal Animation Logic ---		
func _animate_rotation(target_degrees: float) -> void:
	# If the knob is already animating, stop it so we don't get glitchy overlaps
	if _tween and _tween.is_valid():
		_tween.kill()
		
	_tween = create_tween()
	
	if custom_curve != null:
		# If you drew a custom curve in the inspector, we use a custom tween method
		var start_degrees = inner_knob.rotation_degrees
		_tween.tween_method(_apply_custom_curve.bind(start_degrees, target_degrees), 0.0, 1.0, anim_duration)
	else:
		# Otherwise, use Godot's built-in smooth tweening
		_tween.set_trans(fallback_transition)
		_tween.set_ease(Tween.EASE_IN_OUT)
		_tween.tween_property(inner_knob, "rotation_degrees", target_degrees, anim_duration)

# Evaluates the custom curve from 0.0 to 1.0 to lerp between angles
func _apply_custom_curve(t: float, start_val: float, end_val: float) -> void:
	var curve_weight = custom_curve.sample(t)
	inner_knob.rotation_degrees = lerpf(start_val, end_val, curve_weight)
