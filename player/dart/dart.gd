extends Area2D

var direction: int = 1
var speed: float = 420.0
var stuck: bool = false
var life: float = 8.0
var stuck_life: float = 15.0

@export var spring_force: float = -420.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.flip_h = direction < 0
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if stuck:
		stuck_life -= delta
		if stuck_life <= 0.0:
			queue_free()
		return
	position.x += direction * speed * delta
	life -= delta
	if life <= 0.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if not stuck:
		if not body is Player:
			stuck = true
		return
	# Springboard: launch player upward on contact while falling
	if body is Player and body.velocity.y > 0:
		body.velocity.y = spring_force
