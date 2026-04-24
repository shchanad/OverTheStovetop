extends ProgressBar

# Настройки
var boil_level: float = 0.0          # Текущий уровень
var max_level: float = 100.0         # Максимум (когда выкипает)
var boil_speed: float = 10.0         # Базовая скорость

# Это значение мы получаем от крутилки (от 0.0 до 1.0)
var heat_power: float = 0.55

func _process(delta):
	# Если плита включена (heat_power > 0)
	if heat_power > 0:
		# Прибавляем прогресс: скорость * положение крутилки
		boil_level += heat_power * boil_speed * delta
	else:
		# Если плита выключена, еда потихоньку остывает (опционально)
		boil_level -= 2.0 * delta 
	
	# Ограничиваем, чтобы не вышло за пределы 0-100
	boil_level = clamp(boil_level, 0, max_level)
	
	# Обновляем визуальную полоску
	self.value = boil_level
	
	# Проверка на проигрыш
	if boil_level >= max_level:
		print("БАБАХ! Еда выкипела!")
		# Тут можно вызвать функцию взрыва или сброса уровня
