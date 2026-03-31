extends Node2D
class_name Main

func _ready() -> void:
	MenuManager.instance.show_menu(Menu.Type.MAIN)
