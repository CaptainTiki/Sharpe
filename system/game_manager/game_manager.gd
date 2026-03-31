extends Node2D
class_name GameManager

static var instance : GameManager = null

func _ready() -> void:
	instance = self
