extends Control

@onready var start_button: TextureButton = $StartButton
@onready var quit_button: TextureButton = $ExitButton

# Drag your main game scene (.tscn) into this slot in the inspector!
@export var main_game_scene: PackedScene

func _ready() -> void:
	# Connect the buttons via code
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Optional: Grab UI focus so players can use keyboard/controller immediately
	start_button.grab_focus()

func _on_start_pressed() -> void:
	if main_game_scene:
		# Load the actual game!
		get_tree().change_scene_to_packed(main_game_scene)
	else:
		push_warning("Main Game Scene is not assigned in the MainMenu inspector!")

func _on_quit_pressed() -> void:
	# Closes the game application
	get_tree().quit()
