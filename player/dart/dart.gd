# scripts/dart.gd
extends Area2D

var direction: int = 1
var speed: float = 420.0
var stuck: bool = false
var life: float = 8.0

func _ready() -> void:
	$CollisionShape2D.disabled = false

func _physics_process(delta: float) -> void:
	if not stuck:
		position.x += direction * speed * delta
		life -= delta
		if life <= 0:
			queue_free()
	# When stuck it acts as bouncy platform (collision stays)

func _on_body_entered(body: Node2D) -> void:
	if not stuck and body.is_in_group("solid"):  # or check tilemap
		stuck = true
		# TODO: switch to embedded sprite + bounce animation
