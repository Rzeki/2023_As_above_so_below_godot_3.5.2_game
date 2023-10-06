extends Control

onready var global = get_node("/root/Global")

func _ready() -> void:
	$Tween.interpolate_property(
		$Light2D,
		"energy", 
		$Light2D.energy, 
		rand_range(2.5, 3.5), 
		0.2, 
		Tween.TRANS_BOUNCE)
		
	$Tween_inv.interpolate_property(
		$Light2D,
		"energy", 
		$Light2D.energy, 
		rand_range(3.5, 2.5), 
		0.2, 
		Tween.TRANS_BOUNCE)
	$Tween.start()
	$Monster_result.text = global.monster

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://src/Main_menu.tscn")

func _on_Tween_inv_tween_completed(object: Object, key: NodePath) -> void:
	$Tween.interpolate_property(
		$Light2D,
		"energy", 
		$Light2D.energy, 
		rand_range(2.5, 3.5), 
		0.2, 
		Tween.TRANS_BOUNCE)
	$Tween.start()


func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	$Tween_inv.interpolate_property(
		$Light2D,
		"energy", 
		$Light2D.energy, 
		rand_range(3.5, 2.5), 
		0.2, 
		Tween.TRANS_BOUNCE)
	$Tween_inv.start()
