extends CPUParticles2D

var fire_grad: Gradient

func _ready():
	# 1. ТЕКСТУРА (мягкая)
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	for y in range(16):
		for x in range(16):
			var dist = Vector2(x, y).distance_to(Vector2(8, 8))
			var alpha = clamp(1.0 - (dist / 8.0), 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, alpha))
	texture = ImageTexture.create_from_image(img)

	# 2. НАСТРОЙКИ ФОРМЫ (Конфорка эллипсом)
	amount = 100
	lifetime = 0.25
	direction = Vector2(0, -1)
	spread = 8.0
	
	emission_shape = CPUParticles2D.EMISSION_SHAPE_POINTS
	var points = PackedVector2Array()
	var num_holes = 18 
	var radius_x = 44.0
	var radius_y = 4.0
	for i in range(num_holes):
		var angle = (float(i) / num_holes) * TAU
		points.append(Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	emission_points = points

	# 3. ПОДГОТОВКА ГРАДИЕНТА
	fire_grad = Gradient.new()
	color_ramp = fire_grad
	
	# Снова включаем ADD, но сделаем цвета ТЕМНЕЕ, чтобы не было пятна
	material = CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD 
	emitting = false

func update_fire(heat: float):
	heat = heat/5.0
	if heat <= 0.02:
		emitting = false
	else:
		emitting = true
		var h_sq = heat * heat # Плавность роста
		
		# --- ДИНАМИЧЕСКИЙ ГРАДИЕНТ ---
		# Основание всегда синее
		var base_blue = Color(0.1, 0.3, 0.8, 0.8) 
		# На малом газу середина голубая, на большом — оранжевая
		var mid_color = base_blue.lerp(Color(0.8, 0.3, 0.0, 0.7), h_sq)
		# Кончики: на малом газу прозрачно-синие, на большом — красноватые
		var tip_color = Color(0.0, 0.2, 0.5, 0.0).lerp(Color(0.6, 0.1, 0.0, 0.0), h_sq)
		
		fire_grad.set_color(0, base_blue)
		fire_grad.set_color(1, mid_color)
		# Добавим третью точку для плавного затухания кончиков
		if fire_grad.get_point_count() < 3:
			fire_grad.add_point(1.0, tip_color)
		else:
			fire_grad.set_color(2, tip_color)

		# --- ФИЗИКА ПЛАМЕНИ ---
		# Скорость (высота язычков)
		initial_velocity_min = 5.0 + (10.0 * h_sq)
		initial_velocity_max = 15.0 + (35.0 * h_sq)
		
		# Уменьшили вытягивание гравитацией
		gravity = Vector2(0, -100 - (200 * h_sq))
		
		# Немного уменьшим размер, чтобы на маленькой высоте они не кучковались
		scale_amount_min = 0.4 + (h_sq * 0.6)
		scale_amount_max = 0.8 + (h_sq * 1.0)
		
		# Общая яркость
		modulate.a = 0.6 + (heat * 0.4)
