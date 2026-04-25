extends Resource
class_name PuzzleLevel

# The starting values of your 4 puzzle variables (0 to 4)
@export var starting_variables: Vector4i = Vector4i(1, 2, 1, 2)

# How much each knob changes the 4 variables when turned forward.
# Index 0 is Knob 1's effect, Index 1 is Knob 2's effect, etc.
# Example: Vector4i(2, -1, 0, 0) means variable A increases by 2, B decreases by 1, C and D don't change.
@export var knob_rules: Array[Vector4i] = [
	Vector4i(1, 0, 0, 0), # Default: Knob 1 only affects Variable 1
	Vector4i(0, 1, 0, 0), 
	Vector4i(0, 0, 1, 0), 
	Vector4i(0, 0, 0, 1)  
]