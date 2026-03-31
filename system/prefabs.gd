extends RefCounted
class_name Prefabs

# We do not create UIDs - we fall back to paths. If a UID is ready - we can use that instead here. 

## Menus
static var main_menu : PackedScene = load("uid://bqq0s0iilv86x")


## Levels
static var debug_level : PackedScene = load("res://levels/debug_level/debug_level.tscn")
