extends StaticBody2D

# 为了查找这些节点，使用关键字 onready
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var polygon_2d: Polygon2D = $CollisionPolygon2D/Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 提取CollisionShape2D的形状 ，分配给 "视觉上的Visual"Polygon2D
	polygon_2d.polygon = collision_polygon_2d.polygon		# 注意！！ 是polygon，不是polygons
	pass # Replace with function body.
