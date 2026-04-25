extends Node
class_name ScoreManager

@export_group("Score Settings")
@export var base_score: float = 1000.0
@export var penalty_start_rate: float = 2.0  # Points lost per second initially
@export var penalty_growth_factor: float = 1.1 # Grows by 10% every second

var current_score: float
var current_penalty_rate: float
var is_timer_running: bool = false

func _ready() -> void:
	reset_score()

func reset_score() -> void:
	current_score = base_score
	current_penalty_rate = penalty_start_rate
	is_timer_running = true

func _process(delta: float) -> void:
	if is_timer_running and current_score > 0:
		# 1. Grow the penalty rate exponentially over time
		# Formula: rate += (rate * growth_percentage) * delta
		current_penalty_rate += (current_penalty_rate * (penalty_growth_factor - 1.0)) * delta
		
		# 2. Subtract the penalty from the score
		current_score -= current_penalty_rate * delta
		
		# 3. Prevent the raw score from dropping below zero
		if current_score < 0:
			current_score = 0

# Call this function when the player successfully solves the puzzle
func calculate_final_score(player_moves: int, optimal_moves: int) -> int:
	# Stop the clock!
	is_timer_running = false 
	
	var multiplier: float = 0.0
	
	# Tier 1: Perfect
	if player_moves <= optimal_moves:
		multiplier = 10.0
		
	# Tier 2: 1x to 2x optimal moves
	elif player_moves <= (2 * optimal_moves):
		# remap(value, in_min, in_max, out_min, out_max)
		multiplier = remap(player_moves, optimal_moves, 2.0 * optimal_moves, 10.0, 1.0)
		
	# Tier 3: 2x to 4x optimal moves
	elif player_moves <= (4 * optimal_moves):
		multiplier = remap(player_moves, 2.0 * optimal_moves, 4.0 * optimal_moves, 1.0, 0.5)
		
	# Tier 4: Too many moves
	else:
		# Hard drop to 1 total point, ignoring base score entirely
		print("Final Score: 1 (Move limit exceeded)")
		return 1 

	# Calculate the final result
	var final_score: int = int(current_score * multiplier)
	
	# Ensure the player never gets less than 1 point if they finish
	if final_score < 1:
		final_score = 1
		
	print("Base Score left: ", int(current_score), " | Multiplier: x", snapped(multiplier, 0.01), " | FINAL: ", final_score)
	return final_score
