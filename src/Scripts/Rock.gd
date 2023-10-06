extends RigidBody2D

onready var area = $Area2D
onready var spacing = $spacing

var stone_sprites = [
preload("res://assets/Background/stones 0.png"),
preload("res://assets/Background/stones 1.png"),
preload("res://assets/Background/stones 2.png"),
preload("res://assets/Background/stones 3.png")
]
var rooms

func _ready() -> void:
	randomize()
	$body.texture = stone_sprites[randi() % stone_sprites.size()]
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha($body.texture.get_data())
	
	var merged_poly = []
	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, $body.texture.get_size()))
	for poly in polys:
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = poly
		var merged = Geometry.merge_polygons_2d(merged_poly, poly)
		merged_poly = merged[0]
		add_child(collision_polygon)

		# Generated polygon will not take into account the half-width and half-height offset
		# of the image when "centered" is on. So move it backwards by this amount so it lines up.
		if $body.centered:
			collision_polygon.position -= bitmap.get_size()/2	
	var ocl_poly = OccluderPolygon2D.new()
	merged_poly = Transform2D(0, Vector2(-$body.texture.get_width()/2,-$body.texture.get_height()/2)).xform(merged_poly)
	ocl_poly.polygon = merged_poly
	$LightOccluder2D.set_occluder_polygon(ocl_poly)


