extends Node
class_name ScoreManager

@export_group("Score Settings")
@export var base_score: float = 1000.0
@export var penalty_start_rate: float = 2.0  # Points lost per second initially
@export var penalty_growth_factor: float = 1.1 # Grows by 10% every second
@onready var score_label = get_node('../ScoreUI/ScoreBoard/Margins/VerticalLayout/Row1/BaseScoreValue')
@onready var moves_label = get_node('../ScoreUI/ScoreBoard/Margins/VerticalLayout/Row2/MovesValue')
@onready var total_score_label = get_node('../ScoreUI/ScoreBoard/Margins/VerticalLayout/Row3/TotalScoreValue')

var total_score: float = 0
var current_score: float
var current_multiplier: float = 10
var current_penalty_rate: float
var is_timer_running: bool = false
var moves_number: int
var optimal_moves: int

func _ready() -> void:
	moves_number = 0
	optimal_moves = 0
	current_score = base_score
	current_penalty_rate = penalty_start_rate
	is_timer_running = true

func reset_score(optimal_moves_: int) -> void:
	moves_number = 0
	moves_label.text = str(moves_number)
	optimal_moves = optimal_moves_
	update_score(base_score)
	current_penalty_rate = penalty_start_rate
	is_timer_running = true

func commit_final_score(score: float):
	total_score += score
	total_score_label.text = str(int(total_score))

func _process(delta: float) -> void:
	pass

func recalculate_score(delta: float, total_time: float):
	update_score(clampf(current_score - (1.0 + (total_time * total_time)) * delta, 0.0, 1000000))

func update_score(value: float):
	current_score = value
	score_label.text = str(int(current_score))

func register_move(value: int = 1): # ALWAYS register 1 move, but maybe in future more than one...
	moves_number += value
	moves_label.text = str(moves_number)

func get_multiplier():
	var multiplier: float = 0.0
	
	# Tier 1: Perfect
	if moves_number <= optimal_moves:
		multiplier = 10.0
		
	# Tier 2: 1x to 2x optimal moves
	elif moves_number <= (2 * optimal_moves):
		# remap(value, in_min, in_max, out_min, out_max)
		multiplier = remap(moves_number, optimal_moves, 2.0 * optimal_moves, 10.0, 1.0)
		
	# Tier 3: 2x to 4x optimal moves
	elif moves_number <= (4 * optimal_moves):
		multiplier = remap(moves_number, 2.0 * optimal_moves, 4.0 * optimal_moves, 1.0, 0.5)
		
	# Tier 4: Too many moves
	else:
		# Hard drop to 1 total point, ignoring base score entirely
		multiplier = 0.001
	
	return multiplier
	

# Call this function when the player successfully solves the puzzle
func calculate_final_score() -> float:
	# Stop the clock!
	is_timer_running = false 
	
	var multiplier = get_multiplier()

	# Calculate the final result
	var final_score: float = clampf(current_score * multiplier, 1.0, 1000000)
	
	print("Base Score left: ", int(current_score), " | Multiplier: x", snapped(multiplier, 0.01), " | FINAL: ", final_score)
	return final_score
