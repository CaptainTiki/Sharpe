extends Node2D
class_name GameManager

static var instance : GameManager = null

@onready var data_manager = $"../DataManager"  # Adjust path if needed

var current_level: Level = null
var current_level_scene : PackedScene = null
var current_level_name: String = ""

func _ready() -> void:
	instance = self

func start_game() -> void:
	#TODO: setup a "start game" cinematic or fluff text
	load_level(Prefabs.debug_level)

func load_level(level_scene: PackedScene) -> void:
	if current_level:
		current_level.queue_free()

	if level_scene:
		current_level_scene = level_scene
		current_level = level_scene.instantiate()
		add_child.call_deferred(current_level)
		current_level_name = current_level.name.to_lower()
		current_level.player_died.connect(_on_player_death)
		data_manager.reset_level_data(current_level_name)

		var player: Player = current_level.get_node_or_null("Player")
		if player:
			player.died.connect(_on_player_death)
			HUD.instance.connect_player(player)

		HUD.instance.setup_level(
			current_level.level_display_name,
			current_level.level_number,
			current_level.orb_count
		)
		HUD.instance.show_hud()

func _on_player_death() -> void:
	# Instant respawn or reload current level with timer reset
	if current_level_scene:
		load_level(current_level_scene)

# Example exit handler — call this from level's exit Area2D
func handle_level_exit(next_level_scene: PackedScene) -> void:
	data_manager.save_level_time(current_level_name, data_manager.total_time)  # or however you track time
	#TODO: Optional fade transition here
	load_level(next_level_scene)
