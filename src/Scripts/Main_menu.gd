extends Control

onready var menu_sprites = [
	preload("res://assets/Background/bg_1.png"),
	preload("res://assets/Background/bg_2.png"),
	preload("res://assets/Background/bg_3.png"),
	preload("res://assets/Background/bg_4.png"),
	preload("res://assets/Background/bg_5.png"),
	preload("res://assets/Background/bg_6.png"),
	preload("res://assets/Background/bg_7.png"),
	preload("res://assets/Background/bg_8.png"),
	preload("res://assets/Background/bg_9.png")
	]

func _ready() -> void:
	randomize()
	$VBoxContainer/Start.grab_focus()
	$Menu_theme.play()
	$TextureRect.texture = menu_sprites[randi() % menu_sprites.size()]
	
	$Tween.interpolate_property(
		$TextureRect,
		"modulate", 
		Color(1,1,1,0), 
		Color(1,1,1,0.75), 
		5, 
		Tween.TRANS_LINEAR)
		
	$Tween_inv.interpolate_property(
		$TextureRect,
		"modulate", 
		Color(1,1,1,0.75), 
		Color(1,1,1,0), 
		5, 
		Tween.TRANS_LINEAR)
	$Tween.start()
	

func _on_Start_pressed() -> void:
	get_tree().change_scene("res://src/World.tscn")

func _on_Exit_pressed() -> void:
	get_tree().quit()



func _on_Tween_tween_completed(_object: Object, _key: NodePath) -> void:
	$Tween_inv.interpolate_property(
		$TextureRect,
		"modulate", 
		Color(1,1,1,0.75), 
		Color(1,1,1,0), 
		5, 
		Tween.TRANS_LINEAR)
		
	$Tween_inv.start()


func _on_Tween_inv_tween_completed(_object: Object, _key: NodePath) -> void:
	$Tween.interpolate_property(
		$TextureRect,
		"modulate", 
		Color(1,1,1,0), 
		Color(1,1,1,0.75), 
		5, 
		Tween.TRANS_LINEAR)
	yield(get_tree().create_timer(3.0), "timeout")
	$TextureRect.texture = menu_sprites[randi() % menu_sprites.size()]
	$Tween.start()


func _on_Start_mouse_entered() -> void:
	$VBoxContainer/Start.grab_focus()


func _on_Options_mouse_entered() -> void:
	$VBoxContainer/Options.grab_focus()


func _on_Customization_mouse_entered() -> void:
	$VBoxContainer/Customization.grab_focus()


func _on_Exit_mouse_entered() -> void:
	$VBoxContainer/Exit.grab_focus()
