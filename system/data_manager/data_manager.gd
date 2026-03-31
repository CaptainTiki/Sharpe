extends Node
class_name DataManager

# Persistent data across all scenes/levels
var total_time: float = 0.0
var level_times: Dictionary = {}  # "bedroom_01": 42.5
var collected_orbs: Dictionary = {}  # "bedroom_01": 3
var total_orbs_collected: int = 0
var high_scores: Dictionary = {}

# Example functions
func reset_level_data(level_name: String) -> void:
	level_times[level_name] = 0.0
	collected_orbs[level_name] = 0

func add_orb(level_name: String) -> void:
	if not collected_orbs.has(level_name):
		collected_orbs[level_name] = 0
	collected_orbs[level_name] += 1
	total_orbs_collected += 1

func save_level_time(level_name: String, time: float) -> void:
	level_times[level_name] = time
	if not high_scores.has(level_name) or time < high_scores[level_name]:
		high_scores[level_name] = time
