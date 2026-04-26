extends Node2D

@onready var score_label = $Score
@onready var title_label = $ResultTitle
@onready var score_manager: ScoreManager = get_node("ScoreManager")

func _ready():
	var total = score_manager.calculate_final_score()
	score_label.text = "TOTAL SCORE: " + str(total)
	
	# Распределение титулов в зависимости от набранных очков
	if total >= 40000: # 4 идеальных уровня или как-то так
		title_label.text = "MOM'S FAVOURITE CHILD"
	elif total >= 20000: # 2 идеальных уровня
		title_label.text = "MOM WILL BE PROUD"
	elif total >= 10000: 
		title_label.text = "MESSED UP A BIT, BUT IT HAPPENS"
	elif total >= 4000:
		title_label.text = "ON THE VERGE OF FAILURE"
	else:
		title_label.text = "MOM'S DISAPPOINTMENT"

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().change_scene_to_file("res://scenes/welcomeScreen.tscn")
