extends Sprite2D

@export var normal_texture: Texture2D
@export var ringing_texture: Texture2D
@export var shake_amount: float = 3.0

@onready var timer: Timer = $Timer
@onready var audio_player: AudioStreamPlayer2D = $RingSound
@onready var click_area: Area2D = $Area2D

# Новые ссылки на интерфейс диалога
@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var dialogue_label: Label = $DialogueUI/Panel/Label
@onready var closeup_phone: TextureRect = $DialogueUI/BigPhone 

var is_ringing: bool = false
var is_talking: bool = false # Флаг, что сейчас идет разговор
var current_line_index: int = 0 # Индекс текущей фразы

# Массив с нашими фразами
var dialogue_lines: Array[String] = [
	"Алло? Ты меня слышишь?",
	"Слушай внимательно, у нас мало времени.",
	"Возьми ключи на столе и выходи через черный ход.",
	"Конец связи."
]

func _ready() -> void:
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.start()
	
	timer.timeout.connect(_on_timer_timeout)
	click_area.input_event.connect(_on_phone_clicked)
	
	# Убедимся, что диалог скрыт при старте
	dialogue_ui.visible = false

func _process(_delta: float) -> void:
	if is_ringing:
		offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)

func _on_timer_timeout() -> void:
	start_ringing()

func start_ringing() -> void:
	is_ringing = true
	if ringing_texture:
		texture = ringing_texture
	audio_player.play()

func stop_ringing() -> void:
	is_ringing = false
	if normal_texture:
		texture = normal_texture
	offset = Vector2.ZERO
	audio_player.stop()

func _on_phone_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_ringing and not is_talking:
			stop_ringing()
			start_dialogue() # Начинаем разговор после снятия трубки

# --- НОВАЯ ЛОГИКА ДИАЛОГА ---

func start_dialogue() -> void:
	is_talking = true
	current_line_index = 0
	dialogue_ui.visible = true
	show_current_line()

func show_current_line() -> void:
	# Выводим текст из массива по текущему индексу
	dialogue_label.text = dialogue_lines[current_line_index]

func end_dialogue() -> void:
	is_talking = false
	dialogue_ui.visible = false
	print("Разговор завершен!")
	# Опционально: можно снова запустить таймер, чтобы позвонили еще раз
	# timer.start(10.0)

# Эта функция встроена в Godot, она ловит все нажатия (клавиатура/мышь)
func _input(event: InputEvent) -> void:
	# Если мы сейчас разговариваем и игрок кликнул левой кнопкой мыши
	if is_talking and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Увеличиваем индекс на 1 (переходим к следующей фразе)
		current_line_index += 1
		
		# Проверяем, остались ли еще фразы в массиве
		if current_line_index < dialogue_lines.size():
			show_current_line()
		else:
			end_dialogue()
