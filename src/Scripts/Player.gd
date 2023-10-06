extends KinematicBody2D
onready var _animation_player = $AnimationPlayer
onready var p_collision_shape = $CollisionShape2D
onready var death_screen = $death_screen
onready var crucifix_timer = $Crucifix_timer
onready var cave_sfx = $Cave_sfx


var Journal = preload("res://src/Journal.tscn")
var green_bar = preload("res://assets/Player/progress.png")
var red_bar = preload("res://assets/Player/stamina_exausted.png")
var crucifix_broken = preload("res://assets/Evidence/crucifix_broken.png")

var alive = true
var velocity = Vector2.ZERO
var sprint_speed = 150
var stamina = 1000
var stamina_cap = 1000
var can_sprint = true
var torch_min = 1.5
var torch_max = 2.2
var monster
var monster_diff
var p_journal 
var bottles_count = 1

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("Monster"):
		monster = tree.get_nodes_in_group("Monster")[0]
	$journal_layer.add_child(Journal.instance())
	p_journal = get_node("journal_layer/Journal")
	for i in range(1, bottles_count):
		var btn = $GridContainer/bottle1.duplicate()
		btn.name = "bottle" + String(i)
		$GridContainer.add_child(btn)
	

func _input(event):
	if !alive:
		return
		
	if event.is_action_pressed("ui_page_up") and $Camera2D.zoom >= Vector2(0.3,0.3):
		$Camera2D.zoom = $Camera2D.zoom - Vector2(0.1, 0.1)
	if event.is_action_pressed('ui_page_down') and $Camera2D.zoom <= Vector2(0.8,0.8):
		$Camera2D.zoom = $Camera2D.zoom + Vector2(0.1, 0.1)
	if event.is_action_pressed("ui_journal") or event.is_action_pressed("ui_cancel"):
		if(p_journal.visible):
			p_journal.sfx_player.stream = p_journal.sfx_close
		else:
			p_journal.sfx_player.stream = p_journal.sfx_open
		p_journal.pages[p_journal.active_page].visible = false
		if event.is_action_pressed("ui_cancel") and !p_journal.visible:
			p_journal.active_page = p_journal.pages.find(p_journal.menu)
		if event.is_action_pressed("ui_journal") and !p_journal.visible:
			p_journal.active_page = p_journal.pages.find(p_journal.evidence_and_monsters)
		p_journal.visible = !p_journal.visible
		p_journal.sfx_player.play()
	if event.is_action_pressed("bottle_throw") and bottles_count:
		bottles_count -= 1
		$GridContainer.get_child(0).queue_free()
		$bottle_throw_particle.emitting = true;
		$Bottle_sfx.play()
		$GridContainer.visible = true
		yield(get_tree().create_timer(0.3),"timeout")
		$bottle_flash.visible = true
		if monster.ray.get_cast_to().length() < 500 and monster.ray.get_collider() == self:
			monster.vision.disabled = true
			monster.state = monster.States.ROAMING
		yield(get_tree().create_timer(0.2),"timeout")
		$bottle_flash.visible = false
		yield(get_tree().create_timer(4.5),"timeout")
		$GridContainer.visible = false
		yield(get_tree().create_timer(10),"timeout")
		monster.vision.disabled = false
	$GridContainer.visible = Input.is_key_pressed(KEY_TAB)
	$Crucifix.visible = Input.is_key_pressed(KEY_TAB)
	$listening_screen.visible = Input.is_key_pressed(KEY_SPACE)
	if Input.is_key_pressed(KEY_SPACE):
		cave_sfx.pitch_scale = 0.5 
		cave_sfx.volume_db = -10
	else:	
		cave_sfx.pitch_scale = 1
		cave_sfx.volume_db = -5
		

func _process(delta: float) -> void:
	if !alive:
		return
		
	var input_Vec = Vector2.ZERO
	input_Vec.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_Vec.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	
	if input_Vec != Vector2.ZERO:
		if Input.is_action_pressed("shift_run") and can_sprint:
			if stamina > 2:
				stamina -= 2
				$Stamina_bar.visible = true
				$Stamina_bar.value -= 2
				sprint_speed = 230
			else:
				can_sprint = false
				$Stamina_bar.texture_progress = red_bar
		else:
			sprint_speed = 150
		$Player.set_flip_h( !input_Vec.x == 1 )
		_animation_player.play("Walk")
		velocity = input_Vec * sprint_speed * delta
	else:
		_animation_player.play("idle")
		velocity = Vector2.ZERO
		
		
	if stamina < stamina_cap:
		stamina+=1
		$Stamina_bar.value+=1
	if stamina == stamina_cap:
		$Stamina_bar.visible = false
		$Stamina_bar.texture_progress = green_bar
		can_sprint = true
	
		
	monster_diff = (((0 - monster.ray.get_cast_to().length()) * (0 - torch_min)) / (0 - 300.0)) + torch_min
	$bigger_light2.texture_scale = min(2, 2 - monster_diff)
	
	move_and_collide(velocity)
	


func _on_Player_ready() -> void:
	$Cave_sfx.play()
	$Tween.interpolate_property(
		$torch_light,
		"energy", 
		$torch_light.energy, 
		rand_range(torch_min, torch_max), 
		0.5, 
		Tween.TRANS_BOUNCE)
		
	$Tween_inv.interpolate_property(
		$torch_light,
		"energy", 
		$torch_light.energy, 
		rand_range(torch_max, torch_min), 
		0.5, 
		Tween.TRANS_BOUNCE)
	$Tween.start()
		



func _on_Tween_tween_completed(_object: Object, _key: NodePath) -> void:
	$Tween_inv.interpolate_property(
		$torch_light,
		"energy", 
		$torch_light.energy, 
		rand_range(min(torch_max, torch_max - monster_diff), min(torch_min,torch_min - monster_diff)), 
		0.2, 
		Tween.TRANS_BOUNCE)
	$Tween_inv.start()


func _on_Tween_inv_tween_completed(_object: Object, _key: NodePath) -> void:
	$Tween.interpolate_property(
		$torch_light,
		"energy", 
		$torch_light.energy, 
		rand_range(min(torch_min,torch_min - monster_diff), min(torch_max, torch_max - monster_diff)), 
		0.2, 
		Tween.TRANS_BOUNCE)
	$Tween.start()

func die():
	velocity = Vector2.ZERO
	_animation_player.stop()
	var zoom_tween = Tween.new()
	add_child(zoom_tween)
	zoom_tween.interpolate_property(
	$Camera2D, "zoom", 
	$Camera2D.zoom, Vector2(0.3,0.3), 1,
	Tween.TRANS_LINEAR)
	zoom_tween.start()
	monster.visible = false
	monster.heartbeat_player.stop()
	$Cave_sfx.stop()
	get_parent().Ambient_timer.stop()
	$Stamina_bar.visible = false
	$GridContainer.visible = false
	yield(get_tree().create_timer(1),"timeout")
	$death_final_ambient.play()
	yield(get_tree().create_timer(0.4),"timeout")
	_animation_player.play("Death")
	monster.horror_tension_player.stop()
	yield(get_tree().create_timer(1.7),"timeout")
	death_screen.visible = true
	yield(get_tree().create_timer(5),"timeout")
	get_tree().change_scene("res://src/Summary.tscn")
	


func _on_Crucifix_timer_timeout() -> void:
	$Crucifix.texture = crucifix_broken
