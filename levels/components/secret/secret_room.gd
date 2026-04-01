extends Node2D

func _ready() -> void:
	_set_room_visible(false)
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		_set_room_visible(true)

func _set_room_visible(shown: bool) -> void:
	for child in get_children():
		if child is CanvasItem and not child is Area2D:
			child.visible = shown
