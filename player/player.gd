extends CharacterBody2D
class_name Player

@export var speed: float = 180.0
@export var jump_velocity: float = -280.0
@export var gravity: float = 980.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.1
@export var dart_reload_time: float = 1.8

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node = get_node("/root/Main/GameManager")  # adjust path if needed

var facing_right: bool = true
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_crouching: bool = false
var can_shoot: bool = true
var dart_scene = null

func _ready() -> void:
	dart_scene = Prefabs.dart_scene

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_timer -= delta
	else:
		coyote_timer = coyote_time

	# Horizontal movement
	var dir = Input.get_axis("ui_left", "ui_right")
	if dir != 0:
		velocity.x = dir * speed
		facing_right = dir > 0
		sprite.flip_h = not facing_right
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 0.25)

	# Crouch + slide
	is_crouching = Input.is_action_pressed("crouch")
	if is_crouching and is_on_floor():
		velocity.x *= 1.35  # slide momentum

	# Jump logic
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	if (Input.is_action_just_pressed("jump") or jump_buffer_timer > 0) and (is_on_floor() or coyote_timer > 0):
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# Wall slide / jump (Celeste style)
	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		velocity.y = min(velocity.y, 80)  # gentle slide

	move_and_slide()

	# Dart gun (straight shoot)
	if Input.is_action_just_pressed("shoot") and can_shoot:
		_fire_dart()
		can_shoot = false
		await get_tree().create_timer(dart_reload_time).timeout
		can_shoot = true

func _fire_dart() -> void:
	var dart = dart_scene.instantiate()
	dart.global_position = global_position + Vector2(14 if facing_right else -14, -6)
	dart.direction = 1 if facing_right else -1
	get_parent().add_child(dart)
	# TODO: play shoot animation on sprite

# Call this from GameManager on death
func die() -> void:
	queue_free()
