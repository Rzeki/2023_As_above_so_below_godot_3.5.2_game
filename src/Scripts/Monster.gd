extends KinematicBody2D

onready var nav_agent = $NavigationAgent2D
onready var timer: Timer = $Timer
onready var ray: RayCast2D = $Vision_ray
onready var vision = $Area2D/Vision
onready var global = get_node("/root/Global")
onready var horror_tension_player = $horror_tension_player
onready var heartbeat_player = $heartbeat_player
onready var m_particles = $Particles2D

var Evidence = preload("res://src/Evidence.tscn")

enum States {
	INACTIVE,
	ROAMING,
	SEARCHING,
	ANGRY
}

enum Monsters {
	WEREWOLF,
	VAMPIRE,
	GHOST,
	UNDEAD,
	DEMON,
	SKELETON
}

enum Evidences {
	BLOOD,
	CLAWS,
	BONES,
	BITES,
	CRUCIFIX,
	SUMMONING_RING,
	ORBS,
	SCREECH
}

onready var Monster_evidences = [
	[Evidences.BLOOD, Evidences.CLAWS, Evidences.BONES],
	[Evidences.BLOOD, Evidences.BITES, Evidences.CRUCIFIX],
	[Evidences.SUMMONING_RING, Evidences.SCREECH, Evidences.ORBS],
	[Evidences.BONES, Evidences.BITES, Evidences.ORBS],
	[Evidences.SUMMONING_RING, Evidences.BLOOD, Evidences.CRUCIFIX],
	[Evidences.CLAWS, Evidences.SCREECH, Evidences.BONES]
	
]

var state
var monster_type = Monsters.keys()[randi() % Monsters.size()]
var m_speed: float = 140.0
var velocity = Vector2.ZERO
var player = null
var rooms = null
var m_evidence: Array = []
var has_screeched = false


func _ready():
	randomize()
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("Rooms"):
		rooms = tree.get_nodes_in_group("Rooms")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	state = States.ROAMING
	update_pathfinding()
	timer.connect("timeout", self, "update_pathfinding")
#	nav_agent.connect("velocity_computed", self, "move")
	ray.add_exception($Monster_body)
	ray.add_exception($Area2D)
	$heartbeat_player.play()
	$Vision_timer.stop()
	global.monster = monster_type
	get_evidence()

func _input(event):
	m_particles.visible = Input.is_key_pressed(KEY_SPACE)

func get_evidence():
#	if monster_type == Monsters.keys()[Monsters.VAMPIRE]:
#		m_evidence.append_array([Evidences.BLOOD, Evidences.BITES, Evidences.CRUCIFIX])
#	if monster_type == Monsters.keys()[Monsters.WEREWOLF]:
#		m_evidence.append_array([Evidences.BLOOD, Evidences.CLAWS, Evidences.BONES])
#	if monster_type == Monsters.keys()[Monsters.DEMON]:
#		m_evidence.append_array([Evidences.SUMMONING_RING, Evidences.BLOOD, Evidences.CRUCIFIX])
#	if monster_type == Monsters.keys()[Monsters.GHOST]:
#		m_evidence.append_array([Evidences.SUMMONING_RING, Evidences.SCREECH, Evidences.ORBS])
#	if monster_type == Monsters.keys()[Monsters.UNDEAD]:
#		m_evidence.append_array([Evidences.BONES, Evidences.BITES, Evidences.ORBS])
#	if monster_type == Monsters.keys()[Monsters.SKELETON]:
#		m_evidence.append_array([Evidences.CLAWS, Evidences.SCREECH, Evidences.BONES])
	m_evidence.append_array(Monster_evidences[Monsters.keys().find(monster_type)])
			
func _physics_process(delta):	
	if !(player and rooms):
		return
		
	var direction := global_position.direction_to(nav_agent.get_next_location())
	
	var desired_velocity := direction * m_speed
	var steering = (desired_velocity - velocity) * delta * 4.0
	velocity += steering
	nav_agent.set_velocity(velocity)
	
	if velocity:
		$Area2D/Vision.look_at(transform.origin - velocity.rotated(PI/2))
	ray.cast_to = player.global_position - global_position
	$heartbeat_player.pitch_scale = abs((((0 - ray.get_cast_to().length()) * (0.9 - 2)) / (0 - 1000.0)) + 2)
	$heartbeat_player.volume_db = (((0 - ray.get_cast_to().length()) * (-16 - 16)) / (0 - 2000.0)) + 16
	$horror_tension_player.volume_db = (((0 - ray.get_cast_to().length()) * (-16 - 4)) / (0 - 300.0)) + 4
#		Normalization --> (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
	move(velocity)
	
func move(vel):
	velocity = move_and_slide(vel)

func update_pathfinding():
	match state:
		States.ANGRY:
			nav_agent.set_target_location(player.global_position)	
		States.ROAMING:
			if nav_agent.is_navigation_finished():
				nav_agent.set_target_location(rand_room())	
		
	

#func _on_NavigationAgent2D_navigation_finished() -> void:
#	if state == States.ROAMING:
#			nav_agent.set_target_location(rand_room())

func rand_room():
	return rooms.get_child(randi() % rooms.get_child_count()).position

func _on_Area2D_body_entered(body: Node) -> void:
	if is_player_visible(body):
		if m_evidence.has(Evidences.SCREECH) and !has_screeched:
			if randf() < 0.5:
				$screech_player.play()
				has_screeched = true
		m_speed = 190.0
		$horror_tension_player.play()
		$Vision_timer.stop()	
		if m_evidence and m_evidence.has(Evidences.CRUCIFIX):
			player.crucifix_timer.start()
		state = States.ANGRY


func _on_Area2D_body_exited(body: Node) -> void:
	if body == player:
		$Vision_timer.start()
		if m_evidence and m_evidence.has(Evidences.CRUCIFIX):
			player.crucifix_timer.stop()

func is_player_visible(body):
	return body == player and ray.get_collider() == player


func _on_Vision_timer_timeout() -> void:
	state = States.ROAMING
	$horror_tension_player.stop()
	m_speed = 150.0
	has_screeched = false


func _on_Death_box_body_entered(body: Node) -> void:
	if body == player:
		player.alive = false
		player.p_collision_shape.disabled = true
		player.die()


#func _on_NavigationAgent2D_velocity_computed(safe_velocity: Vector2) -> void:
#	move(safe_velocity)

