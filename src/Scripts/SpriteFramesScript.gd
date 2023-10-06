extends SpriteFrames

class_name SpriteFrameResource

const name = "Walk"


var Walk1 = load("res://assets/Player/Walk/Man_walk_1.png")
var Walk2 = load("res://assets/Player/Walk/Man_walk_2.png")
var Walk3 = load("res://assets/Player/Walk/Man_walk_3.png")
var Walk4 = load("res://assets/Player/Walk/Man_walk_4.png")
var Walk5 = load("res://assets/Player/Walk/Man_walk_5.png")
var Walk6 = load("res://assets/Player/Walk/Man_walk_6.png")


func getFrames() -> SpriteFrames:
	
	self.add_animation(name)
	
	self.add_frame(name, Walk1)
	self.add_frame(name, Walk2)
	self.add_frame(name, Walk3)
	self.add_frame(name, Walk4)
	self.add_frame(name, Walk5)
	self.add_frame(name, Walk6)
	
	self.set_animation_loop(name, true)
	self.set_animation_speed(name, 5.0)
	
	return self
