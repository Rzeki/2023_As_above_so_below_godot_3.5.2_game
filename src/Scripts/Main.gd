extends Node2D

var Room = preload("res://src/Room.tscn")
var Player = preload("res://src/Player.tscn")
var Monster = preload("res://src/Monster.tscn")
var Rock = preload("res://src/Rock.tscn")
var Exit = preload("res://src/Exit.tscn")
var Noises = [
	preload("res://assets/Music/ambient_noise_1.mp3"), 
	preload("res://assets/Music/ambient_noise_2.mp3"), 
	preload("res://assets/Music/ambient_noise_3.mp3"),
	preload("res://assets/Music/ambient_noise_4.mp3"),
	preload("res://assets/Music/ambient_noise_5.mp3")
	]
var Evidence = preload("res://src/Evidence.tscn")	
var Dead_body = preload("res://src/Dead_body.tscn")
var Orbs = preload("res://src/Orbs.tscn")

onready var Map = $TileMap
onready var Ambient_timer: Timer = $Ambient_noise_timer

var tile_size = 64
var num_rooms = 35
var min_size = 6
var max_size = 8
var v_spread = 40
var cull = 0.7

var path
var start_room = null
var end_room = null
var play_mode = false  
var player = null
var exit = null
var monster = null


func _ready() -> void:
	randomize()
	make_rooms()
	yield(get_tree().create_timer(2),"timeout")
	make_map()
	stonify()
	yield(get_tree().create_timer(0.5),"timeout")
	player = Player.instance()
	monster = Monster.instance()
	exit = Exit.instance()
	add_child(player)
	add_child(monster)
	add_child(exit)
	exit.set_pos(start_room.position)
	player.position = start_room.position
	while true:
		monster.position = $Rooms.get_child(randi() % $Rooms.get_child_count()).position
		if monster.position != start_room.position:
			break
	Ambient_timer.connect("timeout", self, "play_random_noise_in_room")
	play_mode = true
	yield(get_tree().create_timer(2),"timeout")
	place_evidence()
	yield(get_tree().create_timer(1),"timeout")
	$loading_screen.visible = false

func place_evidence():
	for ev in monster.m_evidence:
		var curr_evidence
		if monster.Evidences.keys()[ev] == "CRUCIFIX" or monster.Evidences.keys()[ev] == "SCREECH":
			continue
		if monster.Evidences.keys()[ev] == "CLAWS" or monster.Evidences.keys()[ev] == "BITES":
			curr_evidence = Dead_body.instance()
		if monster.Evidences.keys()[ev] == "ORBS":
			curr_evidence = Orbs.instance()
		if monster.Evidences.keys()[ev] == "SUMMONING_RING" or monster.Evidences.keys()[ev] == "BONES" or monster.Evidences.keys()[ev] == "BLOOD":
			curr_evidence = Evidence.instance()
		curr_evidence.set_evidence(monster.Evidences.keys()[ev])
		var room = $Rooms.get_child(randi() % $Rooms.get_child_count())
		curr_evidence.position.x = (room.position.x - room.size.x/2) + rand_range(0,room.size.x)
		curr_evidence.position.y = (room.position.y - room.size.y/2) + rand_range(0,room.size.y)
		$WorldEvidences.add_child(curr_evidence)
		print(monster.Evidences.keys()[ev])
	yield(get_tree().create_timer(1),"timeout")
	for evidence in $WorldEvidences.get_children():
		evidence.spacing.disabled = true
		evidence.mode = RigidBody2D.MODE_STATIC
	
func stonify():
	var curr_stone
	for room in $Rooms.get_children():
		for i in rand_range(2,4):
				curr_stone = Rock.instance()
				curr_stone.position.x = (room.position.x - room.size.x/2) + rand_range(0,room.size.x)
				curr_stone.position.y = (room.position.y - room.size.y/2) + rand_range(0,room.size.y)
				$WorldEnvironment.add_child(curr_stone)
	yield(get_tree().create_timer(1),"timeout")
	for stone in $WorldEnvironment.get_children():
		stone.spacing.disabled = true
		stone.mode = RigidBody2D.MODE_STATIC
	
func make_rooms():
	for _i in range(num_rooms):
		var pos = Vector2(rand_range(-v_spread,v_spread),0)
		var r = Room.instance()
		var room_w = min_size + randi() % (max_size - min_size)
		var room_h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(room_w, room_h) * tile_size)
		$Rooms.add_child(r)
	yield(get_tree().create_timer(1.1),"timeout")
	var room_positions = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.mode = RigidBody2D.MODE_STATIC
			room.get_node('CollisionShape2D').disabled = true
			room_positions.append(Vector2(room.position.x, room.position.y))
	yield(get_tree(), "idle_frame")
	path = find_mst(room_positions)
	
#func _draw() -> void:
#	for room in $Rooms.get_children():
#		draw_rect(Rect2(room.position - room.size, room.size * 2), Color(255, 0, 0), false)
#	if path:
#		for p in path.get_points():
#			for c in path.get_point_connections(p):
#				var pp = path.get_point_position(p)
#				var cp = path.get_point_position(c)
#				draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y),
#						  Color(1, 1, 0), 15, true)

func _process(_delta: float) -> void:
	OS.set_window_title( "fps: " + str(Engine.get_frames_per_second())) #!!!!!!!!!!!!!!!!!!!!
	update()
	
#func _input(event: InputEvent) -> void:
#	if event.is_action_pressed("ui_select"):
#		for n in $Rooms.get_children():
#			n.queue_free()
#		make_rooms()
#	if event.is_action_pressed("ui_focus_next"):
#		make_map()
#	if event.is_action_pressed("ui_cancel"):
#		player = Player.instance()
#		add_child(player)
#		player.position = start_room.position
#		play_mode = true

func find_mst(nodes):
	var _path = AStar2D.new()
	_path.add_point(_path.get_available_point_id(), nodes.pop_front())
	
	while nodes:
		var min_dist = INF
		var min_p = null
		var p = null
		for point1 in _path.get_points():
			point1 = _path.get_point_position(point1)
			for point2 in nodes:
				if point1.distance_to(point2) < min_dist:
					min_dist = point1.distance_to(point2)
					min_p = point2
					p = point1
		var n = _path.get_available_point_id()
		_path.add_point(n, min_p)
		_path.connect_points(_path.get_closest_point(p), n)
		nodes.erase(min_p)
	return _path
	
	
			
func make_map():
	Map.clear()
	find_start_room()
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position - room.size, room.get_node('CollisionShape2D').shape.extents*2)
		full_rect = full_rect.merge(r)
	var top_left = Map.world_to_map(full_rect.position)
	var bottom_right = Map.world_to_map(full_rect.end)
	for x in range(top_left.x-20, bottom_right.x+20):
		for y in range(top_left.y-20, bottom_right.y+20):	
			Map.set_cell(x, y, 5)
	
	# Carve rooms
	var corridors = []  # One corridor per connection
	for room in $Rooms.get_children():
		var s = (room.size / tile_size).floor()
		var ul = (room.position / tile_size).floor() - s
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				if randf() < 0.95:
					Map.set_cell(ul.x + x, ul.y + y, randi()%2)
				else:
					Map.set_cell(ul.x + x, ul.y + y, randi()%3 + 2)
		# Carve connecting corridor
		var p = path.get_closest_point(Vector2(room.position.x, 
											room.position.y))
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = Map.world_to_map(Vector2(path.get_point_position(p).x,
													path.get_point_position(p).y))
				var end = Map.world_to_map(Vector2(path.get_point_position(conn).x,
													path.get_point_position(conn).y))									
				carve_path(start, end)
		corridors.append(p)
	beautify_map(top_left, bottom_right)
		
		
func carve_path(pos1, pos2):
	# Carve a path between two points
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 2)
	# choose either x/y or y/x
	var x_y = pos1
	var y_x = pos2
	if (randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff):
		Map.set_cell(x, x_y.y, randi()%2)
		Map.set_cell(x, x_y.y + y_diff, randi()%2)  # widen the corridor
	for y in range(pos1.y, pos2.y, y_diff):
		Map.set_cell(y_x.x, y, randi()%2)
		Map.set_cell(y_x.x + x_diff, y, randi()%2)
	
	
func beautify_map(top_left, bottom_right):
	for x in range(top_left.x, bottom_right.x):
		for y in range(top_left.y, bottom_right.y):	
			if Map.get_cell(x,y) == 5:
				if Map.get_cell(x+1,y) < 5:
					Map.set_cell(x,y,12) #left
				if Map.get_cell(x-1,y) < 5:
					Map.set_cell(x,y,13) #right
				if Map.get_cell(x,y+1) < 5:
					if randf() < 0.7:
						Map.set_cell(x,y,6) #up
					else:
						Map.set_cell(x,y,randi()%4 + 7) #up
				if Map.get_cell(x,y-1) < 5:
					Map.set_cell(x,y,11) #down
				
					
				if Map.get_cell(x+1,y) < 5 and Map.get_cell(x,y+1) < 5:
					Map.set_cell(x,y,14) #left + up
				if Map.get_cell(x-1,y) < 5 and Map.get_cell(x,y+1) < 5:
					Map.set_cell(x,y,15) #right + up
				if Map.get_cell(x+1,y) < 5 and Map.get_cell(x,y-1) < 5:
					Map.set_cell(x,y,16) #left + down
				if Map.get_cell(x-1,y) < 5 and Map.get_cell(x,y-1) < 5:
					Map.set_cell(x,y,17) #right + down
					
				if Map.get_cell(x+1,y+1) < 5 and Map.get_cell(x+1,y) == 5 and Map.get_cell(x,y+1) == 5:
					Map.set_cell(x,y,18) #left + up
				if Map.get_cell(x-1,y-1) < 5 and (Map.get_cell(x-1,y) == 11 or Map.get_cell(x-1,y) == 17) and (Map.get_cell(x,y-1) == 13 or Map.get_cell(x,y-1) == 17):
					Map.set_cell(x,y,19) #right + up
				if Map.get_cell(x-1,y+1) < 5 and (Map.get_cell(x-1,y) in range(6,11) or Map.get_cell(x-1,y) == 15) and Map.get_cell(x,y+1) == 5:
					Map.set_cell(x,y,20) #left + up
				if Map.get_cell(x+1,y-1) < 5 and Map.get_cell(x+1,y) == 5 and (Map.get_cell(x,y-1) == 12 or Map.get_cell(x,y-1) == 16):
					Map.set_cell(x,y,21) #right + up
				
				
	
func find_start_room():
	var min_x = INF
	for room in $Rooms.get_children():
		if room.position.x < min_x:
			start_room = room
			min_x = room.position.x

func play_random_noise_in_room():
	if randf() < 0.7:
		var room = $Rooms.get_child(randi() % $Rooms.get_child_count())
		room.audio_player.stream = Noises[randi() % Noises.size()]
		room.audio_player.volume_db = (((0 - (player.global_position - room.position).length()) * (-30 + 20)) / (0 - 5000.0)) - 20
		room.audio_player.play()
	
