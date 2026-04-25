extends Node2D

@onready var progress_bar = $"../ProgressBar"
@onready var food_sprite = $"mask/food"
@onready var bubbles = get_node("bubbles")
@onready var overflow = $Overflow 

@export var min_y: float = 20.0
@export var max_y: float = -20.0

func _ready():
	# 1. ТЕКСТУРА (Принудительно создаем, чтобы не было пустых частиц)
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	for y in range(16):
		for x in range(16):
			var dist = Vector2(x, y).distance_to(Vector2(8, 8))
			var alpha = clamp(1.0 - (dist / 8.0), 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, alpha))
	overflow.texture = ImageTexture.create_from_image(img)

	# 2. ВИДИМОСТЬ И СЛОИ
	overflow.emitting = false
	overflow.z_index = 20 # Самый верхний слой
	overflow.modulate = Color(1, 1, 1, 1) # Сбрасываем прозрачность в 1
	overflow.show_behind_parent = false
	
	# 3. ФИЗИКА (делаем "фонтан")
	overflow.amount = 40       # Меньше частиц, чтобы не было хаоса
	overflow.lifetime = 1.0    # Успевают упасть до низа кастрюли
	
	# 2. ФИЗИКА СТЕКАНИЯ
	# Направляем их чуть в стороны (spread), но почти не даем скорости вверх
	overflow.direction = Vector2(0, -1)
	overflow.spread = 90.0      # Разлет в стороны, чтобы лилось с обоих боков
	
	# ОЧЕНЬ ВАЖНО: Маленькая скорость, чтобы они не взлетали
	overflow.initial_velocity_min = 10.0 
	overflow.initial_velocity_max = 30.0 
	
	# ОЧЕНЬ ВАЖНО: Сильная гравитация, которая сразу тянет их вниз
	overflow.gravity = Vector2(0, 500) 
	
	# 3. Трение (Damping) - чтобы они не разлетались далеко от кастрюли
	# Это заставит их "прилипать" к вертикальной траектории

	# 4. Размер (делаем их мелкими и каплевидными)
	overflow.scale_amount_min = 0.8
	overflow.scale_amount_max = 2.0
	
	var s_curve = Curve.new()
	s_curve.add_point(Vector2(0, 0.5))
	s_curve.add_point(Vector2(0.2, 1.0))
	s_curve.add_point(Vector2(1, 0.2)) # Сужаются в капельку книзу
	overflow.scale_amount_curve = s_curve
	
	overflow.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINTS
	
	var points = PackedVector2Array()
	var num_points = 50         # Сколько "дырочек", откуда течет пена
	var radius_x = 40.0         # Ширина кастрюли
	var radius_y = 10.0          # "Глубина" эллипса (вид сбоку)
	
	for i in range(num_points):
		var angle = (float(i) / num_points) * TAU
		# Создаем точки по эллипсу
		var pos = Vector2(cos(angle) * radius_x, sin(angle) * radius_y)
		points.append(pos)
	
	overflow.emission_points = points

	# 2. Настройка направления для эллипса
	# Чтобы пена текла "от центра" конфорки наружу:
	overflow.direction = Vector2(0, -1) 
	overflow.spread = 180.0     # Позволяет частицам падать в разные стороны эллипса
	
	# 3. Физика стекания (делаем еще более вязким)
	overflow.initial_velocity_min = 5.0
	overflow.initial_velocity_max = 20.0
	overflow.gravity = Vector2(0, 400)
	 # Чтобы капли не разлетались, а "липли" к стенкам

func _process(_delta):
	# Проверка: если прогресс-бар потерялся, код не упадет
	if not progress_bar: return
	
	var boil_value = progress_bar.value
	var ratio = boil_value / 100.0
	
	# 1. Подъем еды
	if food_sprite:
		food_sprite.position.y = lerp(min_y, max_y, ratio)
	
	# 2. Пузырьки
	if boil_value > 70.0:
		bubbles.emitting = true
		bubbles.amount = int((boil_value - 70.0) * 2)
	else:
		bubbles.emitting = false

	# 3. ЛОГИКА ПЕРЕЛИВА
	# ВНИМАНИЕ: Сделал порог 95, чтобы точно сработало
	if boil_value > 95.0:
		if not overflow.emitting:
			overflow.emitting = true
		
		# Цвет берем от еды, но делаем ярче
		if food_sprite:
			overflow.modulate = food_sprite.modulate.lightened(0.3)
		overflow.modulate.a = 1.0 # Убеждаемся, что не прозрачно
		
		# Тряска
		position.x = randf_range(-1, 1)
	else:
		overflow.emitting = false
		position.x = 0
