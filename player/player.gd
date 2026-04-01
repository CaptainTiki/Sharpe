extends CharacterBody2D
class_name Player

@export var speed: float = 180.0
@export var jump_velocity: float = -280.0
@export var gravity: float = 980.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.1
@export var dart_reload_time: float = 1.8
@export var max_health: int = 3
@export var sprint_multiplier: float = 1.65
@export var slide_duration: float = 0.55
@export var slide_friction: float = 0.91   # fraction of velocity kept per frame at 60fps
@export var wall_jump_horizontal: float = 160.0
@export var wall_coyote_time: float = 0.12
@export var wall_jump_lock: float = 0.15   # seconds of horizontal input lock after wall jump

signal health_changed(new_health: int)
signal died

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Collider dimensions — must match player.tscn CapsuleShape2D
const SHAPE_STAND_HEIGHT  := 22.0
const SHAPE_STAND_OFFSET  := -11.0
const SHAPE_CROUCH_HEIGHT := 11.0
const SHAPE_CROUCH_OFFSET := -5.5

var health: int
var facing_right: bool = true
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var can_shoot: bool = true
var dart_scene = null

var is_sprinting: bool = false
var is_sliding: bool = false
var slide_timer: float = 0.0
var wall_coyote_timer: float = 0.0
var last_wall_normal: Vector2 = Vector2.ZERO
var wall_jump_lock_timer: float = 0.0
var is_shooting: bool = false
var shoot_anim_timer: float = 0.0
var is_dead: bool = false

const SHOOT_ANIM_DURATION := 0.25

func _ready() -> void:
	dart_scene = Prefabs.dart_scene
	health = max_health

func _physics_process(delta: float) -> void:
	# --- Gravity ---
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_timer -= delta
	else:
		coyote_timer = coyote_time

	# --- Wall tracking (feeds wall-jump coyote window) ---
	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		last_wall_normal = get_wall_normal()
		wall_coyote_timer = wall_coyote_time
	else:
		wall_coyote_timer = max(wall_coyote_timer - delta, 0.0)

	# --- Sprint ---
	is_sprinting = Input.is_action_pressed("sprint") and not is_sliding
	var current_speed := speed * (sprint_multiplier if is_sprinting else 1.0)

	# --- Slide update ---
	if is_sliding:
		slide_timer -= delta
		# Frame-rate independent exponential friction
		velocity.x *= pow(slide_friction, delta * 60.0)
		if slide_timer <= 0.0 or abs(velocity.x) < 20.0:
			is_sliding = false
			_set_crouch_collider(false)

	# --- Horizontal movement ---
	if wall_jump_lock_timer > 0.0:
		wall_jump_lock_timer -= delta
	elif not is_sliding:
		var dir := Input.get_axis("move_left", "move_right")
		if dir != 0:
			velocity.x = dir * current_speed
			facing_right = dir > 0
			sprite.flip_h = not facing_right
		else:
			velocity.x = move_toward(velocity.x, 0.0, current_speed * 0.25)

	# --- Jump input buffer ---
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta

	# --- Wall jump (checked before floor jump so coyote doesn't steal it) ---
	var can_wall_jump := wall_coyote_timer > 0.0 and not is_on_floor()
	if jump_buffer_timer > 0.0 and can_wall_jump:
		velocity.y = jump_velocity
		velocity.x = last_wall_normal.x * wall_jump_horizontal
		facing_right = velocity.x > 0
		sprite.flip_h = not facing_right
		wall_coyote_timer = 0.0
		jump_buffer_timer = 0.0
		wall_jump_lock_timer = wall_jump_lock

	# --- Floor jump ---
	if jump_buffer_timer > 0.0 and (is_on_floor() or coyote_timer > 0.0):
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# --- Wall slide ---
	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		velocity.y = min(velocity.y, 80.0)

	# --- Slide trigger ---
	if Input.is_action_just_pressed("crouch") and is_on_floor() and is_sprinting and not is_sliding:
		is_sliding = true
		slide_timer = slide_duration
		_set_crouch_collider(true)

	move_and_slide()

	# --- Shoot anim timer ---
	if shoot_anim_timer > 0.0:
		shoot_anim_timer -= delta
		if shoot_anim_timer <= 0.0:
			is_shooting = false

	# --- Dart gun ---
	if Input.is_action_just_pressed("shoot") and can_shoot:
		_fire_dart()
		can_shoot = false
		await get_tree().create_timer(dart_reload_time).timeout
		can_shoot = true

	_update_animation()

func _fire_dart() -> void:
	var dart = dart_scene.instantiate()
	dart.global_position = global_position + Vector2(14 if facing_right else -14, -6)
	dart.direction = 1 if facing_right else -1
	get_parent().add_child(dart)
	is_shooting = true
	shoot_anim_timer = SHOOT_ANIM_DURATION

func _update_animation() -> void:
	var anim: String
	if is_dead:
		anim = "die"
	elif is_sliding:
		anim = "slide"
	elif is_on_wall() and not is_on_floor() and velocity.y > 0:
		anim = "wall_slide"
	elif not is_on_floor():
		anim = "jump"
	elif is_shooting and abs(velocity.x) > 10.0:
		anim = "run_shoot"
	elif is_shooting:
		anim = "shoot"
	elif abs(velocity.x) > 10.0:
		anim = "run"
	else:
		anim = "idle"

	if sprite.animation != anim:
		sprite.play(anim)

func _set_crouch_collider(crouching: bool) -> void:
	var shape := collision_shape.shape as CapsuleShape2D
	if crouching:
		shape.height = SHAPE_CROUCH_HEIGHT
		collision_shape.position.y = SHAPE_CROUCH_OFFSET
	else:
		shape.height = SHAPE_STAND_HEIGHT
		collision_shape.position.y = SHAPE_STAND_OFFSET

func take_damage(amount: int = 1) -> void:
	health -= amount
	health_changed.emit(health)
	if health <= 0:
		died.emit()
		die()

# Call this from GameManager on death
func die() -> void:
	is_dead = true
	queue_free()
