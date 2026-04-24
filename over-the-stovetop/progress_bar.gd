extends ProgressBar
class_name AutoProgressBar

@export var knob: Knob
@export var state_speeds: Array[float] = [0.0, 5.0, 10.0, 20.0, 50.0]

var current_speed: float = 0.0

# Create a reference to the timer we just added
@onready var tick_timer: Timer = $Timer

func _ready() -> void:
	if not knob:
		return
		
	knob.state_changed.connect(_on_knob_state_changed)
	current_speed = state_speeds[knob.current_state]

# We delete _process(delta) completely!

# This function runs exactly 10 times a second (based on the Timer's 0.1 wait_time)
func _on_timer_timeout() -> void:
	if current_speed > 0.0:
		# We multiply by the timer's wait_time to keep the math consistent
		# with the "per second" speed we defined in the array.
		value += current_speed * tick_timer.wait_time
		
		if value >= max_value:
			value = 0.0

func _on_knob_state_changed(new_state: int) -> void:
	if new_state < state_speeds.size():
		current_speed = state_speeds[new_state]
