extends TextureButton # Если у тебя обычная кнопка, напиши extends Button

# Настройки, которые появятся в Инспекторе
@export var hover_scale: Vector2 = Vector2(1.1, 1.1) # Насколько увеличивать (1.1 = +10%)
@export var transition_time: float = 0.1 # Время анимации в секундах

var default_scale: Vector2

func _ready() -> void:
	default_scale = scale
	pivot_offset = size / 2
	
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)

func _on_hover() -> void:
	var tween = create_tween()
	
	tween.tween_property(self, "scale", hover_scale, transition_time).set_trans(Tween.TRANS_SINE)

func _on_unhover() -> void:
	
	var tween = create_tween()
	
	tween.tween_property(self, "scale", default_scale, transition_time).set_trans(Tween.TRANS_SINE)
