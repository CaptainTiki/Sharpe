extends Control
class_name HUD

static var instance: HUD = null

@onready var level_label: Label = $TopStrip/MarginContainer/HBoxContainer/LevelLabel
@onready var timer_label: Label = $TopStrip/MarginContainer/HBoxContainer/TimerLabel
@onready var orbs_label: Label = $TopStrip/MarginContainer/HBoxContainer/OrbsLabel
@onready var heart_1: Label = $HealthRow/Heart1
@onready var heart_2: Label = $HealthRow/Heart2
@onready var heart_3: Label = $HealthRow/Heart3

const COLOR_HEART_FULL  := Color(1.0, 0.2, 0.2, 1.0)
const COLOR_HEART_EMPTY := Color(0.25, 0.25, 0.25, 1.0)

var current_time: float = 0.0
var is_running: bool = false
var max_orbs: int = 3
var _hearts: Array

func _ready() -> void:
	instance = self
	_hearts = [heart_1, heart_2, heart_3]
	hide()

func _process(delta: float) -> void:
	if not is_running:
		return
	current_time += delta
	_refresh_timer()

func setup_level(display_name: String, level_number: int, orb_count: int = 3) -> void:
	level_label.text = "Lv.%d  %s" % [level_number, display_name]
	max_orbs = orb_count
	current_time = 0.0
	_refresh_timer()
	_refresh_orbs(0)
	_refresh_hearts(3)

func connect_player(player: Player) -> void:
	if player.health_changed.is_connected(_on_health_changed):
		player.health_changed.disconnect(_on_health_changed)
	player.health_changed.connect(_on_health_changed)
	_refresh_hearts(player.health)

func show_hud() -> void:
	show()
	is_running = true

func hide_hud() -> void:
	hide()
	is_running = false

func update_orbs(count: int) -> void:
	_refresh_orbs(count)

func _refresh_timer() -> void:
	var m  := int(current_time) / 60
	var s  := int(current_time) % 60
	var cs := int(fmod(current_time, 1.0) * 100)
	timer_label.text = "%02d:%02d.%02d" % [m, s, cs]

func _refresh_orbs(count: int) -> void:
	orbs_label.text = "♦ %d/%d" % [count, max_orbs]

func _refresh_hearts(health: int) -> void:
	for i in _hearts.size():
		_hearts[i].add_theme_color_override(
			"font_color",
			COLOR_HEART_FULL if i < health else COLOR_HEART_EMPTY
		)

func _on_health_changed(new_health: int) -> void:
	_refresh_hearts(new_health)
