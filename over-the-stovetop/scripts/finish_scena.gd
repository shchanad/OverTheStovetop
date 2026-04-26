extends Node2D

@onready var score_label = $Score
@onready var title_label = $ResultTitle
@onready var score_manager: ScoreManager = get_node("ScoreManager")

func _ready():

	var total = score_manager.calculate_final_score()
	score_label.text = "TOTAL SCORE: " + str(total)
	
	if total > 10000:
		title_label.text = "CULINARY GENIUS!"
	elif total > 5000:
		title_label.text = "KITCHEN SURVIVOR"
	else:
		title_label.text = "AT LEAST THE HOUSE IS STILL STANDING..."

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
