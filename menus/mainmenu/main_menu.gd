extends Menu

func _on_start_btn_pressed() -> void:
	MenuManager.instance.hide_all_menus()
	GameManager.instance.start_game()

func _on_settings_btn_pressed() -> void:
	pass # Replace with function body.

func _on_exit_btn_pressed() -> void:
	get_tree().quit()
