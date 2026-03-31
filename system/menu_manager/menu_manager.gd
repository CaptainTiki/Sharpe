extends Control
class_name MenuManager

static var instance : MenuManager = null

var menu_scenes = {}

var menus: Dictionary = {}
var current_menu: Menu = null

func _ready() -> void:
	init_menus()
	instance = self

func show_menu(type: Menu.Type) -> void:
	if current_menu:
		current_menu.visible = false
		current_menu.set_process(false)
	current_menu = menus[type]
	current_menu.visible = true
	current_menu.set_process(true)

func hide_all_menus() -> void:
	if current_menu:
		current_menu.visible = false
		current_menu.set_process(false)
	current_menu = null

func init_menus() -> void:
	menu_scenes[Menu.Type.MAIN] = Prefabs.main_menu
	
	for type in menu_scenes:
		var menu : Menu = menu_scenes[type].instantiate()
		menus[type] = menu
		add_child.call_deferred(menu)
		menu.hide_menu()
