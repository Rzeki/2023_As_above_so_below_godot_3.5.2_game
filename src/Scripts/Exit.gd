extends StaticBody2D

var _pos
var player_inside = false
var player

onready var global = get_node("/root/Global")

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	
func _input(event):
	if event.is_action_pressed("interact") and player_inside:
		get_tree().change_scene("res://src/Summary.tscn")

func set_pos(pos):
	position = pos





func _on_Area2D_body_entered(body: Node) -> void:
	if !player:
		return
	
	if body == player:
		player_inside = true


func _on_Area2D_body_exited(_body: Node) -> void:
	player_inside = false
