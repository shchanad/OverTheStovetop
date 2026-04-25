extends Resource
class_name PuzzleLevel

@export var starting_variables: Vector4i = Vector4i(1, 1, 1, 1)

@export var knob_rules: Array[Vector4i] = [
	Vector4i( 1, -1,  0,  0),
	Vector4i( 0,  1, -2,  0), 
	Vector4i( 0,  0,  1,  0), 
	Vector4i(-1,  0,  0,  1)  
]