extends RigidBody2D

onready var area = $Area2D
onready var spacing = $spacing

var blood_sprites = [
preload("res://assets/Evidence/bloodstain_1.png"),
preload("res://assets/Evidence/bloodstain_2.png"),
preload("res://assets/Evidence/bloodstain_3.png"),
preload("res://assets/Evidence/bloodstain_4.png")
]

var bones_sprites = [
preload("res://assets/Evidence/bones1.png"),
preload("res://assets/Evidence/bones2.png"),
preload("res://assets/Evidence/bones3.png"),
preload("res://assets/Evidence/bones4.png")
]

var pentagram_sprites = [
	preload("res://assets/Evidence/pentagram_evidence.png")
]

var evidence

func _ready() -> void:
	randomize()
	
	
	
func set_evidence(ev):
	evidence = ev
	match evidence:
		"BLOOD":
			$body.texture = blood_sprites[randi() % blood_sprites.size()]
		"BONES":
			$body.texture = bones_sprites[randi() % bones_sprites.size()]
		"SUMMONING_RING":
			$body.texture = pentagram_sprites[randi() % pentagram_sprites.size()]
