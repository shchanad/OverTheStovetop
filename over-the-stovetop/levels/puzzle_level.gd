extends Resource
class_name PuzzleLevel

@export var starting_variables: Vector4i = Vector4i(0, 0, 0, 0)

@export var knob_rules: Array[Vector4i] = [
	Vector4i( 1,  0,  0,  0),
	Vector4i( 0,  1,  0,  0), 
	Vector4i( 0,  0,  1,  0), 
	Vector4i( 0,  0,  0,  1)  
]
