extends Area2D

const BOB_AMPLITUDE := 3.0
const BOB_SPEED     := 2.5

var _phase: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_phase = randf() * TAU
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	sprite.position.y = sin(Time.get_ticks_msec() * 0.001 * BOB_SPEED + _phase) * BOB_AMPLITUDE

func _on_body_entered(body: Node) -> void:
	if body is Player:
		GameManager.instance.collect_shard()
		queue_free()
