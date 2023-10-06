extends RigidBody2D

onready var area = $Area2D
onready var spacing = $spacing
onready var timer = $Timer
onready var progress_bar = $ProgressBar

var evidence
var player_inside_range
var player

func _ready() -> void:
	randomize()
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	player_inside_range = false
	
func set_evidence(ev):
	evidence = ev
	if evidence == "BITES":
		$body/TextureRect.texture = load("res://assets/Evidence/teeth_icon.png")
	if evidence == "CLAWS":
		$body/TextureRect.texture = load("res://assets/Evidence/claws_icon.png")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_inside_range and !$body/TextureRect.visible:
		progress_bar.visible = true
		timer.start()

func _process(delta: float) -> void:
	progress_bar.value = progress_bar.max_value - round(timer.get_time_left())

func _on_Area2D_body_entered(body: Node) -> void:
	if !player:
		return
	
	if body == player:
		player_inside_range = true


func _on_Area2D_body_exited(body: Node) -> void:
	if !player:
		return
	
	if body == player:
		$body/TextureRect.visible = false
		$ProgressBar.visible = false
		timer.stop()
		player_inside_range = false


func _on_Timer_timeout() -> void:
	progress_bar.visible = false
	$body/TextureRect.visible = true
