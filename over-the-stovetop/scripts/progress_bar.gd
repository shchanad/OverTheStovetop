extends ProgressBar

var boil_level: float = 0.0          
var max_level: float = 100.0        
# Увеличим базовую скорость для контраста
var boil_speed: float = 40.0 
var heat_power: float = 0.0 

@onready var original_pos = position
signal overflow_detected(delta: float)

var active: bool = true

func _ready():
	# Создаем стиль для фона (рамка и подложка)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.8) # Темно-серый фон
	bg_style.border_width_left = 2
	bg_style.border_width_top = 2
	bg_style.border_width_right = 2
	bg_style.border_width_bottom = 2
	bg_style.border_color = Color(0.8, 0.8, 0.8) # Светлая рамка
	bg_style.set_corner_radius_all(4) # Скругление углов
	
	# Создаем стиль для самой полоски (заполнение)
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color.WHITE # Цвет будем менять в процессе
	fill_style.set_corner_radius_all(2)
	# Добавим небольшое свечение полоске
	fill_style.shadow_color = Color(1, 0.3, 0, 0.5)
	fill_style.shadow_size = 8
	
	# Применяем стили к бару
	add_theme_stylebox_override("background", bg_style)
	add_theme_stylebox_override("fill", fill_style)
	
	# Отключаем стандартный текст процентов, если он мешает
	show_percentage = false


func reset():
	active = true
	boil_level = 0
	set_heat_power(0.0)


func _process(delta):
	# скипаем если неактивно (между уровнями)
	if not active:
		return

	# 1. СКОРОСТЬ КИПЕНИЯ (Квадратичная зависимость)
	# heat_power * heat_power дает огромную разницу между 0.2 и 1.0
	if heat_power > 0:
		boil_level += (heat_power * heat_power) * boil_speed * delta
	else:
		boil_level -= 5.0 * delta # Остывание чуть быстрее
	
	boil_level = clamp(boil_level, 0, max_level)
	
	# 2. ПЛАВНОСТЬ (Скорость падения/роста полоски)
	# Увеличим до 300, чтобы падение было быстрым, но заметным глазу
	self.value = move_toward(self.value, boil_level, 300.0 * delta)
	
	# 3. ВИЗУАЛ
	var r = value / max_level
	self.modulate = Color.GREEN.lerp(Color.RED, r)
	
	# 4. ТРЯСКА
	if value > 80.0:
		var shake = (value - 80.0) * 0.3
		position = original_pos + Vector2(randf_range(-shake, shake), randf_range(-shake, shake))
	else:
		position = original_pos

	if value >= max_level:
		# Можно добавить сброс или паузу, чтобы не спамило
		overflow_detected.emit(delta)
		# print("БАБАХ!")

func set_heat_power(new_value: float) -> void:
	var clamped_new = clampf(new_value/5, 0.0, 1.0)
	
	# Если мы уменьшаем мощность
	if clamped_new < heat_power:
		var drop_factor = heat_power - clamped_new
		
		# Экстремальное падение: 
		# Если крутанули с 1.0 до 0.2, вычтет 0.8 * 120 = 96 единиц!
		boil_level -= drop_factor * 120.0 
		
		# Даем небольшую задержку, чтобы кипение не сразу пошло вверх
		# (По желанию можно даже в минус увести на мгновение)
		boil_level = max(boil_level, 1.0) 
		
	heat_power = clamped_new
