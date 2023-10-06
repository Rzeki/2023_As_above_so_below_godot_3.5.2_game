extends RigidBody2D

onready var area = $Area2D
onready var spacing = $spacing

var evidence

	
func _input(event):
	$Particles2D.visible = Input.is_key_pressed(KEY_SPACE)
	
func set_evidence(ev):
	evidence = ev
