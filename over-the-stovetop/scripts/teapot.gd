extends Node2D

@onready var progress_bar = $"../ProgressBar"
@onready var overflow = get_node("Overflow")

func _ready():
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	for y in range(32):
		for x in range(32):
			var dist = Vector2(x, y).distance_to(Vector2(16, 16))
			var alpha = clamp(1.0 - (dist / 16.0), 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, alpha))
	overflow.texture = ImageTexture.create_from_image(img)

	overflow.emitting = false
	overflow.amount = 100
	overflow.lifetime = 2.0
	overflow.z_index = 100
	
	overflow.direction = Vector2(1, -1)
	overflow.spread = 15.0
	
	overflow.gravity = Vector2(0, -150)
	overflow.initial_velocity_min = 100.0
	overflow.initial_velocity_max = 200.0
	
	overflow.scale_amount_min = 1.0
	overflow.scale_amount_max = 4.0
	
	var s_curve = Curve.new()
	s_curve.add_point(Vector2(0, 0.3))
	s_curve.add_point(Vector2(1, 3.0))
	overflow.scale_amount_curve = s_curve

	var grad = Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 0.7))
	grad.set_color(1, Color(1, 1, 1, 0))
	overflow.color_ramp = grad

func _process(_delta):
	if not progress_bar: return
	
	var boil_value = progress_bar.value
	
	if boil_value > 95.0:
		overflow.emitting = true
		
		var intensity = (boil_value - 20.0) / 80.0
		
		overflow.initial_velocity_min = 50.0 + (150.0 * intensity)
		overflow.initial_velocity_max = 100.0 + (250.0 * intensity)
		overflow.modulate.a = 0.3 + (0.7 * intensity)
		
		if boil_value > 90.0:
			position = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	else:
		overflow.emitting = false
		position = Vector2.ZERO
