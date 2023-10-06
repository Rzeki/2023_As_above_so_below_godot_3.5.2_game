extends RigidBody2D

var size
onready var audio_player = $Noise_player

func make_room(_pos, _size):
	position = _pos
	size = _size
	var s = RectangleShape2D.new()
	s.extents = size
	s.custom_solver_bias = 0.8
	var _d = CollisionShape2D.new()
	$CollisionShape2D.shape = s
